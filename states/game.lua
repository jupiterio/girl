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
        
        for i = 1, #g.world.entities do
            local entity = g.world.entities[i]
            entity:draw()
        end
    end)

    gooi.draw()
end

function game:keypressed(key, scan, isrepeat)
    if scan == "escape" then
        Gamestate.switch(g.states.menu)
    end
end

return game