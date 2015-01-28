--- === mjolnir.bg.grid ===
---
--- Move/resize your windows along a virtual and horizontal grid.
---
--- Usage: local grid = require "mjolnir.bg.grid"
---
--- The grid is an partition of your screen; by default it is 3x3, i.e. 3 cells wide by 3 cells tall.
---
--- Grid cells are just a table with keys: x, y, w, h
---
--- For a grid of 2x2:
---
--- * a cell {x=0, y=0, w=1, h=1} will be in the upper-left corner
--- * a cell {x=1, y=0, w=1, h=1} will be in the upper-right corner
--- * and so on...

local grid = {}

local fnutils = require "mjolnir.fnutils"
local window = require "mjolnir.window"
local alert = require "mjolnir.alert"
local screen = require "mjolnir.screen"


--- mjolnir.bg.grid.MARGINX = 5
--- Variable
--- The margin between each window horizontally.
grid.MARGINX = 5

--- mjolnir.bg.grid.MARGINY = 5
--- Variable
--- The margin between each window vertically.
grid.MARGINY = 5

--- mjolnir.bg.grid.GRIDHEIGHT = 3
--- Variable
--- The number of cells high the grid is.
grid.GRIDHEIGHT = 3

--- mjolnir.bg.grid.GRIDWIDTH = 3
--- Variable
--- The number of cells wide the grid is.
grid.GRIDWIDTH = 3

-- The table containing cells
local main = screen.mainscreen():frame()
local cells = {
  {x = 0,        y = 0,        w = main.w/2, h = main.h/2},
  {x = main.w/2, y = 0,        w = main.w/2, h = main.h/2},
  {x = 0,        y = main.h/2, w = main.w/2, h = main.h/2},
  {x = main.w/2, y = main.h/2, w = main.w/2, h = main.h/2}
}

function grid.set2(win, cell)
  for k,v in pairs(cells[cell]) do
  end
  win:setframe(cells[cell])
end

local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

--- mjolnir.bg.grid.get(win)
--- Function
--- Gets the cell this window is on
function grid.get(win)
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  local cellwidth = screenrect.w / grid.GRIDWIDTH
  local cellheight = screenrect.h / grid.GRIDHEIGHT
  return {
    x = round((winframe.x - screenrect.x) / cellwidth),
    y = round((winframe.y - screenrect.y) / cellheight),
    w = math.max(1, round(winframe.w / cellwidth)),
    h = math.max(1, round(winframe.h / cellheight)),
  }
end

--- mjolnir.bg.grid.set(win, grid, screen)
--- Function
--- Sets the cell this window should be on
function grid.set(win, cell, screen)
  local screenrect = screen:frame()
  local cellwidth = screenrect.w / grid.GRIDWIDTH
  local cellheight = screenrect.h / grid.GRIDHEIGHT
  local newframe = {
    x = (cell.x * cellwidth) + screenrect.x,
    y = (cell.y * cellheight) + screenrect.y,
    w = cell.w * cellwidth,
    h = cell.h * cellheight,
  }

  newframe.x = newframe.x + grid.MARGINX
  newframe.y = newframe.y + grid.MARGINY
  newframe.w = newframe.w - (grid.MARGINX * 2)
  newframe.h = newframe.h - (grid.MARGINY * 2)

  win:setframe(newframe)
end

--- mjolnir.bg.grid.snap(win)
--- Function
--- Snaps the window into a cell
function grid.snap(win)
  if win:isstandard() then
    grid.set(win, grid.get(win), win:screen())
  end
end

--- mjolnir.bg.grid.adjustheight(by)
--- Function
--- Increases the grid by the given number of cells; may be negative
function grid.adjustheight(by)
  grid.GRIDHEIGHT = math.max(1, grid.GRIDHEIGHT + by)
  alert.show("grid is now " .. tostring(grid.GRIDHEIGHT) .. " tiles high", 1)
  fnutils.map(window.visiblewindows(), grid.snap)
end

