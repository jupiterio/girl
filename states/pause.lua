local pause = {}

local g = require "global"

function pause:update(dt)
    if g.controls.down() then
        Gamestate.pop()
    end
end

function pause:draw()
    love.graphics.setColor(255, 255, 255)

    g.world.draw()
    g.camera:draw(function()
        g.player:draw()
    end)

    gooi.draw()
end

return pause