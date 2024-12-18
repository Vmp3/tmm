local logging = {}
local event = event
--logging.log = ''
--function logging.read_history()
--function logging.clear_history()
--function logging.read_and_clear_history()
logging.level = {
    debug = true,
    info = true,
    warning = true,
    error = true,
    counter = true,
    network = true,
    callback = true,
    table = true,
    event = true,
    core = nil,
}

local function milliseconds_to_hhmmss(milliseconds)
  -- Calculate the hours, minutes, and seconds
  local seconds = math.floor(milliseconds / 1000)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  seconds = seconds % 60

  -- Format the result as HH:MM:SS
  return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function logging.inject_core(core)
    local new_core = core or {
        debug_mode = true
    }
    logging.core = new_core
end

function logging.info(text)
    if not text then return end
    if logging.level.info and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'INFO         | ' .. tostring(text))
    end
end

function logging.table(text)
    if not text then return end
    if logging.level.table and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'TABLE        | ' .. tostring(text))
    end
end

function logging.event(text)
    if not text then return end
    if logging.level.event and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'EVENT        | ' .. tostring(text))
    end
end

function logging.warning(text)
    if not text then return end
    if logging.level.warning and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'WARNING      | ' .. tostring(text))
    end
end

function logging.counter(text)
    if not text then return end
    if logging.level.counter and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'COUNTING     | ' .. tostring(text))
    end
end

function logging.network_request(text)
    if not text then return end
    if logging.level.network and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'NETWORK CALL | ' .. tostring(text))
    end
end

function logging.test(...)
    if logging.level.network and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'TEST | ' .. tostring(...))
    end
end

function logging.network_error(text)
    if not text then return end
    if logging.level.network and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'NETWORK ERROR | ' .. tostring(text))
    end
end

function logging.network_disconnect(text)
    if not text then return end
    if logging.level.network and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'NETWORK DISCONNECTED | ' .. tostring(text))
    end
end

function logging.network_connect(text)
    if not text then return end
    if logging.level.network and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'NETWORK CONNECTED | ' .. tostring(text))
    end
end

function logging.callback(text)
    if not text then return end
    if logging.level.callback and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'CALLBACK     | ' .. tostring(text))
    end
end

function logging.error(text)
    if not text then return end
    if logging.level.error and logging.core.debug_mode then
        print(milliseconds_to_hhmmss(event.uptime()) .. ' - ' .. 'ERROR        | ' .. tostring(text))
    end
end


-- every 30s, send all_log to the server and clear all_log
return logging
