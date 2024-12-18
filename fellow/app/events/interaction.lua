local Home = require('app/ui/pages/home').Home
local OpeningAds = require ('app/ui/widgets/opening_ads').OpeningAds
local HalfOpeningAds = require ('app/ui/widgets/halfopening_ads').HalfOpeningAds
local Reactions = require('app/ui/widgets/reactions').Reactions
local Carousel = require('app/ui/widgets/carousel').Carousel
local storage = require('app/storage/storage_api').StorageAPI
local Render = require('app/shared/utils/render')
local opening_reactions = Reactions
local home = Home
local opening_ads = OpeningAds
local halfopening_ads = HalfOpeningAds
local logging = require('app/shared/utils/logging')

local Interaction = {
  cursor_current_position_x = 1,
  cursor_current_position_y = 1,
}

-------------------------- // SUPPORT FUNCTIONS \\ -------------------------

local function reset_ad_state(ad_request)
  Interaction:set_y_pos(1)
  Interaction:set_x_pos(1)
  ad_request:reset_ad_uptime()
  ad_request.poll_controller.poll_to_deliver = false
  ad_request.ad_controller.is_ad_running = false
  ad_request.ad_controller.active_ad = ''
  halfopening_ads.visibility = false
  opening_ads.visibility = false
  ad_request.asker:reset_states()

  Render.clear()
end

local function check_next_image(ad_request, cursor_position)
  local _, result = pcall(function()
    local file_exists = storage:file_check('local/assets/', ad_request.ad_controller.active_ad .. '_' .. cursor_position + 1, '.png')
    return file_exists
  end)
  return result
end

local function check_previous_image(ad_request, cursor_position)
  local _, result = pcall(function()
    local file_exists = storage:file_check('local/assets/', ad_request.ad_controller.active_ad .. '_' .. cursor_position - 1, '.png')
    return file_exists
  end)
  return result
end

function Interaction:move_cursor(dx, dy)
  self.cursor_current_position_x = self.cursor_current_position_x + dx
  self.cursor_current_position_y = self.cursor_current_position_y + dy
end

function Interaction:set_x_pos(px)
  self.cursor_current_position_x = px
end

function Interaction:set_y_pos(py)
  self.cursor_current_position_y = py
end

local widgets_swipe_buttons = {}

-------------------------- // OPENING \\ -------------------------

