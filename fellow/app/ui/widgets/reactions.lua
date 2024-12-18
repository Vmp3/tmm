
local Button = require('app/ui/components/button')
local Div = require ('app/ui/components/div')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')


local Reactions = {
  div_style = {},
  button_style = {},
  upper_space = {},
  reaction_1_button = {},
  reaction_2_button = {},
  reaction_3_button = {},
  reaction_4_button = {},
  reaction_1_focus = {},
  reaction_2_focus = {},
  reaction_3_focus = {},
  reaction_4_focus = {},
  reaction_1_image = {},
  reaction_2_image = {},
  reaction_3_image = {},
  reaction_4_image = {},
  new = function(self) end,
  render = function(self) end,
}

Reactions.div_style = Style:new({
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

Reactions.button_style = Style:new({
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
      r = 71,
      g = 63,
      b = 74,
      a = 255,
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

Reactions.upper_space = Div:new({
  position= {
    x = 329,
    y = 560
  },
  size = {
    width = 308,
    height = 25
  },
  styles = Reactions.button_style,
  text = 'ESTÁ GOSTANDO DO PROGRAMA?'
})


Reactions.reaction_1_button = Button:new({
  is_focused = false,
  position= {
    x = 329,
    y = 586
  },
  size = {
    width = 76,
    height = 124
  },
  styles = Reactions.button_style,
  text = '1'
})

Reactions.reaction_2_button = Button:new({
  is_focused = false,
  position= {
    x = 406,
    y = 586
  },
  size = {
    width = 76,
    height = 124
  },
  styles = Reactions.button_style,
  text = 'Reaction 2'
})

Reactions.reaction_3_button = Button:new({
  is_focused = false,
  position= {
    x = 483,
    y = 586
  },
  size = {
    width = 76,
    height = 124
  },
  styles = Reactions.button_style,
  text = 'Reaction 3'
})

Reactions.reaction_4_button = Button:new({
  is_focused = false,
  position= {
    x = 560,
    y = 586
  },
  size = {
    width = 77,
    height = 124
  },
  styles = Reactions.button_style,
  text = 'Reaction 4'
})


Reactions.reaction_1_image = Image:new({
  parent = Reactions.reaction_1_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_1'
})

Reactions.reaction_2_image = Image:new({
  parent = Reactions.reaction_2_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_2'
})

Reactions.reaction_3_image = Image:new({
  parent = Reactions.reaction_3_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_3'
})

Reactions.reaction_4_image = Image:new({
  parent = Reactions.reaction_4_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_4'
})

Reactions.reaction_1_focus = Div:new({
  parent = Reactions.reaction_1_button,
  is_focused = true,
  position = {
    x = 329,
    y = 586
  },
  size = {
    width = 76,
    height = 124
  },
  styles = Reactions.div_style,
  text = ''
})

Reactions.reaction_2_focus = Div:new({
  parent = Reactions.reaction_2_button,
  is_focused = true,
  position = {
    x = 406,
    y = 586
  },
  size = {
    width = 74,
    height = 122
  },
  styles = Reactions.div_style,
  text = ''
})

Reactions.reaction_3_focus = Div:new({
  parent = Reactions.reaction_3_button,
  is_focused = true,
  position = {
    x = 483,
    y = 586
  },
  size = {
    width = 72,
    height = 122
  },
  styles = Reactions.div_style,
  text = ''
})

Reactions.reaction_4_focus = Div:new({
  parent = Reactions.reaction_4_button,
  is_focused = true,
  position = {
    x = 560,
    y = 586
  },
  size = {
    width = 74,
    height = 122
  },
  styles = Reactions.div_style,
  text = ''
})

Reactions.reaction_1_big_image = Image:new({
  parent = Reactions.reaction_1_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_1_big'
})

Reactions.reaction_2_big_image = Image:new({
  parent = Reactions.reaction_2_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_2_big'
})

Reactions.reaction_3_big_image = Image:new({
  parent = Reactions.reaction_3_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_3_big'
})

Reactions.reaction_4_big_image = Image:new({
  parent = Reactions.reaction_4_button,
  position = {
    x = 148,
    y = 631,
  },
  path = 'local/system/',
  extension = '.png',
  file_name = 'reaction_4_big'
})

function Reactions:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self:render()
  return o
end

function Reactions:render()
  Render.div(self.upper_space)
  Render.text(self.upper_space)
  Render.div(self.reaction_1_button)
  Render.div(self.reaction_2_button)
  Render.div(self.reaction_3_button)
  Render.div(self.reaction_4_button)
  Render.center_image(self.reaction_1_image)
  Render.center_image(self.reaction_2_image)
  Render.center_image(self.reaction_3_image)
  Render.center_image(self.reaction_4_image)
  -- Render.cascade_render(o)
end


local P = {}
P.Reactions = Reactions

return P;


