local Style = {
  background = nil, --fill or frame
  background_color = {
    r = 0,
    g = 0,
    b = 0,
    a = 0,
  },
  focus = {
    border = {
      r = 0,
      g = 0,
      b = 0,
      a = 0
    },
    background = {
      r = 0,
      g = 0,
      b = 0,
      a = 0,
    }
  },
  text_color = {
    r = 0,
    g = 0,
    b = 0,
    a = 0,
    focus = {
      r = 0,
      g = 0,
      b = 0,
      a = 0
    }
  },
  padding = {
    x = 0,
    y = 0,
    top = 0,
    bottom = 0,
    left = 0,
    right = 0
  },
  font_family = nil, -- usually tiresias font
  text_size = 0, -- number in pixels (?)
  text_align = nil, -- left, center, right
}

function Style:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local P = {}
P.Style = Style

return P;
