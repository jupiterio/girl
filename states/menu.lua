local menu = {}
local Gamestate = require "thirdparty.hump.gamestate"

local g = require "global"

local function unit()
    return love.graphics.getHeight()/5
end

menu.gui = gooi.newPanel({
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
    layout = "grid 5x1"
})

local play = gooi.newButton({
    text = "Play",
    w = unit()*2,
    h = unit()*2
}):onRelease(function() Gamestate.switch(g.states.game) end)

local edit = gooi.newButton({
    text = "Edit",
    w = unit()*2,
    h = unit()*2
}):onRelease(function() Gamestate.switch(g.states.editor) end)

menu.gui:add(play, edit)

function menu:update(dt)
    
end

function menu:draw()
    gooi.draw()
end

return menu