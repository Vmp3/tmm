----------------------
--- Module: AdRequest
--- Author: Kelvin Camilo - Zedia
--- All rights reserved, 2022
----------------------


-- Global modules
local event = event

-- Esse modulo cuida atualmente de:
--   * Requests para o AdServer, informando dados necessários para a segmentação e impressão de anúncios automatizados.
local http = require('app/shared/utils/ncluahttp')
local logging = require('app/shared/utils/logging')
local json = require('app/shared/utils/json_new')
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')
local util = require('app/shared/utils/util')
local Interaction = require('app/events/interaction')
local ExecutableAppTracker = require('app/events/tracker').ExecutableAppTracker
local Asker = require('app/ui/widgets/asker').Asker
local Home = require('app/ui/pages/home').Home
local ChannelInfo = require('app/ui/widgets/channel_info').ChannelInfo
local Reactions = require('app/ui/widgets/reactions').Reactions
local OpeningAds = require('app/ui/widgets/opening_ads').OpeningAds
local HalfOpeningAds = require('app/ui/widgets/halfopening_ads').HalfOpeningAds
local Carousel = require('app/ui/widgets/carousel').Carousel
local storage = require('app/storage/storage_api').StorageAPI
local envs = require('config/envs')

local opening_channel_info = ChannelInfo
local opening_reactions = Reactions
local home = Home
local opening_ads = OpeningAds
local halfopen_ads = HalfOpeningAds

local RunnableAdRequest = {
  parent = {},
  tracker = nil,
  debug_mode = true,
  name = nil, -- type str
  state = 'ready', -- type enum['ready', 'running', 'finished'] blocked state?
  app_id = nil,
  user_id = nil,
  publisher_id = nil,
  campaign_id = nil,
  session_id = nil,
  ad_request_url = nil,
  delay_window = 0, --type: int, in ms
  delay_offset = 0, --type: int, in ms
  request_count = 0,
  ad_requests_callback_responses = 0, --type: int
    ad_controller = {
        is_ad_running = false,
        active_ad = nil,
        ad_uptime = 0,
    },
    poll_controller = {
        poll_to_deliver = false,
    },
    request_params = {
        workspace_id = nil,
        isp = nil,
        geo_lat = nil,
        geo_lon = nil,
        geo_city = nil,
        geo_region = nil,
        geo_country = nil,
        geo_accur = nil,
        city_code = nil,
    },
    response_data = {
      id = nil,
      order_id = nil,
      name = nil,
      timestamp = nil,
      impression_key = nil,
      click_key = nil,
      poll_key = nil,
      poll = {
        id = nil,
        workspace_id = nil,
        workspace_name = nil,
        question = nil,
        options = {}
      }
    }
}

------------------- // Analytics \\ --------------------

function RunnableAdRequest:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.tracker = ExecutableAppTracker:new({
    parent = o.parent,
    debug_mode = o.debug_mode,
    name = 'tracker',
    app_id = o.app_id,
    publisher_id = o.publisher_id,
    campaign_id = '',
    session_id = o.session_id,
    delay_window = 30000,
    tracker_url = envs.TRACKER_URL,
  })
  return o
end

------------------------- // Support Functions \\ --------------------------------
local widgets_swipe_buttons = {
  [1] = {name = 'heart_reaction', button = opening_reactions.reaction_1_button},
  [2] = {name = 'claps_reaction', button = opening_reactions.reaction_2_button},
  [3] = {name = 'astonished_reaction', button = opening_reactions.reaction_3_button},
  [4] = {name = 'thumb_down_reaction', button = opening_reactions.reaction_4_button},
  [5] = {name = 'opening_ad', button = opening_ads.opening_image}
}