local function home_control(key, core)

  if core.prime_time_ads.ad_request.ad_controller.active_ad:find('halfopen') then
  widgets_swipe_buttons = {
      [1] = {name = 'heart_reaction', button = opening_reactions.reaction_1_button},
      [2] = {name = 'claps_reaction', button = opening_reactions.reaction_2_button},
      [3] = {name = 'astonished_reaction', button = opening_reactions.reaction_3_button},
      [4] = {name = 'thumb_down_reaction', button = opening_reactions.reaction_4_button},
      [5] = {name = 'halfopen_app', button = halfopening_ads.opening_image_1},
      [6] = {name = 'halfopen_ad', button = halfopening_ads.opening_image_2},
    }
  else
    widgets_swipe_buttons = {
      [1] = {name = 'heart_reaction', button = opening_reactions.reaction_1_button},
      [2] = {name = 'claps_reaction', button = opening_reactions.reaction_2_button},
      [3] = {name = 'astonished_reaction', button = opening_reactions.reaction_3_button},
      [4] = {name = 'thumb_down_reaction', button = opening_reactions.reaction_4_button},
      [5] = {name = 'opening_ad', button = opening_ads.opening_image}
    }
  end

  if key == 'BACKSPACE' or key == 'BACK' then

    for _, button in ipairs(widgets_swipe_buttons) do
      button.button.is_focused = false
    end

    if core.prime_time_ads.ad_request.poll_controller.poll_to_deliver then
      Render.clear()
      core.prime_time_ads.ad_request.ad_controller.active_ad = 'asker'
      core.prime_time_ads.ad_request.ad_controller.is_ad_running = true
      core.prime_time_ads.ad_request:load_asker_bg()
      core.prime_time_ads.ad_request:load_asker(true)
      return
    end

    reset_ad_state(core.prime_time_ads.ad_request)
  end

  if key == 'ENTER' then
    local current_button = widgets_swipe_buttons[Interaction.cursor_current_position_x]

    if current_button and core.prime_time_ads.ad_request.ad_controller.ad_uptime > 0 then
      if current_button.name == 'opening_ad' then
        core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('opening', 'maxpage')
        logging.info(core.prime_time_ads.ad_request.ad_controller.active_ad)
        core:timer(100,
          function()
            core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad)
          end
        )
        core:timer(4000,
          function()
            core.prime_time_ads.ad_request:click_callback('maxpage')
          end
        )
      elseif current_button.name == 'halfopen_app' then
        core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('halfopen', 'maxpage_1')
        logging.info(core.prime_time_ads.ad_request.ad_controller.active_ad .. ' clicked at halfopen_app')
        core:timer(100,
          function()
            core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad)
          end
        )
        core:timer(4000,
          function()
            core.prime_time_ads.ad_request:click_callback('repaginando_app')
          end
        )
      elseif current_button.name == 'halfopen_ad' then
        core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('halfopen', 'maxpage_2')
        logging.info(core.prime_time_ads.ad_request.ad_controller.active_ad .. ' clicked at halfopen_ad')
        core:timer(100,
          function()
            core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad)
          end
        )
        core:timer(4000,
          function()
            core.prime_time_ads.ad_request:click_callback('repaginando_ad')
          end
        )
      else
        core.prime_time_ads.ad_request.tracker:send_content_reaction_event(current_button.name)
        core.prime_time_ads.ad_request:load_thanks(Interaction.cursor_current_position_x)
        core.prime_time_ads.ad_request.ad_controller.ad_uptime = 0
      end
    end
  end

  if key == 'CURSOR_LEFT' then
    core.prime_time_ads.ad_request:reset_ad_uptime()
    if Interaction.cursor_current_position_x > 1 then
      Interaction:move_cursor(-1, 0)
    end

    local current_button = widgets_swipe_buttons[Interaction.cursor_current_position_x]
    local last_button = widgets_swipe_buttons[Interaction.cursor_current_position_x+1]

    current_button.button.is_focused = true
    last_button.button.is_focused = false

    home:new({})
    home:flush()
  end

  if key == 'CURSOR_RIGHT' then
    core.prime_time_ads.ad_request:reset_ad_uptime()
    local swipe_length = 4
    if core.prime_time_ads.ad_request.ad_controller.active_ad ~= 'opening' then
      swipe_length = #widgets_swipe_buttons
    end

    if Interaction.cursor_current_position_x < swipe_length then
      Interaction:move_cursor(1, 0)
    end

    local current_button = widgets_swipe_buttons[Interaction.cursor_current_position_x]
    local last_button = widgets_swipe_buttons[Interaction.cursor_current_position_x-1]

    current_button.button.is_focused = true
    last_button.button.is_focused = false

    home:new({})
    home:flush()
  end
end

---------------------------- // ASKER \\ -------------------------------

