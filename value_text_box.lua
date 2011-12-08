-- @author cedlemo  

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type = type
local string = string
local color = require("gears.color")
local base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
---A text box that can display value and text with colors. 
module("blingbling.value_text_box")

local data = setmetatable({}, { __mode = "k" })

---Fill all the widget with this color (default is transparent).
--@usage myvt_box:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param vt_box the value text box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border (width * height) with this color (default is none ) 
--@usage myvt_box:set_background_border(string) -->"#rrggbbaa"
--@name set_background_border
--@class function
--@vt_box vt_box the vt_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the text area (text height/width + padding) background with this color (default is none)
--@usage myvt_box:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param vt_box the vt_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border on the text area background (default is none ) 
--@usage myvt_box:set_text_background_border(string) -->"#rrggbbaa"
--@name set_text_background_border
--@class function
--@vt_box vt_box the vt_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the top and bottom margin for the text background 
--@usage myvt_box:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param vt_box the value text box
--@param margin an integer for top and bottom margin

---Define the left and right margin for the text background
--@usage myvt_box:set_h_margin(integer) 
--@name set_h_margin
--@class function
--@param vt_box the value text box
--@param margin an integer for left and right margin

---Define the padding between the text and it's background
--@usage myvt_box:set_padding(integer) 
--@name set_h_margin
--@class function
--@param vt_box the value text box
--@param padding an integer for the text padding

---Set rounded corners for background and text background
--@usage myvt_box:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param vt_box the value text box
--@param rounded_size float in [0,1]

---Define the color for all the text of the widget (white by default)
--@usage myvt_box:set_default_text_color(string) -->"#rrggbbaa"
--@name set_default_text_color
--@class function
--@param vt_box the value text box
--@param color a string "#rrggbbaa" or "#rrggbb

---Define the value text color depending on the limit given ( if value >= limit, we apply the color).
--@usage myvt_box:set_values_text_color(table) -->{ {"#rrggbbaa", limit 1}, {"#rrggbbaa", limit 2}}
--  By default the color is default_text_color(another example: {{"#88aa00ff",0},{"#d4aa00ff", 0.5},{"#d45500ff",0.75}})
--@name set_values_text_color
--@class function
--@param vt_box the value text box
--@param table table like { {"#rrggbbaa", limit 1}, {"#rrggbbaa", limit 2}}

---Define the text font size
--@usage myvt_box:set_font_size(integer)
--@name set_font_size
--@class function
--@param vt_box the value text box
--@param size the font size

---Define the template of the text to display
--@usage myvt_box:set_label(string)
--By default the text is : (value_send_to_the_widget *100) 
--static string: example set_label("CPU usage:") will display "CUP usage:" on the vt_box
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param vt_box the value text box
--@param text the text to display

local properties = {    "width", "height", "h_margin", "v_margin", "padding",
                        "background_border", "background_color", 
                        "text_background_border", "text_background_color",
                        "rounded_size", "default_text_color", "values_text_color", 
                        "font_size", "label"
                   }

