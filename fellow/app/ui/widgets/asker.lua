local Div = require ('app/ui/components/div')
local Button = require ('app/ui/components/button')
local Style = require('app/ui/styles/styles').Style
local Render = require('app/shared/utils/render')
local logging = require('app/shared/utils/logging')
local http = require('app/shared/utils/ncluahttp')
local util = require('app/shared/utils/util')

local Asker = {
  visibility = false,
  is_option_selected = false,
  option_selected = 0,
  option_selected_slug = 'exit',
  poll_id = nil,
  poll_key = nil,
  poll_timestamp = nil,
  div_style = nil,
  button_style = nil,
  question_style = nil,
  body = nil, --main div
  header_div = nil, -- header div and text
  question_div = nil, -- question div and text
  nav_helper_div = nil, -- nav helper div and text
  options_div = nil, -- options div
  options = {}, -- option buttons
  footer_div = nil, -- footer div [contains confirm and exit buttons]
  confirm_button = nil, -- confirm button and text
  exit_button = nil, -- exit button and text
  next_poll = nil -- queue pool of polls
}

------------------------ // UI \\ --------------------------

------------------------ // STYLES \\ --------------------------

Asker.div_style = Style:new({
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
    top = 15,
    bottom = 0,
    left = 15,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

Asker.button_style = Style:new({
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
    top = 15,
    bottom = 0,
    left = 15,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 9, -- number in pixels (?)
  text_align = 'center', -- left, center, right TODO
})

Asker.question_style = Style:new({
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
    r = 255,
    g = 255,
    b = 255,
    a = 255
  },
  padding = {
    top = 15,
    bottom = 0,
    left = 15,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 14, -- number in pixels (?)
  text_align = 'left', -- left, center, right TODO
})

Asker.option_style = Style:new({
  background = 'fill',
  background_color = {
    r = 114,
    g = 109,
    b = 116,
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
      r = 114,
      g = 109,
      b = 116,
      a = 255,
    }
  },
  text_color = {
    r = 255,
    g = 255,
    b = 255,
    a = 255
  },
  padding = {
    top = 0,
    bottom = 0,
    left = 10,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 12, -- number in pixels (?)
  text_align = 'left', -- left, center, right TODO
})

Asker.confirmed_style = Style:new({
  background = 'fill',
  background_color = {
    r = 1,
    g = 207,
    b = 164,
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
      r = 1,
      g = 207,
      b = 164,
      a = 255,
    }
  },
  text_color = {
    r = 255,
    g = 255,
    b = 255,
    a = 255
  },
  padding = {
    top = 0,
    bottom = 0,
    left = 10,
    right = 0
  },
  font_family = 'tiresias', -- usually tiresias font
  text_size = 12, -- number in pixels (?)
  text_align = 'left', -- left, center, right TODO
})

Asker.confirm_button_style = Style:new({
  background = 'fill',
  background_color = {
    r = 71,
    g = 63,
    b = 74,
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
    r = 255,
    g = 255,
    b = 255,
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
  text_align = 'left', -- left, center, right TODO
})

Asker.exit_button_style = Style:new({
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
    r = 255,
    g = 255,
    b = 255,
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
  text_align = 'left', -- left, center, right TODO
})

------ // DIVS \\ ------

Asker.body = Div:new({
  position = {
    x = 1012,
    y = 15
  },
  size = {
    width = 253,
    height = 370
  },
  styles = Asker.div_style,
  text = ''
})

Asker.header_div = Div:new({
  position = {
    x = 1012,
    y = 15
  },
  size = {
    width = 253,
    height = 35
  },
  styles = Asker.div_style,
  text = 'number of askers..'
})

Asker.question_div = Div:new({
  parent = Asker.body,
  position= {
    x = Asker.body.position.x,
    y = Asker.body.position.y + Asker.header_div.size.height
  },
  size = {
    width = 253,
    height = 176
  },
  styles = Asker.question_style,
  text = 'Did this pool load??'
})

Asker.nav_helper_div = Div:new({
  parent = Asker.body,
  position= {
    x = Asker.body.position.x,
    y = Asker.question_div.position.y + Asker.question_div.size.height
  },
  size = {
    width = 253,
    height = 40
  },
  styles = Asker.div_style,
  text = 'Use o controle remoto para selecionar sua resposta'
})

Asker.options_div = Div:new({
  parent = Asker.body,
  position= {
    x = Asker.body.position.x,
    y = Asker.nav_helper_div.position.y + Asker.nav_helper_div.size.height
  },
  size = {
    width = 253,
    height = 10
  },
  styles = Asker.div_style,
  text = '??'
})

Asker.footer_div = Div:new({
  parent = Asker.body,
  position= {
    x = Asker.body.position.x,
    y = Asker.options_div.position.y + (Asker.options_div.size.height)
  },
  size = {
    width = 253,
    height = 70
  },
  styles = Asker.div_style,
  text = ''
})

Asker.thanks_div = Div:new({
  position= {
    x = Asker.body.position.x,
    y = Asker.body.position.y
  },
  size = {
    width = 253,
    height = 100
  },
  styles = Asker.div_style,
  text = ''
})

------ // BUTTONS \\ ------

Asker.confirm_button = Button:new({
  parent = Asker.footer_div,
  position= {
    x = Asker.footer_div.position.x + 15,
    y = Asker.footer_div.position.y + (Asker.footer_div.size.height - 40)
  },
  size = {
    width = 100,
    height = 25
  },
  styles = Asker.confirm_button_style,
  text = 'CONFIRMAR'
})

Asker.exit_button = Button:new({
  parent = Asker.footer_div,
  position= {
    x = (Asker.footer_div.position.x + Asker.confirm_button.size.width + 37),
    y = Asker.footer_div.position.y + (Asker.footer_div.size.height - 40)
  },
  size = {
    width = 100,
    height = 25
  },
  styles = Asker.exit_button_style,
  text = 'NÃO, OBRIGADO'
})

------------------------ // FUNCTIONS \\ --------------------------

function Asker:set_options(t)
  local index = 1
  local options = t or {}
  
  self.options = {}

  for k, v in pairs(options) do
    local option_text = self:firstToUpper(v.option)

    self.options[k] = Button:new({
      parent = self.options_div,
      size = {
        width = 222,
        height = 31
      },
      styles = self.option_style,
      text = option_text,
      slug = v.slug
    })
  end

  self.options[1].is_focused = true
end

function Asker:set_options_position()
  for k, _ in pairs(self.options) do
    if (k == 1) then
      self.options[k].position = {
        x = self.options_div.position.x + 15,
        y = self.options_div.position.y + 15
      }
    else
      self.options[k].position = {
        x = self.options_div.position.x + 15,
        y = self.options[k-1].position.y + 45
      }
    end
  end
end

function Asker:set_question_number(n, total)
  if total == 1 then
    self.header_div.text = 'ENQUETE'
  else
    local current = tostring(n)
    local amount = tostring(total)
    self.header_div.text = 'ENQUETE ('..current..' de '..amount..')'
  end
end

function Asker:set_question(q)
  if not q then q = "" end
  self.question_div.text = self:firstToUpper(q)
end

function Asker:set_next_poll(poll)
  local order = 2
  poll.next_poll = self.next_poll
  self.next_poll = poll

  -- reorder polls
  local queue = self.next_poll
  while queue do
    queue.order = order
    queue = queue.next_poll
    order = order + 1
  end
end

function Asker:has_next_poll()
  return self.next_poll
end

function Asker:get_next_poll()
  local questions = 0
  local order = self.next_poll.order
  local queue = self.next_poll
  local poll = self.next_poll

  -- count total of polls
  while queue do
    questions = queue.order
    queue = queue.next_poll
  end

  -- unqeue
  self.next_poll = poll.next_poll
  poll.next_poll = nil
  poll.order = nil

  return order, questions, poll
end

function Asker:clear_next_polls()
  local queue = self.next_poll
  local poll = nil
  while queue do
    poll = queue
    queue = queue.next_poll
    poll.next_poll = nil
  end
  self.next_poll = nil
end

function Asker:set_visibility(visibility)
  self.visibility = visibility
end

function Asker:set_selected_button(button, position)

  for k, v in pairs(self.options) do
    v.styles = self.option_style
  end

  button.styles = self.confirmed_style
  button.is_focused = false

  self.confirm_button.is_focused = true
  self.is_option_selected = true
  self.option_selected = position
  self.option_selected_slug = button.slug

  Render.div(self.confirm_button)
  Render.center_text(self.confirm_button)
  Render.div(button)
  Render.left_centered_text(button)
  Render.flush()
end

function Asker:render()
  self.confirm_button.is_focused = false

  local question_height = Render.get_text_total_height(self.question_div) + 14

  self.question_div.size.height = question_height
  local body = self.body
  local header_div = self.header_div
  local question_div = self.question_div
  local nav_helper_div = self.nav_helper_div
  local options_div = self.options_div
  local footer_div = self.footer_div
  local confirm_button = self.confirm_button
  local exit_button = self.exit_button

  self.nav_helper_div.position.y = self.question_div.position.y + question_height
  self.options_div.position.y = self.nav_helper_div.position.y + self.nav_helper_div.size.height
  self:set_options_position()
  self.footer_div.position.y = self.options[#self.options].position.y + self.options[#self.options].size.height
  self.confirm_button.position.y = self.footer_div.position.y + (self.footer_div.size.height - 40)
  self.exit_button.position.y = self.confirm_button.position.y
  self.body.size.height = self.footer_div.position.y + self.footer_div.size.height

  Render.div(body)
  Render.div(header_div)
  Render.div(question_div)
  Render.div(nav_helper_div)
  Render.div(options_div)
  Render.div(footer_div)
  Render.div(confirm_button)
  Render.div(exit_button)



  for _, v in pairs(self.options) do
    Render.div(v)
    Render.left_centered_text(v)
  end

  Render.text(self.header_div)
  Render.left_broken_text(self.question_div)
  Render.left_broken_text(self.nav_helper_div)
  Render.center_text(self.confirm_button)
  Render.center_text(self.exit_button)

  Render.flush()
end

function Asker:load_thanks()

  Render.clear()

  Render.div(self.thanks_div)
  Render.div(self.header_div)
  Render.div(self.question_div)

  self.question_div.text = "Obrigado pela sua participação!"
  Render.text(self.header_div)
  Render.left_broken_text(self.question_div)

  Render.flush()
end

function Asker:load_next()

  Render.clear()

  Render.div(self.thanks_div)
  Render.div(self.header_div)
  Render.div(self.question_div)

  self.question_div.text = "Carregando próxima pergunta..."
  Render.text(self.header_div)
  Render.left_broken_text(self.question_div)

  Render.flush()
end

function Asker:load_goodbye()

  Render.clear()

  local question_height = Render.get_text_total_height(self.question_div) + 50

  self.question_div.size.height = question_height

  Render.div(self.thanks_div)
  Render.div(self.header_div)
  Render.div(self.question_div)

  self.question_div.text = "Até a próxima!"
  Render.text(self.header_div)
  Render.text(self.question_div)

  Render.flush()
end

function Asker:options_length()
  return #self.options
end

function Asker:set_button_focus_up(Interaction)
  local options_length = self:options_length()
  local swipe_length =  options_length + 1
  if Interaction.cursor_current_position_y > 1 then
    Interaction:move_cursor(0, -1)
  end

  if self.is_option_selected then
    Interaction:set_y_pos(options_length)
    self:reset_states_and_render()
  end

  local current_button = self.options[Interaction.cursor_current_position_y] or self.confirm_button
  local last_button = self.options[Interaction.cursor_current_position_y + 1] or self.exit_button
  local exit_button = self.exit_button

  if Interaction.cursor_current_position_y == swipe_length then
    last_button = self.exit_button
    current_button = self.options[Interaction.cursor_current_position_y + 1] or self.options[Interaction.cursor_current_position_y -1]
  elseif Interaction.cursor_current_position_y == options_length then
    last_button = self.options[Interaction.cursor_current_position_y - 1]
  end

  current_button.is_focused = true
  last_button.is_focused = false
  exit_button.is_focused = false

  self:render()
end

function Asker:set_button_focus_down(Interaction)
  local options_length = self:options_length()
  local swipe_length = options_length + 1

  if self.is_option_selected then
    return
  end

  if Interaction.cursor_current_position_y < swipe_length then
    Interaction:move_cursor(0, 1)
  end

  local current_button = self.options[Interaction.cursor_current_position_y]
  local last_button = self.options[Interaction.cursor_current_position_y - 1]

  if Interaction.cursor_current_position_y == swipe_length then
    current_button = self.exit_button
  end

  current_button.is_focused = true
  last_button.is_focused = false

  self:render()
end

function Asker:poll_callback(ad_request, survey_id)
    ad_request.parent:timer(10, function()
        local callback_query = '/poll-callback/'
        .. '?pollId=' .. tostring(self.poll_id)
        .. '&sessionId=' .. tostring(ad_request.session_id)
        .. '&timestamp=' .. tostring(self.poll_timestamp)
        .. '&pollKey=' .. tostring(self.poll_key)
        .. '&connId=' .. tostring(ad_request.parent.session.conn_id)

        if survey_id then
          callback_query = callback_query..'&surveyId='..tostring(survey_id)
        end

        http.request(ad_request.ad_request_url .. callback_query,
            function(header, body)
                ad_request.parent:timer(100, function() self:poll_callback_response(header, body, ad_request) end)
                if ad_request.debug_mode then
                    logging.network_request(ad_request.ad_request_url .. callback_query)
                    logging.callback("[PollRequest] Poll callback sent to AdServer")
                end
            end,
            "GET"
        )
    end)
end

function Asker:poll_callback_response(header, body, ad_request)
    local lower_header = string.lower(header)
    logging.callback("[PollRequest] passando aqui")
    logging.callback(lower_header)
    if lower_header:find("200 ok") then
        ad_request.parent:timer(1800,
            function()
                ad_request.tracker:send_poll_answer(self.poll_id, self.option_selected_slug)
                if self.load_next_poll then
                  self.load_next_poll()
                  self.load_next_poll = nil
                end
            end
        )
        if ad_request.debug_mode then
            logging.callback('[AdRequest] response received, poll answer sent to Analytics Server')
        end
    else
        ad_request:reset_ad_state()
        self:reset_states()
    end


end

function Asker:reset_states_and_render()

  self.confirm_button.is_focused = false
  self.is_option_selected = false
  self.option_selected = 0

  for _, v in pairs(self.options) do
    v.styles = self.option_style
    v.is_focused = false
  end

  self:render()
end

function Asker:reset_states()
  self.survey_id = nil
  self.confirm_button.is_focused = false
  self.is_option_selected = false
  self.option_selected = 0
  self.exit_button.is_focused = false
  
  for k, v in pairs(self.options) do
    v.styles = self.option_style
    v.is_focused = false
    table.remove(self.options, k)
  end
end

function Asker:reset_states_and_interaction(Interaction, core, rf, ad_request)
  Interaction:set_y_pos(1)
  ad_request.poll_controller.poll_to_deliver = false
  core:timer(10, function() self:reset_states() rf(ad_request) end)
end

function Asker:firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end
------------------------ // INSTANCE \\ ----------------------------

function Asker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local P = {}
P.Asker = Asker

return P;
