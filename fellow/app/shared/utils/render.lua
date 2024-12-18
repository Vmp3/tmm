local storage = require('app/storage/storage_api').StorageAPI
local logging = require('app/shared/utils/logging')
local util = require('app/shared/utils/util')
local math = require('math')

local Render = {}

function Render.center_text(o)
  canvas:attrFont(o.styles.font_family, o.styles.text_size)
  canvas:attrColor(o.styles.text_color.r, o.styles.text_color.g, o.styles.text_color.b, o.styles.text_color.a)
  local dx, dy = canvas:measureText(o.text)
  local text_padding_x = (o.size.width - dx) / 2
  local text_padding_y = (o.size.height - dy) / 2
  canvas:drawText(o.position.x + text_padding_x, o.position.y + text_padding_y, o.text)
end

function Render.title_and_text(o)
  local dx, dy = canvas:measureText(o.text)
  canvas:attrFont(o.styles.font_family, o.styles.text_size)
  canvas:attrColor(o.styles.text_color.r, o.styles.text_color.g, o.styles.text_color.b, o.styles.text_color.a)
  canvas:drawText(o.position.x + (o.styles.padding.left + 1), o.position.y + ((o.size.height - (dy * 3)) / 2), o.title)

  local div_dx, div_dy = o.size.width, o.size.height

  local reversed = ''
  local where_filter_string = ''
  local split_string = ''
  local normal_string = ''
  local string_len = ''
  local where_filter_next_string = 0
  local split_second_string = ''

  if dx >= div_dx then
    reversed = o.text:reverse()
    where_filter_string = reversed:find('%s+')
    split_string = reversed:sub(where_filter_string)
    normal_string = split_string:reverse()
    string_len = o.text:len()
    where_filter_next_string = string_len - where_filter_string + 2
    split_second_string = o.text:sub(where_filter_next_string)
    dx, dy = canvas:measureText(normal_string)
    canvas:drawText(o.position.x + (o.styles.padding.left + 1), o.position.y + o.styles.padding.top + dy, normal_string)
    canvas:drawText(o.position.x + (o.styles.padding.left + 1), o.position.y + o.styles.padding.top + dy + dy, split_second_string)
  else
    canvas:drawText(o.position.x + (o.styles.padding.left + 1),  o.position.y + ((o.size.height + (dy / 2)) / 2), o.text)
  end
end

function Render.left_broken_text(o)
  canvas:attrFont(o.styles.font_family, o.styles.text_size)
  local areaWidth = o.size.width
  local text = o.text
  local y = o.position.y
  local x = o.position.x
  local tw, th = canvas:measureText("a")
  local charsByLine = math.floor(areaWidth / tw)
  local textTable = util.breakString(text, charsByLine)

  if textTable ~= nil then
    for k, ln in pairs(textTable) do
      canvas:attrColor(o.styles.text_color.r, o.styles.text_color.g, o.styles.text_color.b, o.styles.text_color.a)
      canvas:drawText(x + o.styles.padding.left, y + o.styles.padding.top, ln)
      y = y + th
    end
  end
end

function Render.get_text_total_height(o)
    canvas:attrFont(o.styles.font_family, o.styles.text_size)
    local areaWidth = o.size.width
    local text = o.text
    local y = o.position.y
    local x = o.position.x
    local tw, th = canvas:measureText("a")
    local charsByLine = math.floor(areaWidth / tw)
    local textTable = util.breakString(text, charsByLine)

    if textTable ~= nil then
        local totalHeight = 0  -- Variable to store the total height of the text block

        for k, ln in pairs(textTable) do
            totalHeight = totalHeight + th  -- Accumulate the text height for each line
        end

        for k, ln in pairs(textTable) do
            y = y + th  -- Move to the next line without any extra spacing
        end

        return totalHeight  -- Return the calculated total height of the text block
    end

    return 0  -- Return 0 if there is no text or if an error occurred
end

function Render.button(o)
  local dx, dy = canvas:measureText(o.text)

  if dx >= o.size.width or dy >= o.size.height then
     repeat
        canvas:attrFont('tiresias', o.styles.text_size)
        o.styles.text_size = o.styles.text_size - 1
        dx, dy = canvas:measureText(o.text)
     until( dx < o.size.width )
  end
  if o.is_focused then
    Render.div_focus(o)
  else
    Render.div(o)
    Render.text(o)
  end
end

function Render.div(o)
  if o.is_focused then
  Render.div_focus(o)
  else
  canvas:attrColor(o.styles.background_color.r, o.styles.background_color.g, o.styles.background_color.b, o.styles.background_color.a)
  canvas:drawRect('fill', o.position.x, o.position.y, o.size.width, o.size.height)
  end
end

function Render.flush()
  canvas:flush()
end

