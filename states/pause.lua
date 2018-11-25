local pause = {}

local g = require "global"

function pause:update(dt)
    if g.controls.down() then
        Gamestate.pop()
    end
end

function pause:draw()
    love.graphics.setColor(255, 255, 255)

    g.camera:draw(function()
        g.world.draw()
        g.player:draw()
        
        for i = 1, #g.world.objects do
            local object = g.world.objects[i]
            if not object.id then
                object:draw()
            end
        end
    end)

    gooi.draw()
end

return pause