function draw(vt_box, wibox, cr, width, height)
  local v_margin =  2 
  if data[vt_box].v_margin and data[vt_box].v_margin <= data[vt_box].height/4 then 
    v_margin = data[vt_box].v_margin 
  end
  local h_margin = 2
  if data[vt_box].h_margin and data[vt_box].h_margin <= data[vt_box].width / 3 then 
    h_margin = data[vt_box].h_margin 
  end
  local padding = data[vt_box].padding or 2
  local font_size = data[vt_box].font_size or 9
  --find the width of our image
  local value = (data[vt_box].value or 0) * 100
  local label = data[vt_box].label or "$percent"
  local text = string.gsub(label,"$percent", value)
  cr:set_font_size(font_size)
  local ext = cr:text_extents(text)
  local height = font_size + 2* padding + 2* v_margin
  local width = math.ceil(ext.width +2*ext.x_bearing+ 2*padding + 2* h_margin)

  if data[vt_box].width == nil or data[vt_box].width < width then
    data[vt_box].width = width
  end
  if data[vt_box].height == nil or data[vt_box].height < height then
    data[vt_box].height = height
  end
  
  local rounded_size = data[vt_box].rounded_size or 0
  
  --Generate Background (background widget)
  if data[vt_box].background_color then
    helpers.draw_rounded_corners_rectangle( cr,
                                            0,
                                            0,
                                            data[vt_box].width, 
                                            data[vt_box].height,
                                            data[vt_box].background_color, 
                                            rounded_size,
                                            data[vt_box].background_border
                                            )
  
  end
  
  --Draw nothing, or filled ( value background)
  if data[vt_box].text_background_color then
    --draw rounded corner rectangle
    local x=h_margin
    local y=v_margin
    
    helpers.draw_rounded_corners_rectangle( cr,
                                            x,
                                            y,
                                            data[vt_box].width - h_margin, 
                                            data[vt_box].height - v_margin, 
                                            data[vt_box].text_background_color, 
                                            rounded_size,
                                            data[vt_box].text_background_border
                                            )
  end  
    --draw the value

    --get the colors used to display the value

    --analyse the label :
    label_parts={}
    label_length = string.len(label)
    value_start, value_finish = string.find(label, "$percent")
    table.insert(label_parts,{1, value_start -1})
    table.insert(label_parts,{value_start, value_finish,is_value = true})
    local new_start = value_finish + 1
    if value_finish < label_length then
      while value_start ~= nil do
        value_start, value_finish = string.find(label, "$percent", new_start)
        if value_start ~=nil and value_start ~= new_start then
          table.insert(label_parts,{new_start, value_start -1})
          table.insert(label_parts,{value_start, value_finish, is_value = true})
          new_start = value_finish + 1
        elseif value_start == new_start then
          table.insert(label_parts,{value_start, value_finish, is_value = true})
          new_start = value_finish + 1
        end
      end
      --if rest char:
      if label_parts[#label_parts][2] < label_length then
        table.insert(label_parts,{label_parts[#label_parts][2] + 1, label_length})
      end
    end
    x= h_margin + padding
    y= 0 
    --Draw the text:

    local default_text_color = data[vt_box].default_text_color or "#ffffffff"
    local value_text_color = default_text_color 
    if data[vt_box].values_text_color  and type(data[vt_box].values_text_color) == "table" then
      for i,table in ipairs(data[vt_box].values_text_color) do
        if i == 1 then 
          if value/100 >= table[2] then
            value_text_color = table[1]
          end
        elseif i ~= 1 then
          if value/100 >= table[2]  then
            value_text_color = table[1]
          end
        end
      end
    end
    for i,range in ipairs(label_parts) do
      if range.is_value then 
        text = value
        --dirty trick : if there are spaces at the end of cairo text, they aren't represented so I put them at the begining of the value:
        for j=range[1],label_parts[i-1][1], -1 do
          if string.sub(label, j,j) == " " then
            text = " " .. text
          end
        end
        r,g,b,a = helpers.hexadecimal_to_rgba_percent(value_text_color)
        cr:set_source_rgba(r,g,b,a)
        ext = cr:text_extents(text)
        y=data[vt_box].height/2 + font_size/2 - padding/2 
        cr:set_font_size(font_size)
        cr:move_to(x,y)
        cr:show_text(text)
        x=x+ext.width + ext.x_bearing
      else
        text=string.sub(label, range[1],range[2])
        text=string.gsub(text, "(.*[^%s]*)(%s*)","%1")
        r,g,b,a = helpers.hexadecimal_to_rgba_percent(default_text_color)
        cr:set_source_rgba(r,g,b,a)
        ext = cr:text_extents(text)
       
        y=data[vt_box].height/2 + font_size/2 - padding/2 
 
        cr:set_font_size(font_size)
        cr:move_to(x,y)
        cr:show_text(text)
        x=x+ext.width --+ext.x_bearing
      end
    end

end

function fit(vt_box, width, height)
    return data[vt_box].width, data[vt_box].height
end

--- Add a value to the vt_box
-- @param vt_box The vt_box.
-- @param value The value between 0 and 1.
-- @param group The stack color group index.
local function add_value(vt_box, value)
    if not vt_box then return end

    local value = value or 0
   
    if string.find(value, "nan") then
       value=0
    end
   
    data[vt_box].value = value
    vt_box:emit_signal("widget::updated")
    return vt_box
end


--- Set the vt_box height.
-- @param vt_box The vt_box.
-- @param height The height to set.
function set_height(vt_box, height)
    if height >= 5 then
        data[vt_box].height = height
        vt_box:emit_signal("widget::updated")
    end
    return vt_box
end

--- Set the vt_box width.
-- @param vt_box The vt_box.
-- @param width The width to set.
function set_width(vt_box, width)
    if width >= 5 then
        data[vt_box].width = width
        vt_box:emit_signal("widget::updated")
    end
    return vt_box
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(vt_box, value)
            data[vt_box][prop] = value
            vt_box:emit_signal("widget::updated")
            return vt_box
        end
    end
end

--- Create a vt_box widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set vt_box geometry.
-- @return A vt_box widget.
function new(args)
    local args = args or {}

    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local vt_box = base.make_widget()

    data[vt_box] = { width = width, height = height }

    -- Set methods
    vt_box.add_value = add_value
    vt_box.draw = draw
    vt_box.fit = fit

    for _, prop in ipairs(properties) do
        vt_box["set_" .. prop] = _M["set_" .. prop]
    end

    return vt_box
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

