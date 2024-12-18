local logging = require('app/shared/utils/logging')
local persistent = persistent

local Persistent = {}

function Persistent:test(core, ad_request)
  local worked, result = pcall(function()

    local resultString = ''

    if persistent and persistent.shared then
      if persistent.shared.zDate == '' or persistent.shared.zDate == nil then
        persistent.shared.zDate = core.session.time_local
      end
      resultString = resultString.. '__shared:'.. persistent.shared.zDate
    end

    if persistent and persistent.service then
      if persistent.service.zDate == '' or persistent.service.zDate == nil then
        persistent.service.zDate = core.session.time_local
      end
      resultString = resultString .. '__service:'.. persistent.service.zDate
    end

    if persistent and persistent.channel then
      if persistent.channel.zDate == '' or persistent.channel.zDate == nil then
        persistent.channel.zDate = core.session.time_local
      end
      resultString = resultString .. '__channel:'.. persistent.channel.zDate
    end

    return resultString

  end)

  core:timer(1000, function() ad_request.tracker:send_widget_event('persistentTest', tostring(worked), result) end)

  if worked and result then
      core.capability_persistent = true
  end

  if core.debug_mode then
    logging.info(worked)
    logging.info(result)
    logging.info(core.capability_persistent)
  end
end

return Persistent