local function reset_ad_state(ad_request)
  for _, button in ipairs(widgets_swipe_buttons) do
    button.button.is_focused = false
  end

  Interaction.cursor_current_position_y = 1
  Interaction.cursor_current_position_x = 1
  ad_request.ad_controller = {
    is_ad_running = false,
    active_ad = nil,
    ad_uptime = 0,
  }
  ad_request.response_data = {
    id = nil,
    order_id = nil,
    name = nil,
    poll = {}
  }
  halfopen_ads.visibility = false
  opening_ads.visibility = false

  event.post("out",
    {
      class = 'ncl',
      type = 'edit',
      command = 'setPropertyValue',
      nodeId = 'application',
      propertyId = 'upsize',
      value = '1'
    }
  )

  Render.clear()
  if  ad_request.poll_controller.poll_to_deliver then
    ad_request.poll_controller.poll_to_deliver = false
    ad_request.ad_controller.active_ad = 'asker'
    ad_request.ad_controller.is_ad_running = true
    ad_request:load_asker_bg()
    ad_request:load_asker(true)
    ad_request:interaction_check(30)
  end
  
end

function RunnableAdRequest:reset_ad_uptime()
  self.ad_controller.ad_uptime = 0
end

function RunnableAdRequest:set_ad_uptime(time)
  self.ad_controller.ad_uptime = time
end

function RunnableAdRequest:interaction_check(time)
  time = time or 30 -- set default time to 30 seconds

  local function check_ad_time()
    if not self.ad_controller.is_ad_running then return end

    if self.ad_controller.active_ad:find('maxpage') then
      time = 300
    end
    if self.ad_controller.active_ad:find('asker') then
      time = 60
    end
    if self.ad_controller.ad_uptime > time and self.ad_controller.is_ad_running then
      reset_ad_state(self)
      if self.debug_mode then logging.counter(self.ad_controller.ad_uptime) end
    else
      if self.debug_mode then logging.counter(self.ad_controller.ad_uptime) end
      self.ad_controller.ad_uptime = self.ad_controller.ad_uptime + 1
      self.parent:timer(1000, check_ad_time)
    end
  end

  self.parent:timer(1000, check_ad_time) -- start the initial timer
end

---------------------------- // Load Ad Functions \\ ----------------------

function RunnableAdRequest:load_thanks(key)
  local reaction_image = opening_reactions["reaction_" .. key .. "_image"]
  reaction_image.file_name = "reaction_" .. key .. "_big"
  home:new({})
  home:flush()

  self.parent:timer(120, function()
    reaction_image.file_name = "reaction_" .. key
    home:new({})
    home:flush()
  end)

  self.parent:timer(240, function()
    reaction_image.file_name = "reaction_" .. key .. "_big"
    home:new({})
    home:flush()
  end)

  self.parent:timer(360, function()
    reaction_image.file_name = "reaction_" .. key
    home:new({})
    home:flush()
  end)

end

function RunnableAdRequest:load_opening(ad_name, user_call)
  if ad_name == nil then ad_name = "opening" end
  opening_ads.opening_image.file_name = ad_name
  home:load_opening_bg_gradient()


  if ad_name ~= 'opening' then
    home:load_navigator(true)
    opening_ads:set_visibility(true)
    opening_ads.opening_image.is_focused = true
  elseif ad_name == 'opening' then
    widgets_swipe_buttons[1].button.is_focused = true
  end

  home:new({})
  home:flush()

  self.ad_controller.is_ad_running = true
  local user_called = user_call

  if ad_name ~= 'opening' then
    self.parent:timer(1000, function() self:impression_callback() self:interaction_check(30) end)
  else
    self.parent:timer(1000, function() self.tracker:send_opening_impression_event(user_called) self:interaction_check(10) end)
  end
end

function RunnableAdRequest:load_halfopening(ad_name, user_call)
  halfopen_ads.opening_image_1.file_name = ad_name .. '_1'
  halfopen_ads.opening_image_2.file_name = ad_name .. '_2'
  widgets_swipe_buttons = {
    [1] = {name = 'heart_reaction', button = opening_reactions.reaction_1_button},
    [2] = {name = 'claps_reaction', button = opening_reactions.reaction_2_button},
    [3] = {name = 'astonished_reaction', button = opening_reactions.reaction_3_button},
    [4] = {name = 'thumb_down_reaction', button = opening_reactions.reaction_4_button},
    [5] = {name = 'halfopen_app', button = halfopen_ads.opening_image_1},
    [6] = {name = 'halfopen_ad', button = halfopen_ads.opening_image_2},
  }

  home:load_opening_bg_gradient()
  home:load_navigator(true)
  halfopen_ads:set_visibility(true)
  HalfOpeningAds.opening_image_2.is_focused = true
  HalfOpeningAds.opening_image_1.is_focused = false

  home:new({})
  home:flush()

  self.ad_controller.is_ad_running = true
  self.parent:timer(1000, function() self:impression_callback() self:interaction_check(30) end)
