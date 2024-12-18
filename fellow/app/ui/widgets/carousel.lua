local Div = require ('app/ui/components/div')
local Button = require ('app/ui/components/button')
local Image = require ('app/ui/components/image')
local Style = require ('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local Storage = require('app/storage/storage_api').StorageAPI
local logging = require('app/shared/utils/logging')
local util = require('app/shared/utils/util')

local Carousel = {
  visibility = false,
  body = nil, --main div
  options = {}, --clickable images/options
  options_divs = {}, --options div
  brand_space = {}, --brand image/not clickable
  maxpages = {}, --maxpage images
  background = {}, --background gradient
  is_maxpage_open = false
}

------------------------ // UI \\ --------------------------

Carousel.div_style = Style:new({
  background = 'fill',
  background_color = {
    r = 0,
    g = 0,
    b = 0,
    a = 1,
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
      a = 1,
    }
  },
  text_color = {
    r = 159,
    g = 149,
    b = 163,
    a = 255
  },
  padding = {
    top = 15,
    bottom = 0,
    left = 15,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

------ // DIVS \\ ------

Carousel.body = Div:new({
  position = {
    x = 10,
    y = 573
  },
  size = {
    width = 1260,
    height = 147
  },
  styles = Carousel.div_style
})

------------------------ // FUNCTIONS \\ --------------------------
function Carousel:set_brand_image(ad_name)
  local path = 'local/assets/'

  self.brand_space = Image:new({
      parent = self.body,
      path = path,
      file_name = ad_name,
      extension = '.png',
      position = {
        x = self.body.position.x,
        y = self.body.position.y,
      },
  })
end

function Carousel:set_options(ad_name)
  local options = {}
  local path = 'local/assets/'
  local i = 1

  while true do
    local image = self:check_image(ad_name, i)
    if image then
      options[i] = image
      i = i + 1
    else
      break
    end
  end

  for k, _ in ipairs(options) do
    self.options_divs[k] = Div:new({
      styles = Carousel.div_style
    })

    self.options[k] = Image:new({
      parent = self.options_divs[k],
      path = path,
      extension = '.png',
      file_name = ad_name .. '_' .. k
    })

    local maxpage_name = ad_name:gsub('carousel', 'maxpage')

    self.maxpages[k] = Image:new({
        parent = self,
        position = {
            x = 0,
            y = 0,
        },
        path = path,
        extension = '.png',
        file_name = maxpage_name .. '_' .. k
    })
  end

  self.background = Image:new({
        parent = self,
        position = {
            x = 0,
            y = 373,
        },
        path = '/local/system/',
        extension = '.png',
        file_name = 'carousel_bg'
    })

  self.options[1].is_focused = true
end

function Carousel:set_options_position()
  local img_width = 240
  local img_height = 220
  local img_height_diff = 73
  local grid_spacing = 15

  for k, _ in pairs(self.options) do
    if (k == 1) then
      self.options_divs[k].position = {
        x = self.body.position.x + img_width + grid_spacing,
        y = self.body.position.y - img_height_diff
      }

      self.options[k].position = {
        x = self.body.position.x + img_width + grid_spacing,
        y = self.body.position.y - img_height_diff
      }
    else
      self.options_divs[k].position = {
        x = self.options[k-1].position.x + img_width + grid_spacing,
        y = self.body.position.y,
      }

      self.options[k].position = {
        x = self.options[k-1].position.x + img_width + grid_spacing,
        y = self.body.position.y,
      }
    end

    self.options_divs[k].size = {
      width = img_width,
      height = img_height
    }
  end
end

function Carousel:set_visibility(visibility)
  self.visibility = visibility
end


function Carousel:render()
  Render.image(self.background)
  for _, v in ipairs(self.options) do
    Render.image(v)
  end
  Render.image(self.brand_space)

  Render.flush()
end

function Carousel:render_bg()

end

function Carousel:render_maxpage(page, ad_request)
  self.is_maxpage_open = true
  ad_request.parent:timer(1000, function()
    ad_request.tracker:send_ad_click_event('maxpage_' .. page)
  end)
  Render.image(self.maxpages[page])
  Render.flush()
end

function Carousel:options_length()
  return #self.options
end

function Carousel:set_button_focus_right(Interaction, ad_request)
  local img_height_diff = 73
  local options_length = self:options_length()
  if Interaction.cursor_current_position_x < options_length then
    Interaction:move_cursor(1, 0)
  else
    return
  end

  if self.is_maxpage_open then
    self:render_maxpage(Interaction.cursor_current_position_x, ad_request)
    return
  end

  local current_button = self.options[Interaction.cursor_current_position_x]
  local last_button = self.options[Interaction.cursor_current_position_x - 1]

  current_button.is_focused = true
  last_button.is_focused = false

  current_button.position.y = current_button.position.y - img_height_diff
  last_button.position.y = current_button.position.y + img_height_diff
  current_button.parent.position.y = current_button.position.y

  Render.clear()
  self:render()
end

function Carousel:set_button_focus_left(Interaction, ad_request)
  local img_height_diff = 73

  if Interaction.cursor_current_position_x > 1 then
    Interaction:move_cursor(-1, 0)
  else
    return
  end

  if self.is_maxpage_open then
    self:render_maxpage(Interaction.cursor_current_position_x, ad_request)
    return
  end

  local current_button = self.options[Interaction.cursor_current_position_x]
  local last_button = self.options[Interaction.cursor_current_position_x + 1]

  current_button.is_focused = true
  last_button.is_focused = false

  current_button.position.y = current_button.position.y - img_height_diff
  last_button.position.y = current_button.position.y + img_height_diff
  current_button.parent.position.y = current_button.position.y

  Render.clear()
  self:render()
end

function Carousel:check_image(ad_name, position)
  local _, result = pcall(function()
    local file_exists = Storage:file_check('local/assets/', ad_name .. '_' .. position, '.png')
    return file_exists
  end)
  return result
end

function Carousel:reset(Interaction)
  Interaction:set_x_pos(1)
  Render.clear()
  self.is_maxpage_open = false

  for k, v in ipairs(self.options) do
    if k == 1 then
      self.options[k].is_focused = true
    else
      self.options[k].is_focused = false
    end
  end

  self:set_options_position()
end

------------------------ // INSTANCE \\ ----------------------------

function Carousel:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local P = {}
P.Carousel = Carousel

return P;
