local Core = require('app/events/core_src').Core
local Interaction = require('app/events/interaction')
local logging = require('app/shared/utils/logging')
local envs = require('config/envs')
local engine_started = false

-------------------- // APP INITIALIZATION \\ --------------------

local core = Core:new({
  debug_mode = envs.DEBUG_MODE,
  event_debug_mode = envs.EVENT_DEBUG_MODE,
  app_name = envs.APP_NAME,
  app_version = envs.APP_NAME_VERSION,
  core_version = envs.APP_VERSION,
  channel_id = envs.CHANNEL_WORKSPACE_ID
})

if core.debug_mode then
  core.channel_id = 'ebe55c6d-3faa-4d23-8f7f-df897b1bddab' -- Zedia Development Channel
end

logging.inject_core(core)

-------------------- // Interaction Handler \\ --------------------

local function handler(evt)
  if core.event_debug_mode then
    for k, v in pairs(evt) do
      logging.event(tostring(k) .. '=' ..  tostring(v))
    end
  end

  if evt.class == 'ncl' and evt.type == 'presentation' then
    if core.debug_mode then
      logging.info("NCL presentation.")
    end
  elseif evt.class == 'key' and evt.type == 'press' then
    if evt.key == 'RED' and not engine_started then
      engine_started = true
      print('loading engine....')
      print(pcall(function() require('engine/main')({class='ncl', action='start'}, 'engine/game') end))
    end
    if core.prime_time_ads.ad_request ~= nil then
      Interaction:control(evt.key, core)
    end
  end

end

event.register(handler)

