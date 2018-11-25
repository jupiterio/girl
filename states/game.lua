local game = {}

local g = require "global"

function game:enter()
    g.world.changeMap(nil, 1, 1)
end

function game:update(dt)
    if dt > 0.5 then return end
    g.player:update(dt)
    g.world.update(dt)

    g.camera:setPosition(math.floor(g.player.x), math.floor(g.player.y))
end

function game:draw()
    love.graphics.setColor(1, 1, 1)

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

return game