local function asker_control(key, core)
  local clicked_button = Interaction.cursor_current_position_y
  local options_length = core.prime_time_ads.ad_request.asker:options_length()
  if core.prime_time_ads.ad_request.asker.muttex_next_poll then return end
  if key == 'CURSOR_UP' then
    core.prime_time_ads.ad_request.asker:set_button_focus_up(Interaction)
    core.prime_time_ads.ad_request:reset_ad_uptime()
  end

 if key == 'CURSOR_DOWN' then
   core.prime_time_ads.ad_request.asker:set_button_focus_down(Interaction)
   core.prime_time_ads.ad_request:reset_ad_uptime()
 end

 if key == 'CURSOR_RIGHT' then
   if core.prime_time_ads.ad_request.asker.is_option_selected then
     Interaction:set_y_pos(options_length + 1)
     local current_button = core.prime_time_ads.ad_request.asker.exit_button
     current_button.is_focused = true
     core.prime_time_ads.ad_request.asker:reset_states_and_render()
   end
 end

 if key == 'ENTER' then
   core.prime_time_ads.ad_request:reset_ad_uptime()
   if core.prime_time_ads.ad_request.asker.is_option_selected then
    if core.prime_time_ads.ad_request.asker:has_next_poll() then
      local actual, questions, poll = core.prime_time_ads.ad_request.asker:get_next_poll()
      core.prime_time_ads.ad_request.asker.muttex_next_poll = true
      core.prime_time_ads.ad_request.asker:load_next()
      core.prime_time_ads.ad_request.asker:poll_callback(core.prime_time_ads.ad_request)
      core.prime_time_ads.ad_request.asker.load_next_poll = function() 
        core.prime_time_ads.ad_request.asker:set_options(poll.options)
        core.prime_time_ads.ad_request.asker:set_question(poll.question)
        core.prime_time_ads.ad_request.asker:set_question_number(actual, questions)
        core.prime_time_ads.ad_request.asker.poll_id = tostring(poll.id)
        core.prime_time_ads.ad_request.asker.poll_key = tostring(poll.pollKey)
        core.prime_time_ads.ad_request.asker:reset_states_and_render()
        core.prime_time_ads.ad_request.asker:set_button_focus_up(Interaction)
        core.prime_time_ads.ad_request.asker:render()
        core.prime_time_ads.ad_request.asker.muttex_next_poll = nil
      end
      core:timer(4000, function() core.prime_time_ads.ad_request.tracker:send_poll_impression(poll.id) end)
    else
      core.prime_time_ads.ad_request.asker:load_thanks()
      core.prime_time_ads.ad_request.ad_controller.active_ad = ''
      core.prime_time_ads.ad_request.asker:poll_callback(core.prime_time_ads.ad_request)
      core:timer(4000, function() reset_ad_state(core.prime_time_ads.ad_request) end)
    end
   else
     if clicked_button ~= options_length + 1 then
       core.prime_time_ads.ad_request.asker:set_selected_button(core.prime_time_ads.ad_request.asker.options[clicked_button], clicked_button)
     else
       core.prime_time_ads.ad_request.asker:load_goodbye()
       core.prime_time_ads.ad_request.asker:poll_callback(core.prime_time_ads.ad_request, core.prime_time_ads.ad_request.asker.survey_id)
       core.prime_time_ads.ad_request.ad_controller.active_ad = ''
       core:timer(4000, function()
        reset_ad_state(core.prime_time_ads.ad_request)
        core.prime_time_ads.ad_request.asker:clear_next_polls()
      end)
     end
   end
 end

 if key == 'BACKSPACE' or key == 'BACK' then
   core.prime_time_ads.ad_request.asker:clear_next_polls()
   core.prime_time_ads.ad_request.asker:load_goodbye()
   core.prime_time_ads.ad_request.asker:poll_callback(core.prime_time_ads.ad_request, core.prime_time_ads.ad_request.asker.survey_id)
   core.prime_time_ads.ad_request.ad_controller.active_ad = ''
   core:timer(4000, function() reset_ad_state(core.prime_time_ads.ad_request) end)
 end

end

---------------------------- // FLOAT \\ -------------------------------

