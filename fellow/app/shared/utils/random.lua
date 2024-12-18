local function string_to_number(str)
    local _str = tostring(str)
    local sum = 0
    for i = 1, #_str do
        local c = _str:sub(i,i)
        --print(c:byte())
        sum = sum + c:byte()
    end
    return sum
end

local function random_seed()

    local seed = os.time()
    if (settings and settings.system and settings.system.CPU) then
        seed = seed + string_to_number(settings.system.CPU)
    end
    if (settings and settings.system and settings.system.memory) then
        seed = seed + string_to_number(settings.system.memory)
    end
    if (settings and settings.system and settings.system.macAddress) then
        seed = seed + string_to_number(settings.system.macAddress)
    end
    if (settings and settings.system and settings.system.operatingSystem) then
        seed = seed + string_to_number(settings.system.operatingSystem)
    end
    if (settings and settings.system and settings.system.screenSize) then
        seed = seed + string_to_number(settings.system.screenSize)
    end
    if (settings and settings.system and settings.system.screenGraphicSize) then
        seed = seed + string_to_number(settings.system.screenGraphicSize)
    end
    if (settings and settings.system and settings.system.javaConfiguration) then
        seed = seed + string_to_number(settings.system.javaConfiguration)
    end
    if (settings and settings.system and settings.system.luaVersion) then
        seed = seed + string_to_number(settings.system.luaVersion)
    end
    if (settings and settings.system and settings.system.modelId) then
        seed = seed + string_to_number(settings.system.modelId)
    end
    if (settings and settings.system and settings.system.versionId) then
        seed = seed + string_to_number(settings.system.versionId)
    end
    if (settings and settings.system and settings.system.serialNumber) then
        seed = seed + string_to_number(settings.system.serialNumber)
    end

    if os.date then
        seed = seed + string_to_number(os.date())
    end
    if canvas and canvas.attrSize then
        local dx, dy = canvas:attrSize()
        seed = seed + dx + dy
    end
    if persistent and persistent.shared and persistent.shared.zadsUserID then
        seed = seed + string_to_number(persistent.shared.zadsUserID)
    end
    if event and event.uptime then
        seed = seed + event.uptime()
    end
    math.randomseed(seed)

    --These firsts call are a workaround for a well know problem: http://lua-users.org/lists/lua-l/2007-03/msg00564.html
    math.random()
    math.random()
    math.random()
    math.random()
    math.random()
end

return random_seed