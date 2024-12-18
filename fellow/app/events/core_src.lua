local envs = require('config/envs')
local http = require('app/shared/utils/ncluahttp')
local json = require('app/shared/utils/json_new')
local util = require('app/shared/utils/util')
local strings = require('app/shared/utils/strings')
local logging = require('app/shared/utils/logging')
local random_seed = require('app/shared/utils/random')
local err = require('app/shared/utils/error')
local RunnableAdRequest = require('app/events/adrequest').RunnableAdRequest
local event = event
local ChannelInfo = require('app/ui/widgets/channel_info').ChannelInfo
local opening_channel_info = ChannelInfo

local Core = {
  debug_mode = envs.DEBUG_MODE, -- debug mode activate prints and logs
  app_name = envs.APP_NAME, -- application name
  app_version = envs.APP_NAME_VERSION, -- test version to control debug
  core_version = envs.APP_VERSION, -- application version
  core_startup_time = 2000, -- time to start-up and load everything - need to make it random
  core_startup_delay = 0, -- time to randomize core startup
  is_loading_core = true, -- true while loading core and session info
  channel_id = '', --WorkspaceID based on where the tv is
  exception_flag = false, -- for error purposes
  exception_cause = 'none', -- for error purposes
  capability_internet = false, -- is capable of making http requests?
  capability_persistent = false,
  prime_time_ads = {
    ad_request = nil,
    time_skip = 8000, -- time to skip advertising
    time_exhibition = 18000, -- advertising exhibition time
    time_sleep = 10000, -- time to sleep between advertising request attempts
    time_interactive = 14400000, -- time of interactivity 
    position = 'bottom', -- advertising position
    ctvOnly = true, -- only connected tv? 
    prime_time_ads_url = envs.PRIMETIME_URL, --session registry and ad request base url
  },
  session = {
    session_server_url = envs.PRIMETIME_URL, --session registry and ad request base url primetime.apis.zedia.com.br
    status = 'unregistered', --type str ['unregistered', 'registered']
    retry_attempts = 0, -- number of retry attempts when session is unavailable
    id = nil, -- type uuid4 - sessionID
    geo_lat = nil, -- latitude of the session
    geo_lon = nil, -- longitude of the session
    geo_city = nil, -- city of the session
    geo_region = nil, -- state of the session
    geo_country = nil, -- country of the session
    city_code = nil, -- citycode of the session
    geo_accur = nil, -- accuracy of the session location
    conn_provider = nil, -- internet service
    conn_id = nil, -- hashed id of the connection
    time_utc = nil, -- datetime in UTC format
    timestamp = nil, -- timestamp of the session
    time_local = nil, -- datetime in local time format
    timezone = nil, -- locale timezone
    widgets = {
        channel_info = {
            name = nil,
            tagline = nil
        },
        home = {
            is_active = false,
            mode = nil
        }
    }, -- list of widgets
  },
  tracker = {
    state = 'ready',
    tracker_url = envs.TRACKER_URL, -- tracker/analytics url 
    _have_recurrent = true, -- have recurrent ping
    recurrent_callback_responses = 0, --type: int
	  report_sample_proportion = 100, --type: int, from 0 to 100, 100 means all reports are sent
    settings = '',
  }
}

function Core:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o:try(function()
    random_seed()
  end)

  o.capability_internet = false
  o.core_startup_delay = math.random(o.core_startup_time)

  -- Health Monitoring
  o.monitoring_period = 120000
  o.connections_tries = 0
  o.connections_success = 0
  o.last_execution = event.uptime()
  o:timer(o.core_startup_delay, function() o:health_monitoring() end )

  -- Interaction control
  o.initial_uptime = event.uptime()
  o.last_interaction = o.initial_uptime -9999 --minus infinity
  o:get_settings()
  o:register(function (evt)
      if evt.class=='key' and evt.type=='press' then
          o.last_interaction = event.uptime()
      end
  end )
  return o
