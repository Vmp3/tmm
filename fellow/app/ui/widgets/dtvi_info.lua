local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')

local DTVi_checker = {
  tries = 0,
  div_style = {},
  div = {},
  new = function(self) end,
  render = function(self) end,
}

DTVi_checker.div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 255,
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

DTVi_checker.div = Div:new({
  position= {
    x = 0,
    y = 0
  },
  size = {
    width = 10,
    height = 10
  },
  styles = DTVi_checker.div_style,
  text = ''
})

function DTVi_checker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function DTVi_checker:render()
  Render.div(self.div)
  Render.flush()
end

function DTVi_checker:init_check_handler(core)
  if core then
    self:new({})
    self:render()
    if self.tries < 3 then
      core:timer(5000,
        function()
        local network_connectivity = core.capability_internet
        self:change_color_by_status(core, network_connectivity)
        end
      )
    end
  end
end

function DTVi_checker:change_color_by_status(core, status)
  if not status then
    local status_false = {
      r = 0,
      g = 0,
      b = 255,
      a = 50
    }
    self.div.styles.background_color = status_false
    self.tries = self.tries + 1
    self:init_check_handler(core)
  else
    local status_positive = {
      r = 0,
      g = 255,
      b = 0,
      a = 50
    }
    self.div.styles.background_color = status_positive
  end
  self:render()
  core:timer(15000, function() self:clear() end)
end

function DTVi_checker:clear()
  Render.clear()
end

local P = {}
P.DTVi_checker = DTVi_checker

return P;