local function float_control(key, core)

 if key == 'CURSOR_LEFT' then
   local result = check_previous_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_x)
   if result then
     Interaction:move_cursor(-1, 0)
     Render.clear()
     core.prime_time_ads.ad_request:load_float(core.prime_time_ads.ad_request.ad_controller.active_ad, Interaction.cursor_current_position_x)
   end
 end

 if key == 'CURSOR_RIGHT' then
   local result = check_next_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_x)
   if result then
     Interaction:move_cursor(1, 0)
     Render.clear()
     core.prime_time_ads.ad_request:load_float(core.prime_time_ads.ad_request.ad_controller.active_ad, Interaction.cursor_current_position_x)
   end
 end

 if key == 'ENTER' then
   core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('float', 'maxpage')
   core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad, 1)
   core:timer(4000,
     function()
       core.prime_time_ads.ad_request:click_callback('maxpage')
     end
   )
 end

 if key == 'BACKSPACE' or key == 'BACK' then
   reset_ad_state(core.prime_time_ads.ad_request)
 end
end

---------------------------- // SKYSCRAPER FULL \\ -------------------------------

local function skyscraper_control(key, core)
 if key == 'CURSOR_UP' then
   local result = check_previous_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_y)
   if result then
     Interaction:move_cursor(0, -1)
     core.prime_time_ads.ad_request:reset_ad_uptime()
     core.prime_time_ads.ad_request:load_skyscraper(core.prime_time_ads.ad_request.ad_controller.active_ad, Interaction.cursor_current_position_y)
   end
 end

 if key == 'CURSOR_DOWN' then
   local result = check_next_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_y)
   if result then
     Interaction:move_cursor(0, 1)
     core.prime_time_ads.ad_request:reset_ad_uptime()
     core.prime_time_ads.ad_request:load_skyscraper(core.prime_time_ads.ad_request.ad_controller.active_ad, Interaction.cursor_current_position_y)
   end
 end

 if key == 'ENTER' then
   local result = check_next_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_y)
   if result then
     core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('skcf', 'maxpage')
     core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad, 1)
     core:timer(4000,
       function()
         core.prime_time_ads.ad_request:click_callback('maxpage')
       end
     )
   else
     reset_ad_state(core.prime_time_ads.ad_request)
   end
 end

 if key == 'BACKSPACE' or key == 'BACK' then
   reset_ad_state(core.prime_time_ads.ad_request)
 end

end

---------------------------- // SKYSCRAPER HALF \\ -------------------------------

local function skyscraper_half_control(key, core)
  if key == 'CURSOR_UP' then
    local result = check_previous_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_y)
    if result then
      Interaction:move_cursor(0, -1)
      core.prime_time_ads.ad_request.ad_controller.ad_uptime = 0
      core.prime_time_ads.ad_request:load_skyscraper_half(core.prime_time_ads.ad_request.ad_controller.active_ad, Interaction.cursor_current_position_y)
    end
  end

  if key == 'CURSOR_DOWN' then
    local result = check_next_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_y)
    if result then
      Interaction:move_cursor(0, 1)
      core.prime_time_ads.ad_request:reset_ad_uptime()
      core.prime_time_ads.ad_request:load_skyscraper_half(core.prime_time_ads.ad_request.ad_controller.active_ad, Interaction.cursor_current_position_y)
    end
  end

  if key == 'ENTER' then
    local result = check_next_image(core.prime_time_ads.ad_request, Interaction.cursor_current_position_y)
    if result then
      core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('skch', 'maxpage')
      core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad, 1)
      core:timer(4000,
        function()
          core.prime_time_ads.ad_request:click_callback('maxpage')
        end
      )
    else
      reset_ad_state(core.prime_time_ads.ad_request)
    end
  end

  if key == 'BACKSPACE' or key == 'BACK' then
    reset_ad_state(core.prime_time_ads.ad_request)
  end

end

---------------------------- // SQUEEZE \\ -------------------------------

local function squeeze_control(key, core)
  if key == 'ENTER' then
    core.prime_time_ads.ad_request.ad_controller.active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad:gsub('squeeze', 'maxpage')

    core.prime_time_ads.ad_request:load_maxpage(core.prime_time_ads.ad_request.ad_controller.active_ad, 1)
    core:timer(4000,
      function()
        core.prime_time_ads.ad_request:click_callback('maxpage')
      end
    )
  end
  if key == 'BACKSPACE' or key == 'BACK' then
    event.post("out",
      {
        class = 'ncl',
        type = 'edit',
        command = 'setPropertyValue',
        nodeId = 'application',
        propertyId = 'upsize',
        value = '1'
      }
    )

    Render.clear()
    reset_ad_state(core.prime_time_ads.ad_request)
  end
