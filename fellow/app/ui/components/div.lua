
local oo = require('app/shared/utils/oo')

local Div = oo.div()

Div = {
  parent = nil,
  text = nil,
  is_focused = false,
  position = {
    x = 0,
    y = 0
  },
  size = {
    width = 0,
    height = 0
  }
}

function Div:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


return Div