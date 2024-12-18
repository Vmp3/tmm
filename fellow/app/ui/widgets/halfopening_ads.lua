local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')

local HalfOpeningAds = {
  visibility = false
}

HalfOpeningAds.div_style = Style:new({
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
    top = 10,
    bottom = 0,
    left = 0,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

HalfOpeningAds.upper_space_1 = Div:new({
  position= {
    x = 643,
    y = 560
  },
  size = {
    width = 310,
    height = 25
  },
  styles = HalfOpeningAds.div_style,
  text = 'REPAGINANDO'
})

HalfOpeningAds.upper_space_2 = Div:new({
  position= {
    x = 957,
    y = 560
  },
  size = {
    width = 310,
    height = 25
  },
  styles = HalfOpeningAds.div_style,
  text = 'ANÚNCIO INTERATIVO'
})

HalfOpeningAds.lower_space_1 = Div:new({
  parent = 'halfopen',
  is_focused = false,
  position= {
    x = 643,
    y = 586
  },
  size = {
    width = 310,
    height = 124
  },
  styles = HalfOpeningAds.div_style,
  text = ''
})

HalfOpeningAds.lower_space_2 = Div:new({
  parent = 'halfopen',
  is_focused = false,
  position= {
    x = 957,
    y = 586
  },
  size = {
    width = 310,
    height = 124
  },
  styles = HalfOpeningAds.div_style,
  text = ''
})

HalfOpeningAds.opening_image_1 = Image:new({
  parent = HalfOpeningAds.lower_space_1,
  is_focused = false,
  position = {
    x = 643,
    y = 586,
  },
  path = 'local/assets/',
  extension = '.png',
  file_name = 'halfopen_1'
})

HalfOpeningAds.opening_image_2 = Image:new({
  parent = HalfOpeningAds.lower_space_2,
  is_focused = false,
  position = {
    x = 957,
    y = 586,
  },
  path = 'local/assets/',
  extension = '.png',
  file_name = 'halfopen_2'
})

function HalfOpeningAds:set_visibility(visibility)
  self.visibility = visibility
end


function HalfOpeningAds:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if self.visibility then
    Render.div(HalfOpeningAds.upper_space_1)
    Render.div(HalfOpeningAds.upper_space_2)
    Render.div(HalfOpeningAds.lower_space_1)
    Render.div(HalfOpeningAds.lower_space_2)
    Render.image(HalfOpeningAds.opening_image_1)
    Render.image(HalfOpeningAds.opening_image_2)
    Render.text(HalfOpeningAds.upper_space_1)
    Render.text(HalfOpeningAds.upper_space_2)
  end
  return o
end

local P = {}
P.HalfOpeningAds = HalfOpeningAds

return P;
