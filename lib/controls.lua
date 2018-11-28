local controls = {}

local g = require "global"

local function unit()
    return love.graphics.getHeight()/5
end

local gui = gooi.newPanel({
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
    layout = "game",
    group = "game"
})
controls.gui = gui

local joystick = gooi.newJoy({
    size = unit()*2,
    deadZone = 0.2,
    image = g.assets.joy,
    group = "game"
})
joystick:setDigital()
joystick:setRadius(unit())

local jumpPressed = false
local jumpButton = gooi.newButton({
    text = "jump",
    w = unit()*2,
    h = unit()*2,
    group = "game"
}):onPress(function() jumpPressed = true end):onRelease(function() jumpPressed = false end)
jumpButton:setRadius(unit())

gui:add(joystick, "b-l")
gui:add(jumpButton, "b-r")

function controls.overGui(x, y)
    if gooi.showingDialog then return true end
    local overGui = false
    for k,v in ipairs(gui.sons) do
        if v.ref:overIt(x, y) and gui.visible then
            overGui = true
            break
        end
    end
    return overGui
end

function controls.jump()
    return
        love.keyboard.isScancodeDown(g.settings.controls.jump) or
        love.keyboard.isScancodeDown(g.settings.controls.up) or
        jumpPressed
end

function controls.up()
    return
        love.keyboard.isScancodeDown(g.settings.controls.up) or
        joystick:direction() == "t"
end

function controls.down()
    return
        love.keyboard.isScancodeDown(g.settings.controls.down) or
        joystick:direction() == "b"
end

function controls.left()
    return
        love.keyboard.isScancodeDown(g.settings.controls.left) or
        joystick:direction() == "l" or
        joystick:direction() == "tl" or
        joystick:direction() == "bl"
end

function controls.right()
    return
        love.keyboard.isScancodeDown(g.settings.controls.right) or
        joystick:direction() == "r" or
        joystick:direction() == "tr" or
        joystick:direction() == "br"
end

return controls