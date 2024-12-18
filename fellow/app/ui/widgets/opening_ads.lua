local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')

local OpeningAds = {
  visibility = false
}

OpeningAds.div_style = Style:new({
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
    left = 25,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

OpeningAds.upper_space = Div:new({
  position= {
    x = 644,
    y = 560
  },
  size = {
    width = 626,
    height = 25
  },
  styles = OpeningAds.div_style,
  text = 'ANÚNCIO INTERATIVO'
})

OpeningAds.lower_space = Div:new({
  parent = 'opening',
  is_focused = false,
  position= {
    x = 644,
    y = 586
  },
  size = {
    width = 626,
    height = 124
  },
  styles = OpeningAds.div_style,
  text = ''
})

OpeningAds.opening_image = Image:new({
  parent = OpeningAds.lower_space,
  is_focused = true,
  position = {
    x = 644,
    y = 586,
  },
  path = 'local/assets/',
  extension = '.png',
  file_name = 'opening'
})

function OpeningAds:set_visibility(visibility)
  self.visibility = visibility
end


function OpeningAds:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if self.visibility then
    Render.div(OpeningAds.upper_space)
    Render.div(OpeningAds.lower_space)
    Render.image(OpeningAds.opening_image)
    Render.text(OpeningAds.upper_space)
  end
  return o
end

local P = {}
P.OpeningAds = OpeningAds

return P;
