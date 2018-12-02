local unfinished = {}

local g = require "global"

function unfinished:draw()
    love.graphics.setColor(255, 255, 255)

    g.world.draw()
    g.camera:draw(function()
        g.player:draw()
    end)

    love.graphics.printf("This part hasn't been finished, sorry. Click or tap to return to the game", 50, 50, love.graphics.getWidth()-100)
end

function unfinished:mousepressed()
    Gamestate.pop()
end

function unfinished:touchpressed()
    Gamestate.pop()
end

return unfinished