end

function RunnableAdRequest:load_maxpage(ad_name)
  local path = 'local/assets/'
  local maxpage = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name = ad_name
  })

  self.ad_controller.ad_uptime = 0
  self.ad_controller.is_ad_running = true

  Render.image(maxpage)
  Render.flush()

end

function RunnableAdRequest:load_asker_bg()
  local path = 'local/system/'
  local background = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name =  'asker_background'
  })
  Render.image(background)
  Render.flush()
end

function RunnableAdRequest:load_asker(send_impression)
  if not send_impression then send_impression = false end

  self.asker:render()
  if send_impression then
    self.parent:timer(4000, function() self.tracker:send_poll_impression(self.asker.poll_id) end)
    if self.asker.survey_id then
      self.parent:timer(8000, function() self.tracker:send_survey_impression(self.asker.survey_id) end)
    end
  end
end

function RunnableAdRequest:load_float(ad_name, page, send_impression)
  if not send_impression then send_impression = false end
  if page == nil then page = '1' end

  local path = 'local/assets/'
  local float = Image:new({
      parent = self,
      position = {
        x = 0,
        y = 10,
      },
      path = path,
      extension = '.png',
      file_name = ad_name .. '_' .. page
  })
  if float then
    Render.image(float)
    Render.flush()

    if send_impression then
      self.parent:timer(1000, function() self:impression_callback() end)
    end
 end

  if self.debug_mode then
    logging.info('[AdRequest] loading float')
  end
end

function RunnableAdRequest:load_float_bg()
  local path = 'local/system/'
  local background = Image:new({
      parent = self,
      position = {
        x = 0,
        y = 0,
      },
      path = path,
      extension = '.png',
      file_name =  'float_background'
  })
  -- Para formato push comentar as proximas duas linhas. 
  Render.image(background)
  Render.flush()
end

function RunnableAdRequest:load_skyscraper_bg()
  local path = 'local/system/'
  local background = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name =  'skcf_background'
  })
  Render.image(background)
  Render.flush()
end

function RunnableAdRequest:load_skyscraper_half_bg()
  local path = 'local/system/'
  local background = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name =  'skch_background'
  })
  Render.image(background)
  Render.flush()
end

function RunnableAdRequest:load_skyscraper(ad_name, page, send_impression)
  if not send_impression then send_impression = false end
  if page == nil then page = '1' end

  local path = 'local/assets/'

  local skyscraper = Image:new({
    parent = self,
    position = {
      x = 1060,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name = ad_name .. '_' .. page
  })
  if skyscraper then
    Render.image(skyscraper)
    Render.flush()

    if send_impression then
      self.parent:timer(1000, function() self:impression_callback() end)
    end

    if self.debug_mode then
      logging.info('[AdRequest] loading skyscraper')
    end
  end
end

function RunnableAdRequest:load_skyscraper_half(ad_name, page, send_impression)
  if not send_impression then send_impression = false end
  if page == nil then page = '1' end

  local path = 'local/assets/'
  local skyscraper_half = Image:new({
    parent = self,
    position = {
      x = 1060,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name = ad_name .. '_' .. page
  })
  if skyscraper_half then
    Render.image(skyscraper_half)
    Render.flush()

    if send_impression then
      self.parent:timer(1000, function() self:impression_callback() end)
    end
  end
  if self.debug_mode then
    logging.info('[AdRequest] loading skyscraper half')
  end
end

function RunnableAdRequest:load_squeeze(ad_name, send_impression)
  if not send_impression then send_impression = false end

  local path = 'local/assets/'
  local squeeze_side = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name = string.lower(ad_name) .. '_side'
  })

  local squeeze_bottom = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 0,
    },
    path = path,
    extension = '.png',
    file_name = string.lower(ad_name) .. '_bottom'
  })

  if squeeze_side and squeeze_bottom then
    self.parent:timer(100,
      function()
        event.post("out",{
          class = 'ncl',
          type = 'edit',
          command = 'setPropertyValue',
          nodeId = 'application',
          propertyId = 'downsize',
          value = '1'
        })
      end
    )
    Render.image(squeeze_side)
    Render.image(squeeze_bottom)
    Render.flush()

    if send_impression then
      self.parent:timer(1000, function() self:impression_callback() end)
    end
  end
  if self.debug_mode then
    logging.info('[AdRequest] loading squeeze')
  end
