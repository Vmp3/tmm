----------------------
--- Module: AdRequest
--- Author: Kelvin Camilo - Zedia
--- All rights reserved, 2022
----------------------


-- Esse modulo cuida atualmente de:
--   * Requests para o AdServer, informando dados necessários para a segmentação e impressão de anúncios automatizados.

local http = require('app/shared/utils/ncluahttp')
local logging = require('app/shared/utils/logging')
local json = require('app/shared/utils/json_new')
local util = require('app/shared/utils/util')



local RunnableVASTAdRequest = {
    ad_request_url = 'https://tv.springserve.com/vast/689370?w=1920&h=1080&cb={{CACHEBUSTER}}',
    user_agent = 'Fellow-5.0/ZediaOS',
    pod_max_dur = 120,
    pod_ad_slots = 4,
    device_id = 'ecd8528d-4f04-4145-91a6-afad4fb2beed',
    ip = '162.238.217.18',
    proxy_url = 'http://127.0.0.1:8082/?destination='

}

------------------- // Analytics \\ --------------------

function RunnableVASTAdRequest:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---------------------------- // AdRequest Functions \\ --------------------------------

function RunnableVASTAdRequest:start()
    self:send_ad_request()
end

function RunnableVASTAdRequest:send_ad_request()
    local query = '&ip=' .. self.ip ..
    '&ua=' .. self.user_agent ..
    '&pod_max_dur=' .. self.pod_max_dur ..
    '&pod_ad_slots=' .. self.pod_ad_slots ..
    '&did=' .. self.device_id ..
    '&url=www.zedia.com.br'
-- self.ad_request_url .. query
    http.request(
        self.proxy_url .. 'https://text.npr.org/',
        function(header, body) self:ad_request_callback(header, body) end,
        "GET"
    )

    logging.network_request(self.proxy_url .. self.ad_request_url .. query)
end

function RunnableVASTAdRequest:ad_request_callback(header, body)
   logging.warning('[VAST HEADER]: \n' .. header)
   logging.warning('[VAST BODY]: \n' .. body)
end


local P = {}
P.RunnableVASTAdRequest = RunnableVASTAdRequest

return P;