end

function Core:register(f)

  event.register(function(evt)
      local status, exception = pcall(f, evt)

      if not status then
          self.exception_flag = true
          self.exception_cause = ' ' .. tostring(self.exception_cause) .. tostring(exception) --TODO: concatenate or substitute?
            if self.debug_mode then
              logging.error('[CORE] Exception in event handler:')
              logging.error(exception)
            end
      end

  end)
end

function Core:unregister(f)
  --TODO: this does not work because we are registering an anonymous function
  event.unregister(f)
end

function Core:try(f)
  --TODO: we may want to schedule the executions to ensure fair CPU time
  local status, exception = pcall(f)

  if not status then
    self.exception_flag = true
    self.exception_cause = ' ' .. tostring(self.exception_cause) .. tostring(exception) --TODO: concatenate or substitute?
    err:send_pcall_error(status, exception)
  end
end

function Core:timer(time, f)
  local uf = event.timer(time, function() self:try(f) end)
  return uf
end

function Core:uptime()
  return event.uptime() - self.initial_uptime
end

function Core:time_since_last_interaction()
  return event.uptime() - self.last_interaction
end

function Core:register_session()
  local channel = tostring(self.channel_id)
  local app = tostring(self.app_name)
  local version = tostring(self.core_version)

  local query = string.format(
    "/api/v1/media/sessions?channel=%s&app=%s&version=%s",
    channel, app, version
  )

  if self.debug_mode then
    logging.info('Registrando sessão')
    logging.network_request(tostring(self.session.session_server_url) .. query)
  end
  if self.session.retry_attempts < 3 then
    http.request(self.session.session_server_url .. query,
    function(header, body) self:register_session_callback(header, body) end,
    "GET")
  end
end

function Core:register_session_callback(header, body)
  if header:find("200 OK") then
    self:handle_session_registration(body)
  else
    self:handle_failed_session_registration(header)
  end
end

function Core:handle_session_registration(body)
  local decoded_body = json.decode(body)
  self.session = decoded_body
  self.session.status = 'registered'
  self.capability_internet = true

  if self.debug_mode then
    self:print_session_info()
  end

  local ad_request_params = self:generate_ad_request_params()
  self:start_ad_request(ad_request_params)
end

function Core:handle_failed_session_registration(header)
  if self.debug_mode then
    self:log_retry_info(header)
  end

  self.session.retry_attempts = self.session.retry_attempts + 1
  self:retry_registration()
end

function Core:print_session_info()
  util.printable(self.session)
  logging.info('[Core] Session resources loaded successfully')
end


function Core:generate_ad_request_params()
  return {
    workspace_id = self.channel_id,
    isp = self.session.conn_provider or '',
    geo_lat = self.session.geo_lat or '0',
    geo_lon = self.session.geo_lon or '0',
    geo_city = self.session.geo_city or '',
    geo_region = self.session.geo_region or '',
    geo_country = self.session.geo_country or 'brasil',
    geo_accur = self.session.geo_accur or '0',
    city_code = self.session.city_code or ''
  }
end


function Core:start_ad_request(request_params)
  self.prime_time_ads.ad_request = RunnableAdRequest:new({
    parent = self,
    debug_mode = self.debug_mode,
    asker = nil,
    name = 'ad_request',
    publisher_id = self.channel_id,
    session_id = self.session.id or '',
    app_id = self.app_version,
    delay_window = 1000,
    ad_request_url = envs.PRIMETIME_URL..'/api/v1/ads/adrequest',
    request_params = request_params
  })

  opening_channel_info.lower_space.title = strings:uppercase(self.session.widgets.channel_info.name) or ''
  opening_channel_info.lower_space.text = self.session.widgets.channel_info.tagline or ''
  err:inject_core(self)
  self:timer(300, function() self.prime_time_ads.ad_request:start() end)
end