end

function RunnableAdRequest:load_carousel(ad_name, send_impression)
  if not send_impression then send_impression = false end
    Carousel:set_brand_image(ad_name)
    Carousel:set_options(ad_name)
    Carousel:set_options_position()
    -- Carousel:render_bg()
    Carousel:render()
  if send_impression then
    self.parent:timer(1000, function() self:impression_callback() end)
  end

  if self.debug_mode then
    logging.info('[AdRequest] loading carousel')
  end
end

---------------------------- // AdRequest Functions \\ --------------------------------

function RunnableAdRequest:start()
  assert(self.publisher_id, 'publisherID is required')
  assert(self.app_id, 'appID is required')
  assert(self.ad_request_url, 'baseURL is required')
  self.tracker:start()
  self:send_ad_request('opening')
end

function RunnableAdRequest:send_ad_request(placement, is_user_call)
  if placement == nil then placement = 'overlay' end
  local is_call = is_user_call or false
  if self.debug_mode then
      logging.info('[AdRequest] Sending ad request')
  end
  if not self.ad_controller.is_ad_running then
    local workspaceId = tostring(self.request_params.workspace_id)
    local sessionId = tostring(self.session_id)
    local internetProvider = tostring(self.request_params.isp)
    local geoRegion = string.lower(self.request_params.geo_region)
    local geoCity = string.lower(self.request_params.geo_city)
    local geoCityCode = tostring(self.request_params.city_code)
    local connId = tostring(self.parent.session.conn_id)
    local query = string.format(
      '/criteria/?workspaceId=%s&sessionId=%s&internetProvider=%s&placement=%s&geoRegion=%s&geoCity=%s&connId=%s&cityCode=%s',
      workspaceId, sessionId, internetProvider, placement, geoRegion, geoCity, connId, geoCityCode
    )

    query = string.gsub(query, " ", "%%20")

    http.request(self.ad_request_url .. query,
      function(header, body) self.parent:timer(1, function() self:ad_request_callback(header, body, placement, is_call) end) end,
      "GET"
    )
    if self.debug_mode then
        -- logging.network_request(self.ad_request_url .. query)
      logging.info('[AdRequest] recurrent ad request sent')
    end
  else
    self.parent:timer(self.delay_window,
      function()
        self:send_ad_request(placement, is_user_call)
      end
    )
  end
end

function RunnableAdRequest:ad_request_callback(header, body, placement, is_user_call)
  self:init_asker()
  self:update_counts()

  local lower_header = string.lower(header)
  if self.debug_mode then
    self:log_debug('[AdRequest] response received')
  end

  if lower_header:find("204 no") and placement == 'opening' then
    self:handle_opening_response(is_user_call)
  elseif lower_header:find("200 ok") then
    self:handle_ok_response(body, is_user_call)
  else
    self:handle_error_response(is_user_call)
  end
end

function RunnableAdRequest:init_asker()
  self.asker = Asker:new({})
end

function RunnableAdRequest:update_counts()
  self.request_count = self.request_count + 1
  self.ad_requests_callback_responses = self.ad_requests_callback_responses + 1
end

function RunnableAdRequest:log_debug(message)
  logging.callback(message)
end

function RunnableAdRequest:handle_opening_response(is_user_call)
  self.ad_controller.active_ad = 'opening'
  self.ad_controller.is_ad_running = true
  self.delay_window = 30000

  if self.debug_mode then
    self:log_debug('[AdRequest] delay window: ' .. self.delay_window)
  end

  self:handle_request_delay(is_user_call)
  self:load_opening(nil, is_user_call)
end

function RunnableAdRequest:handle_ok_response(body, is_user_call)
  self.delay_window = 300000

  if self.debug_mode then
    self:log_debug('[AdRequest] delay window: ' .. self.delay_window)
  end

  self.ad_controller.is_ad_running = true

  local lower_decoded_body = json.decode(string.lower(body))
  local decoded_body = json.decode(body)

  if self.debug_mode then
    util.printable(lower_decoded_body)
  end

  self:set_ad_properties(lower_decoded_body, decoded_body)
  self:handle_load_ad(is_user_call)
