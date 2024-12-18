local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')

local ChannelInfo = {}

 ChannelInfo.div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 44,
    g = 41,
    b = 46,
    a = 255,
    hover = {
      r = 255,
      g = 255,
      b = 255,
      a = 255
    }
  },
  text_color = {
    r = 159,
    g = 149,
    b = 163,
    a = 255
  },
  padding = {
    top = 10,
    bottom = 0,
    left = 25,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

ChannelInfo.lower_div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 44,
    g = 41,
    b = 46,
    a = 255,
    hover = {
      r = 255,
      g = 255,
      b = 255,
      a = 255
    }
  },
  text_color = {
    r = 255,
    g = 255,
    b = 255,
    a = 255
  },
  padding = {
    top = 10,
    bottom = 0,
    left = 25,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 15, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

ChannelInfo.upper_space = Div:new({
  parent = ChannelInfo,
  position= {
    x = 15,
    y = 560
  },
  size = {
    width = 308,
    height = 25
  },
  styles = ChannelInfo.div_style,
  text = 'ASSISTINDO AGORA'
})

ChannelInfo.lower_space = Div:new({
  parent = ChannelInfo,
  position= {
    x = 15,
    y = 586
  },
  size = {
    width = 308,
    height = 124
  },
  styles = ChannelInfo.lower_div_style,
  title = '',
  text = ''
})

ChannelInfo.channel_live = Image:new({
  parent = ChannelInfo.lower_space,
  position = {
    x = ChannelInfo.lower_space.position.x + (ChannelInfo.div_style.padding.left / 2),
    y = ChannelInfo.lower_space.position.y + ((ChannelInfo.lower_space.size.height - 32) / 2),
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'live'
})



function ChannelInfo:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  Render.div(ChannelInfo.upper_space)
  Render.div(ChannelInfo.lower_space)
  Render.text(ChannelInfo.upper_space)
  Render.image(ChannelInfo.channel_live)
  Render.title_and_text(ChannelInfo.lower_space)
  return o
end

local P = {}
P.ChannelInfo = ChannelInfo

return P;
