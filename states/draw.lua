local draw = {}

local detection = require "lib.gesture.detection"
local abilities = require "lib.abilities"

local g = require "global"

function draw:enter()
    love.graphics.setShader(g.assets.shaders.sepia)
end

function draw:draw()
    love.graphics.setShader(g.assets.shaders.sepia)
    love.graphics.setColor(1, 1, 1)

    g.camera:draw(function()
        g.world.draw()
        g.player:draw()
    end)

    love.graphics.setShader()

    detection.draw()
end

function draw:keypressed(key, scan, isrepeat)
    if scan == "escape" then
        Gamestate.switch(g.states.menu)
    end
end

function draw:mousepressed(x, y, button, istouch)
    if istouch then return end
    detection.pressed("mouse", x, y)
end
function draw:mousemoved(x, y, dx, dy, istouch)
    if istouch then return end
    detection.moved("mouse", x, y, dx, dy)
end
function draw:mousereleased(x, y, button, istouch)
    if istouch then return end
    detection.released("mouse", x, y)
    Gamestate.pop()
    local ability = abilities[detection.detected]
    if ability then
        ability(x, y)
    end
end

function draw:touchpressed(id, x, y) 
    detection.pressed(id, x, y)
end
function draw:touchmoved(id, x, y, dx, dy)
    detection.moved(id, x, y, dx, dy)
end
function draw:touchreleased(id, x, y)
    detection.released(id, x, y)
    Gamestate.pop()
    local ability = abilities[detection.detected]
    if ability then
        ability(x, y)
    end
end

function draw:leave()
    love.graphics.setShader()
end

return draw