end

function RunnableAdRequest:handle_error_response(is_user_call)
  self.delay_window = 30000

  if self.debug_mode then
    self:log_debug('[AdRequest] delay window: ' .. self.delay_window)
  end

  self:handle_request_delay(is_user_call)
end

function RunnableAdRequest:set_ad_properties(lower_decoded_body, decoded_body)
  if not lower_decoded_body.name then
    lower_decoded_body.name = 'opening'
  end

  if lower_decoded_body.id then
    self.response_data.id = tostring(lower_decoded_body.id)
    self.tracker.app_id = tostring(lower_decoded_body.id)
  end
  if lower_decoded_body.name then
    self.response_data.name = tostring(lower_decoded_body.name)
    self.ad_controller.active_ad = tostring(lower_decoded_body.name)
  end
  if lower_decoded_body.orderid then
    self.response_data.order_id = tostring(lower_decoded_body.orderid)
    self.tracker.campaign_id = tostring(lower_decoded_body.orderid)
  end
  if lower_decoded_body.timestamp then
    self.response_data.timestamp = tostring(lower_decoded_body.timestamp)
    self.asker.poll_timestamp = tostring(lower_decoded_body.timestamp)
  end
  if lower_decoded_body.impressionkey then
    self.response_data.impression_key = tostring(lower_decoded_body.impressionkey)
  end
  if lower_decoded_body.clickkey then
    self.response_data.click_key = tostring(lower_decoded_body.clickkey)
  end
  if lower_decoded_body.pollkey then
    self.asker.poll_key = tostring(lower_decoded_body.pollkey)
  end
  if lower_decoded_body.surveyid then
    self.asker.survey_id = lower_decoded_body.surveyid
  end
  if lower_decoded_body.polls and #lower_decoded_body.polls > 0 then
    local index = #lower_decoded_body.polls
    decoded_body.poll = decoded_body.polls[1]
    lower_decoded_body.poll = lower_decoded_body.polls[1]
    while index >= 2 do
      self.asker:set_next_poll(decoded_body.polls[index])
      index = index - 1
    end
    self.asker.poll_key = tostring(lower_decoded_body.poll.pollkey)
  end
  if lower_decoded_body.poll and lower_decoded_body.poll.id then
    local questions = lower_decoded_body.polls and #lower_decoded_body.polls ~= 0 and #lower_decoded_body.polls
    self.asker.poll_id = tostring(lower_decoded_body.poll.id)
    self.poll_controller.poll_to_deliver = true
    self.asker:set_options(decoded_body.poll.options)
    self.asker:set_question(decoded_body.poll.question)
    self.asker:set_question_number(1, questions or 1)
  end
end

function RunnableAdRequest:handle_load_ad(is_user_call)
  local file_exists = storage:file_check('local/assets/', tostring(self.response_data.name) .. '_1', '.png', self.debug_mode)
  local opening_file_exists = storage:file_check('local/assets/', tostring(self.response_data.name), '.png', self.debug_mode)
  local squeeze_side_exists = storage:file_check('local/assets/', tostring(self.response_data.name) .. '_side', '.png', self.debug_mode)
  local squeeze_bottom_exists = storage:file_check('local/assets/', tostring(self.response_data.name) .. '_bottom', '.png', self.debug_mode)

  if not is_user_call then
    self:handle_request_delay(is_user_call)
  end


  if file_exists or (squeeze_side_exists and squeeze_bottom_exists) or opening_file_exists or self.poll_controller.poll_to_deliver then
    local ad_name = tostring(self.response_data.name)

    if ad_name:find('opening') then
      Interaction:set_x_pos(5)
      self:load_opening(ad_name, is_user_call)
    elseif ad_name:find('halfopen') then
      Interaction:set_x_pos(5)
      self:load_halfopening(ad_name, true)
    elseif ad_name:find('asker') then
      self:load_asker_bg()
      self:load_asker(true)
      self:interaction_check(30)
    elseif ad_name:find('float') then
      self:load_float_bg()
      self:load_float(ad_name, 1, true)
      self:interaction_check(30)
    elseif ad_name:find('skcf') then
      self:load_skyscraper_bg()
      self:load_skyscraper(ad_name, 1, true)
      self:interaction_check(30)
    elseif ad_name:find('skch') then
      self:load_skyscraper_half_bg()
      self:load_skyscraper_half(ad_name, 1, true)
      self:interaction_check(30)
    elseif ad_name:find('squeeze') then
      self:load_squeeze(ad_name, true)
      self:interaction_check(30)
    elseif ad_name:find('carousel') then
      self:load_carousel(ad_name, true)
      self:interaction_check(30)
    end
  else
    local ad_name = tostring(self.response_data.name)
    if ad_name:find('opening') or ad_name:find('halfopen') then
      self.ad_controller.active_ad = 'opening'
      self:load_opening(nil, is_user_call)
    else
      self:reset_ad_state()
    end
  end
