local finished = {}

local g = require "global"

function finished:draw()
    love.graphics.setColor(255, 255, 255)

    g.world.draw()
    g.camera:draw(function()
        g.player:draw()
    end)

    love.graphics.printf("Well, you've finished what's in the game right now. Sorry to disappoint. " ..
    "Hopefully you can check it out later. Feel free to wander around the map. " ..
    "Protip: Get the ability over there, it's really fun. Click or tap to return to the game.", 50, 50, love.graphics.getWidth()-100)
end

function finished:mousepressed()
    Gamestate.pop()
end

function finished:touchpressed()
    Gamestate.pop()
end

return finished