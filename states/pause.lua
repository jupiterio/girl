local pause = {}

local g = require "global"

function pause:draw()
    love.graphics.setColor(255, 255, 255)

    g.world.draw()
    g.camera:draw(function()
        g.player:draw()
    end)

    love.graphics.printf("Paused. Click or tap to return to the game", 50, 50, love.graphics.getWidth()-100)
end

function pause:mousepressed()
    Gamestate.pop()
end

function pause:touchpressed()
    Gamestate.pop()
end

return pause