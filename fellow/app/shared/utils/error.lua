local http = require('app/shared/utils/ncluahttp')
local envs = require('config/envs')

local Error = {
  debug_mode = true,
  url =  envs.TRACKER_URL .. "?endpoint=ctv-error&publisherID=%s&eventType=ctv-error&campaignID=%s&appID=%s&userID=%s&sessionID=%s&error=%s",
  core = nil
}

function Error:send_pcall_error(s, e)
  local status = s or false
  local err = e or nil
  local formatted_error = string.format('&error=status:%s|exception:%s', tostring(status), tostring(err))
  local formatted_url = ''

  if self.core then
    formatted_url = string.format(self.url, self.core.channel_id, self.core.campaign_id, self.core.app_id, self.core.tracker.user_id, self.core.session.id, err)
  end

  if self.debug_mode then
    print(formatted_error)
    print(formatted_url)
  end

  http.request(formatted_url,
    function(header, body) print(header, body) end,
    "GET"
  )

end

function Error:inject_core(core)
  self.core = core
end

return Error