local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')

local Background = {}

Background.opening_solid_bg_style = Style:new({
  background = 'fill',
  background_color = {
    r = 44,
    g = 41,
    b = 46,
    a = 255,
  },
  focus = {
    border = {
      r = 255,
      g = 255,
      b = 255,
      a = 255
    },
    background = {
      r = 0,
      g = 0,
      b = 0,
      a = 0,
    }
  },
  text_color = {
    r = 159,
    g = 149,
    b = 163,
    a = 255
  },
  padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

Background.opening_lower_space_style = Style:new({
  background = 'fill',
  background_color = {
    r = 115,
    g = 75,
    b = 226,
    a = 255,
  },
  focus = {
    border = {
      r = 255,
      g = 255,
      b = 255,
      a = 255
    },
    background = {
      r = 0,
      g = 0,
      b = 0,
      a = 0,
    }
  },
  text_color = {
    r = 159,
    g = 149,
    b = 163,
    a = 255
  },
  padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

function Background:load_opening_bg()

  Background.opening_solid_bg = Div:new({
    parent = 'opening',
    is_focused = false,
    position= {
      x = 0,
      y = 560
    },
    size = {
      width = 1280,
      height = 150
    },
    styles = Background.opening_solid_bg_style,
    text = ''
  })

  Background.opening_lower_space = Div:new({
    parent = 'opening',
    is_focused = false,
    position= {
      x = 0,
      y = 710
    },
    size = {
      width = 1280,
      height = 10
    },
    styles = Background.opening_lower_space_style,
    text = ''
  })

  Render.div(Background.opening_solid_bg)
  Render.div(Background.opening_lower_space)
end


function Background:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local P = {}
P.Background = Background

return P;