end

---------------------------- // CAROUSEL \\ -------------------------------

local function carousel_control(key, core)
  if key == 'CURSOR_LEFT' then
    core.prime_time_ads.ad_request:reset_ad_uptime()
    Carousel:set_button_focus_left(Interaction, core.prime_time_ads.ad_request)
  end
  if key == 'CURSOR_RIGHT' then
    core.prime_time_ads.ad_request:reset_ad_uptime()
    Carousel:set_button_focus_right(Interaction, core.prime_time_ads.ad_request)
  end
  if key == 'ENTER' then
    core.prime_time_ads.ad_request:reset_ad_uptime()
    Carousel:render_maxpage(Interaction.cursor_current_position_x, core.prime_time_ads.ad_request)
  end
  if key == 'BACKSPACE' or key == 'BACK' then
    if Carousel.is_maxpage_open then
      Carousel:reset(Interaction)
      Carousel:render()
    else
      reset_ad_state(core.prime_time_ads.ad_request)
    end
  end
end

------------------------------ // MAXPAGE \\ ------------------------------

local function maxpage_control(key, core)
  if key == 'CURSOR_LEFT' then
  end
  if key == 'CURSOR_RIGHT' then
  end
  if key == 'ENTER' then
    -- LOAD PRODUCT PAGE
  end
  if key == 'BACKSPACE' or key == 'BACK' then
    event.post("out",
      {
        class = 'ncl',
        type = 'edit',
        command = 'setPropertyValue',
        nodeId = 'application',
        propertyId = 'upsize',
        value = '1'
      }
    )

    for _, button in ipairs(widgets_swipe_buttons) do
      button.button.is_focused = false
    end

    if core.prime_time_ads.ad_request.poll_controller.poll_to_deliver then
      core.prime_time_ads.ad_request.ad_controller.active_ad = 'asker'
      core.prime_time_ads.ad_request.ad_controller.is_ad_running = true
      core.prime_time_ads.ad_request:load_asker_bg()
      core.prime_time_ads.ad_request:load_asker(true)
      core.prime_time_ads.ad_request:interaction_check(60)
      return
    end

    reset_ad_state(core.prime_time_ads.ad_request)
   return
  end
end

---------------------------- // AD CONTROLLER \\ -------------------------------

local control_functions = {
  opening = home_control,
  halfopen = home_control,
  asker = asker_control,
  float = float_control,
  skcf = skyscraper_control,
  skch = skyscraper_half_control,
  squeeze = squeeze_control,
  carousel = carousel_control,
  maxpage = maxpage_control
}

local function ad_control(key, core)
  local active_ad = core.prime_time_ads.ad_request.ad_controller.active_ad
  for ad_format, control_func in pairs(control_functions) do
    if active_ad:find(ad_format) then
      control_func(key, core)
      return
    end
  end
end

------------ // INPUT CONTROLLER \\ -----------------------
function Interaction:control(key, core)
  if key == 'ENTER' and not core.prime_time_ads.ad_request.ad_controller.is_ad_running and core.prime_time_ads.ad_request.ad_controller.active_ad ~= 'loading' then --and core.session.widgets.home.is_active == 'true' and (core.session.widgets.home.mode == 'always' or core.session.widgets.home.mode == 'on_demand')
    core.prime_time_ads.ad_request.ad_controller.active_ad = 'loading'
    core.prime_time_ads.ad_request:send_ad_request('opening', true)
  end

  if key and core.prime_time_ads.ad_request.ad_controller.is_ad_running then
    ad_control(key, core)
  end
end

return Interaction