function Render.cascade_render(o)
  for k, v in pairs(o) do
    if type(v) ~= "table" then
        return
    else
        if tostring(k):find('space') then
          print(tostring(k)..'='..tostring(v))
          Render.div(v)
          Render.center_text(v)
        elseif tostring(k):find('button') then
          print(tostring(k)..'='..tostring(v))
          Render.div(v)
        elseif tostring(k):find('image') then
          print(tostring(k)..'='..tostring(v))
          Render.image(v)
        elseif tostring(k):find('focus') then
          print(tostring(k)..'='..tostring(v))
          Render.div(v)
        end
    end
  end
end

function Render.text(o)
  canvas:attrFont('tiresias', o.styles.text_size)
  canvas:attrColor(o.styles.text_color.r, o.styles.text_color.g, o.styles.text_color.b, o.styles.text_color.a)
  canvas:drawText((o.position.x + o.styles.padding.left), (o.position.y + o.styles.padding.top), o.text)
end

function Render.left_centered_text(o)
  canvas:attrFont(o.styles.font_family, o.styles.text_size)
  local _, dy = canvas:measureText(o.text)
    local text_padding_y = (o.size.height - dy) / 2
    canvas:attrColor(o.styles.text_color.r, o.styles.text_color.g, o.styles.text_color.b, o.styles.text_color.a)
    canvas:drawText(o.position.x + o.styles.padding.left, o.position.y + text_padding_y, o.text)
end

function Render.div_focus(o)
  canvas:attrColor(o.styles.focus.background.r, o.styles.focus.background.g, o.styles.focus.background.b, o.styles.focus.background.a)
  canvas:drawRect('fill', o.position.x + 1, o.position.y + 1, o.size.width - 2, o.size.height - 2)
  canvas:attrColor(o.styles.focus.border.r, o.styles.focus.border.g, o.styles.focus.border.b, o.styles.focus.border.a)
  canvas:drawRect('frame', o.position.x + 1, o.position.y + 1, o.size.width - 2, o.size.height - 2)
end

function Render.image(o)

  -- check if file exists
  local image = storage:get_file(o.path, o.file_name, o.extension)
  -- if image doesn't exists, return.
  if image == nil then return end
  -- construct a new canvas with image path.
  local render_image = canvas:new(image)
  -- get image size
  local iw, ih = render_image:attrSize()
  -- get screen size
  local cw, ch = canvas:attrSize()

  -- if image path contains 'loading' and is_focused == true, then compose a canvas with a focused loading image
  if image:find('loading') and o.is_focused then
    Render.center_image(o)
    Render.image_focus(o, render_image)
  -- if image path ~= 'loading' and is_focused == true, then compose a canvas with a focused image
  elseif not image:find('loading') and o.is_focused then
    canvas:compose(o.position.x, o.position.y, render_image)
    Render.image_focus(o, render_image)
  elseif image:find('bottom') or image:find('float') then
  -- if image path contains 'bottom' (squeeze bottom image), then compose a canvas with bottom image, position x = 0, position y = screen height size - image height size
    canvas:compose(o.position.x, ch - ih, render_image)
  elseif image:find('side') then
  -- if image path contains 'side' (squeeze side image), then compose a canvas with side image, position x = screen width - image width, position y = 0
    canvas:compose(cw - iw, o.position.y, render_image)
  else
  -- if none of the conditions above matches, just compose the image using image object position x and y.
    canvas:compose(o.position.x, o.position.y, render_image)
  end
end

function Render.image_focus(o, render_image)
  canvas:compose(o.position.x, o.position.y, render_image)
  canvas:attrColor(o.parent.styles.focus.border.r, o.parent.styles.focus.border.g, o.parent.styles.focus.border.b, o.parent.styles.focus.border.a)
  -- horizontal 
  canvas:drawLine(o.parent.position.x + 1, o.parent.position.y + 1, (o.parent.position.x + o.parent.size.width), (o.parent.position.y + 1))
  canvas:drawLine(o.parent.position.x + 1, (o.parent.position.y + o.parent.size.height - 1), (o.parent.position.x + o.parent.size.width), (o.parent.position.y + o.parent.size.height - 1))
  -- vertical
  canvas:drawLine(o.parent.position.x + 1, o.parent.position.y + 1, o.parent.position.x + 1, (o.parent.position.y - 1 + o.parent.size.height))
  canvas:drawLine((o.parent.position.x + o.parent.size.width - 1), o.parent.position.y + 1, (o.parent.position.x + o.parent.size.width - 1), (o.parent.position.y - 1 + o.parent.size.height))
end

function Render.center_image(o)
  local image = storage:get_file(o.path, o.file_name, o.extension)
  if image == nil then return end
  local render_image = canvas:new(image)
  -- print(image)
  local dx, dy = render_image:attrSize()
  canvas:compose(o.parent.position.x + ((o.parent.size.width - dx) / 2), o.parent.position.y + ((o.parent.size.height - dy) / 2), render_image)
end

function Render.clear()
  canvas:attrColor(0, 0, 0, 0)
  canvas:clear()
  canvas:flush()
end

return Render