end

function RunnableAdRequest:handle_request_delay(is_user_call)
  if not is_user_call then
    self.parent:timer(self.delay_window, function() self:request_timer_callback() end)
  end
end

function RunnableAdRequest:request_timer_callback()
  self:send_ad_request()
end


function RunnableAdRequest:reset_ad_state()
  reset_ad_state(self)
end

function RunnableAdRequest:impression_callback()
  self.parent:timer(100, function()
    local lineId = tostring(self.response_data.id)
    local orderId = tostring(self.response_data.order_id)
    local sessionId = tostring(self.session_id)
    local timestamp = tostring(self.response_data.timestamp)
    local impressionKey = tostring(self.response_data.impression_key)
    local connId = tostring(self.parent.session.conn_id)

    local callback_query = string.format(
      '/impression-callback/?lineId=%s&orderId=%s&sessionId=%s&timestamp=%s&impressionKey=%s&connId=%s',
      lineId, orderId, sessionId, timestamp, impressionKey, connId
    )

    http.request(self.ad_request_url .. callback_query,
      function(header, body)
          self.parent:timer(1000, function() self:impression_callback_response(header, body) end)
          if self.debug_mode then
              logging.network_request(callback_query)
              logging.callback("[AdRequest] Impression callback sent to AdServer")
          end
      end,
      "GET"
    )
  end)
end


function RunnableAdRequest:impression_callback_response(header, body)
  local lower_header = string.lower(header)

  if lower_header:find("200 ok") then
    self.parent:timer(2000,
      function()
        self.tracker:send_ad_impression_event()
      end
    )
    if self.debug_mode then
      logging.callback('[AdRequest] response received, impression sent to Analytics Server')
    end
  else
    reset_ad_state(self)
  end
end

function RunnableAdRequest:click_callback(clicked_button)
  self.parent:timer(100, function()
    local lineId = tostring(self.response_data.id)
    local orderId = tostring(self.response_data.order_id)
    local sessionId = tostring(self.session_id)
    local timestamp = tostring(self.response_data.timestamp)
    local clickKey = tostring(self.response_data.click_key)
    local connId = tostring(self.parent.session.conn_id)

    local callback_query = string.format(
      '/click-callback/?lineId=%s&orderId=%s&sessionId=%s&timestamp=%s&clickKey=%s&connId=%s',
      lineId, orderId, sessionId, timestamp, clickKey, connId
    )

    http.request(self.ad_request_url .. callback_query,
      function(header, body)
          self.parent:timer(1000, function() self:click_callback_response(header, body, clicked_button) end)
          if self.debug_mode then
              logging.network_request(callback_query)
              logging.callback("[AdRequest] Click callback sent to AdServer")
          end
      end,
      "GET"
    )
  end)
end


function RunnableAdRequest:click_callback_response(header, body, clicked_button)
  local lower_header = string.lower(header)

  if lower_header:find("200 ok") then
    self.parent:timer(2000,
      function()
        self.tracker:send_ad_click_event(clicked_button)
      end
    )
    if self.debug_mode then
      logging.callback('[AdRequest] response received, click sent to Analytics Server')
    end
  else
    reset_ad_state(self)
  end
end

local P = {}
P.RunnableAdRequest = RunnableAdRequest

return P