function Core:log_retry_info(header)
  logging.warning("Trying again")
  logging.info(header)
end


function Core:retry_registration()
  self:timer(10000, function() self:register_session() end)
end


function Core:health_monitoring()
  if self.capability_internet then
    self.connections_tries = self.connections_tries + 1
    local current_execution = event.uptime()
    local endpoint = 'ctv-health-monitoring'
    local publisherID = tostring(self.channel_id)
    local campaign = tostring(self.campaign_id)
    local appID = tostring(self.app_id)
    local userID = tostring(self.tracker.user_id)
    local sessionID = tostring(self.session.id)
    local exception_flag = tostring(self.exception_flag)
    local exception_cause = tostring(self.exception_cause)
    local query = string.format(
      '?endpoint=%s&publisherID=%s&campaign=%s&appID=%s&userID=%s&sessionID=%s&exception_flag=%s&exception_cause=%s',
      endpoint, publisherID, campaign, appID, userID, sessionID, exception_flag, exception_cause
    )

    http.request(self.prime_time_ads.ad_request.tracker.tracker_url .. query,
      function (header, body) self.connections_success = self.connections_success + 1 end,
    "GET")
    self.last_execution = current_execution

    if self.connections_tries>5 then
        if self.connections_success <=2 then
          self.capability_internet = false
          self:timer(self.core_startup_time, function() self:register_session() end)
        end
      self.connections_success = 0
      self.connections_tries = 0
    end
  else
    self:try(function() self:register_session() end)
  end

  self:timer(self.monitoring_period, function() self:health_monitoring() end)

end


function Core:get_settings()
 local seed = 'settings:'
 local function addSetting(key, value)
   if value then
     seed = seed .. key .. ':' .. tostring(value) .. '|'
   end
 end

 local system = settings and settings.system

 addSetting('system_CPU', system and system.CPU)
 addSetting('system_memory', system and system.memory)
 addSetting('system_macAddress', system and system.macAddress)
 addSetting('system_OS', system and system.operatingSystem)
 addSetting('system_ScreenSize', system and system.screenSize)
 addSetting('system_ScreenGraphicSize', system and system.screenGraphicSize)
 addSetting('system_luaVersion', system and system.luaVersion)
 addSetting('system_modelID', system and system.modelId)
 addSetting('system_versionID', system and system.versionId)
 addSetting('system_SN', system and system.serialNumber)

 if persistent then
   local persistentUserID = persistent.shared and persistent.shared.zadsUserID
   addSetting('persistent_userID', persistentUserID)
   addSetting('persistent_sharedDate', persistent.shared and persistent.shared.zDate)
 end

 if canvas then
   local dx, dy = canvas:attrSize()
   addSetting('Width', dx)
   addSetting('Height', dy)
 end

 if system then
   addSetting('Language', system.language)
   addSetting('Caption', system.caption)
   addSetting('Subtitle', system.subtitle)
   addSetting('Audio', system.audioType)
   addSetting('Class', system.classNumber)
   addSetting('Ginga', system.GingaNCL and system.GingaNCL.version)
   addSetting('Maker', system.makerId)
   addSetting('Network', system.hasActiveNetwork)
   addSetting('NetworkConnectivity', system.hasNetworkConnectivity)
   addSetting('MaxNetworkBitRate', system.maxNetworkBitRate)
   local user = system.user
   if user then
     addSetting('Age', user.age)
     addSetting('Genre', user.genre)
     addSetting('Location', user.location)
     addSetting('Name', user.name)
   end
   local si = system.si
   if si then
     addSetting('Service', si.numberOfServices)
     addSetting('Partial', si.numberOfPartialServices)
     addSetting('channel_number', si.channeNumber)
   end
   local full_settings = util.tableToString(settings)
   addSetting('full_settings', full_settings)
 end

 self.settings = seed
end

---------------------------------
------- // Instance \\ -----------
local P = {}
P.Core = Core

return P