--- mjolnir.bg.grid.adjustwidth(by)
--- Function
--- Widens the grid by the given number of cells; may be negative
function grid.adjustwidth(by)
  grid.GRIDWIDTH = math.max(1, grid.GRIDWIDTH + by)
  alert.show("grid is now " .. tostring(grid.GRIDWIDTH) .. " tiles wide", 1)
  fnutils.map(window.visiblewindows(), grid.snap)
end

--- mjolnir.bg.grid.adjust_focused_window(fn)
--- Function
--- Passes the focused window's cell to fn and uses the result as its new cell.
function grid.adjust_focused_window(fn)
  local win = window.focusedwindow()
  local f = grid.get(win)
  fn(f)
  grid.set(win, f, win:screen())
end

--- mjolnir.bg.grid.maximize_window()
--- Function
--- Maximizes the focused window along the given cell.
function grid.maximize_window()
  local win = window.focusedwindow()
  local f = {x = 0, y = 0, w = grid.GRIDWIDTH, h = grid.GRIDHEIGHT}
  grid.set(win, f, win:screen())
end

--- mjolnir.bg.grid.pushwindow_nextscreen()
--- Function
--- Moves the focused window to the next screen, using its current cell on that screen.
function grid.pushwindow_nextscreen()
  local win = window.focusedwindow()
  grid.set(win, grid.get(win), win:screen():next())
end

--- mjolnir.bg.grid.pushwindow_prevscreen()
--- Function
--- Moves the focused window to the previous screen, using its current cell on that screen.
function grid.pushwindow_prevscreen()
  local win = window.focusedwindow()
  grid.set(win, grid.get(win), win:screen():previous())
end

--- mjolnir.bg.grid.pushwindow_left()
--- Function
--- Moves the focused window one cell to the left.
function grid.pushwindow_left()
  grid.adjust_focused_window(function(f) f.x = math.max(f.x - 1, 0) end)
end

--- mjolnir.bg.grid.pushwindow_right()
--- Function
--- Moves the focused window one cell to the right.
function grid.pushwindow_right()
  grid.adjust_focused_window(function(f) f.x = math.min(f.x + 1, grid.GRIDWIDTH - f.w) end)
end

--- mjolnir.bg.grid.resizewindow_wider()
--- Function
--- Resizes the focused window's right side to be one cell wider.
function grid.resizewindow_wider()
  grid.adjust_focused_window(function(f) f.w = math.min(f.w + 1, grid.GRIDWIDTH - f.x) end)
end

--- mjolnir.bg.grid.resizewindow_thinner()
--- Function
--- Resizes the focused window's right side to be one cell thinner.
function grid.resizewindow_thinner()
  grid.adjust_focused_window(function(f) f.w = math.max(f.w - 1, 1) end)
end

--- mjolnir.bg.grid.pushwindow_down()
--- Function
--- Moves the focused window to the bottom half of the screen.
function grid.pushwindow_down()
  grid.adjust_focused_window(function(f) f.y = math.min(f.y + 1, grid.GRIDHEIGHT - f.h) end)
end

--- mjolnir.bg.grid.pushwindow_up()
--- Function
--- Moves the focused window to the top half of the screen.
function grid.pushwindow_up()
  grid.adjust_focused_window(function(f) f.y = math.max(f.y - 1, 0) end)
end

--- mjolnir.bg.grid.resizewindow_shorter()
--- Function
--- Resizes the focused window so its height is 1 grid count less.
function grid.resizewindow_shorter()
  grid.adjust_focused_window(function(f) f.y = f.y - 0; f.h = math.max(f.h - 1, 1) end)
end

--- mjolnir.bg.grid.resizewindow_taller()
--- Function
--- Resizes the focused window so its height is 1 grid count higher.
function grid.resizewindow_taller()
  grid.adjust_focused_window(function(f) f.y = f.y - 0; f.h = math.min(f.h + 1, grid.GRIDHEIGHT - f.y) end)
end

return grid
