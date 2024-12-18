local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local util = require('app/shared/utils/util')
local settings = settings

local Debugger = {
  div_style = {},
  div = {},
  new = function(self) end,
  render = function(self) end,
}

 function Debugger:createDebuggerString(text)
  local seed = 'debugger: | \n'
  if (settings and settings.system and settings.system.CPU) then
      seed = seed .. '| ' ..'system_CPU:' .. tostring(settings.system.CPU) .. ' | \n '
  end
  if (settings and settings.system and settings.system.memory) then
      seed = seed .. '| ' ..'system_memory:' .. tostring(settings.system.memory) .. ' | \n '
  end
  if (settings and settings.system and settings.system.macAddress) then
      seed = seed .. '| ' ..'system_macAddress:' .. tostring(settings.system.macAddress) .. ' | \n '
  end
  if (settings and settings.system and settings.system.operatingSystem) then
      seed = seed .. '| ' ..'system_OS:' .. tostring(settings.system.operatingSystem) .. ' | \n '
  end
  if (settings and settings.system and settings.system.screenSize) then
      seed = seed .. '| ' ..'system_ScreenSize:' .. tostring(settings.system.screenSize) .. ' | \n '
  end
  if (settings and settings.system and settings.system.screenGraphicSize) then
      seed = seed .. '| ' ..'system_ScreenGraphicSize:' .. tostring(settings.system.screenGraphicSize) .. ' | \n '
  end
  if (settings and settings.system and settings.system.luaVersion) then
      seed = seed .. '| ' ..'system_luaVersion' .. tostring(settings.system.luaVersion) .. ' | \n '
  end
  if (settings and settings.system and settings.system.modelId) then
      seed = seed .. '| ' ..'system_modelID:' .. tostring(settings.system.modelId) .. ' | \n '
  end
  if (settings and settings.system and settings.system.versionId) then
      seed = seed .. '| ' ..'system_versionID:' .. tostring(settings.system.versionId) .. ' | \n '
  end
  if (settings and settings.system and settings.system.serialNumber) then
      seed = seed .. '| ' ..'system_SN:' .. tostring(settings.system.serialNumber) .. ' | \n '
  end
  if persistent and persistent.shared and persistent.shared.zadsUserID then
      seed = seed .. '| ' ..'persistent_userID:' .. tostring(persistent.shared.zadsUserID) .. ' | \n '
  end
  if persistent and persistent.shared then
    seed = seed .. '| ' ..'persistent_sharedDate:' .. tostring(persistent.shared.zDate) .. ' | \n '
  end
  if canvas then
    local dx, dy = canvas:attrSize()
    seed = seed .. '| ' ..'Width:' .. dx .. ' | \n '
    seed = seed .. '| ' ..'Height:' .. dy .. ' | \n '
  end

  if settings and settings.system then
    if settings.system.language then
      seed = seed .. '| ' ..'Language:' .. tostring(settings.system.language) .. ' | \n '
    end
    if settings.system.caption then
      seed = seed .. '| ' ..'Caption:' .. tostring(settings.system.caption) .. ' | \n '
    end
    if settings.system.subtitle then
      seed = seed .. '| ' ..'Subtitle:' .. tostring(settings.system.subtitle) .. ' | \n '
    end
    if settings.system.audioType then
      seed = seed .. '| ' ..'Audio:' .. tostring(settings.system.audioType) .. ' | \n '
    end
    if settings.system.classNumber then
      seed = seed .. '| ' ..'Class:' .. tostring(settings.system.classNumber) .. ' | \n '
    end
    if settings.system.GingaNCL.version then
      seed = seed .. '| ' ..'Ginga' .. tostring(settings.system.GingaNCL.version) .. ' | \n '
    end
    if settings.system.makerId then
      seed = seed .. '| ' ..'Maker:' .. tostring(settings.system.makerId) .. ' | \n '
    end
    if settings.system.hasActiveNetwork then
      seed = seed .. '| ' ..'Network:' .. tostring(settings.system.hasActiveNetwork) .. ' | \n '
    end
    if settings.system.hasNetworkConnectivity then
      seed = seed .. '| ' ..'NetworkConnectivity:' .. tostring(settings.system.hasNetworkConnectivity) .. ' | \n '
    end
    if settings.system.maxNetworkBitRate then
      seed = seed .. '| ' ..'MaxNetworkBitRate:' .. tostring(settings.system.maxNetworkBitRate) .. ' | \n '
    end
    if settings.system.user then
      if settings.system.user.age then
        seed = seed .. '| ' ..'Age:' .. tostring(settings.system.user.age) .. ' | \n '
      end
      if settings.system.user.genre then
        seed = seed .. '| ' ..'Genre:' .. tostring(settings.system.user.genre) .. ' | \n '
      end
      if settings.system.user.location then
        seed = seed .. '| ' ..'Location:' .. tostring(settings.system.user.location) .. ' | \n '
      end
      if settings.system.user.name then
        seed = seed .. '| ' ..'Name:' .. tostring(settings.system.user.name) .. ' | \n '
      end
    end
    if settings.system.si then
      if settings.system.si.numberOfServices then
        seed = seed .. '| ' ..'Service:' .. tostring(settings.system.si.numberOfServices) .. ' | \n '
      end
      if settings.system.si.numberOfPartialServices then
        seed = seed .. '| ' ..'Partial:' .. tostring(settings.system.si.numberOfPartialServices) .. ' | \n '
      end
      if settings.system.si.channeNumber then
        seed = seed .. '| ' ..'channel_number:' .. tostring(settings.system.si.channeNumber) .. ' | \n '
      end
    end

    local full_settings = util.tableToString(settings.system)
    seed = seed .. '| ' ..'full_settings:' .. tostring(full_settings) .. ' | \n '
  end

  if text then
    seed = seed .. '| ' ..'text:' .. tostring(text) .. ' | \n '
  end

  self.div.text = seed
end

local px, py = 1280, 720

Debugger.div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 0,
    g = 0,
    b = 0,
    a = 50
  },
  padding = {
    top = 10,
    bottom = 0,
    left = 25,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 10, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

Debugger.div = Div:new({
  position= {
    x = px / 2,
    y = py / py
  },
  size = {
    width = px / 2,
    height = py
  },
  styles = Debugger.div_style,
  text = ''
})

function Debugger:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self:createDebuggerString()
  return o
end

function Debugger:add_new_text(text)
  local old_text = self.div.text
  local new_text = old_text .. ' | \n ' .. tostring(text)
  self.div.text = new_text
end

function Debugger:render()
  Render.div(self.div)
  util.paintBreakedString(px/2, px/2, 0, self.div.text)
  Render.flush()
end

local P = {}
P.Debugger = Debugger

return P;


