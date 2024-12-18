
local oo = require('app/shared/utils/oo')

local Image = oo.image()

Image = {
  parent = nil,
  is_focused = false,
  position = {
    x = 0,
    y = 0
  },
  path = nil,
  extension = nil,
  file_name = nil
}

function Image:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


return Image