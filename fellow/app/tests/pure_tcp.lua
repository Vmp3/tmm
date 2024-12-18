local logging = require('app/shared/utils/logging')
local util = require('app/shared/utils/util')
local event = event

local Pure_TCP = {}
local host = '34.203.161.196'
local port = 80

function Pure_TCP:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local debug = false

function Pure_TCP:connect()

  local sent, error_message = event.post {
      class = 'tcp',
      type  = 'connect',
      host  = host,
      port  = port,
    }

  if debug then
    logging.network_request("Tentando conectar a ".. host .." pela porta " .. port)
    logging.info('[PureTCP] connect? ' .. tostring(sent))
    logging.error('[PureTCP] error: ' ..tostring(error_message))
  end
end

function Pure_TCP:handler(evt, debugger)
    if evt.class ~= 'tcp' then return end

    if evt.type == 'connect' and evt.host == host then
      local text = ''
      text = text .. 'evt_error: ' .. tostring(evt.error) .. ' ' .. 'evt_type: ' .. tostring(evt.type) .. ' ' .. 'evt_host: ' .. tostring(evt.host) .. ' '
      debugger:add_new_text(text)
      if debug then
        util.printable(evt)
        logging.info(evt.type)
        logging.error(evt.error)
      end
      return
    end

    if evt.type == 'disconnect' and evt.host == host then
      local text = ''
      text = text .. 'evt_error: ' .. tostring(evt.error) .. ' ' .. 'evt_type: ' .. tostring(evt.type) .. ' ' .. 'evt_host: ' .. tostring(evt.host) .. ' '
      debugger:add_new_text(text)
      if debug then
        logging.info(evt.type)
        logging.error(evt.error)
      end
      return
    end

    if evt.type == 'data' and evt.host == host then
      local text = ''
      text = text .. 'evt_error: ' .. tostring(evt.error) .. ' ' .. 'evt_type: ' .. tostring(evt.type) .. ' ' .. 'evt_host: ' .. tostring(evt.host) .. ' '
      debugger:add_new_text(text)
      if debug then
        logging.info(evt.type)
        logging.error(evt.error)
      end
      return
    end
end

---------------------------------
------- // Instance \\ -----------
local P = {}
P.Pure_TCP = Pure_TCP

return P;