local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')

local SeasonAndDatesElement = {}

SeasonAndDatesElement.div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 0,
    g = 0,
    b = 0,
    a = 255,
    hover = {
      r = 0,
      g = 0,
      b = 0,
      a = 255
    }
  },
  text_color = {
    r = 0,
    g = 0,
    b = 0,
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


SeasonAndDatesElement.element_image = Image:new({
  parent = SeasonAndDatesElement,
  position = {
    x = 25,
    y = 500
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'season_and_dates_element'
})



function SeasonAndDatesElement:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  Render.image(SeasonAndDatesElement.element_image)
  return o
end

local P = {}
P.SeasonAndDatesElement = SeasonAndDatesElement

return P;
