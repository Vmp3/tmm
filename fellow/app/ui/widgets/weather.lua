local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')

local Weather = {
  weather_url = 'http://api.open-meteo.com/v1/forecast?'
}

Weather.div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 53,
    g = 43,
    b = 57,
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

Weather.lower_div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 53,
    g = 43,
    b = 57,
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

Weather.upper_space = Div:new({
  parent = Weather,
  position= {
    x = 10,
    y = 560
  },
  size = {
    width = 308,
    height = 25
  },
  styles = Weather.div_style,
  text = 'ASSISTINDO AGORA'
})

Weather.lower_space = Div:new({
  parent = Weather,
  position= {
    x = 10,
    y = 586
  },
  size = {
    width = 308,
    height = 124
  },
  styles = Weather.lower_div_style,
  text = ''
})

Weather.channel_live = Image:new({
  parent = Weather.lower_space,
  position = {
    x = Weather.lower_space.position.x + (Weather.div_style.padding.left / 2),
    y = Weather.lower_space.position.y + (Weather.div_style.padding.top * 1.5),
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'live'
})



function Weather:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  Render.div(Weather.upper_space)
  Render.div(Weather.lower_space)
  Render.center_text(Weather.upper_space)
  Render.image(Weather.channel_live)
  Render.text(Weather.lower_space)
  return o
end

local P = {}
P.Weather = Weather

return P;
