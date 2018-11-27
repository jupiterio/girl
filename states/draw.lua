local draw = {}

local detection = require "lib.gesture.detection"

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

function draw:mousepressed(...) detection.mousepressed(...) end
function draw:mousemoved(...) detection.mousemoved(...) end
function draw:mousereleased(...) detection.mousereleased(...) Gamestate.pop() print(detection.detected) end

function draw:leave()
    love.graphics.setShader()
end

return draw