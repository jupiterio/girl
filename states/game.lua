local game = {}

local g = require "global"

function game:enter()
    g.world.changeMap(nil, 1, 1)
end

function game:update(dt)
    if dt > 0.25 then return end
    g.player:update(dt)
    g.world.update(dt)

    g.camera:setPosition(math.floor(g.player.x), math.floor(g.player.y))
end

function game:draw()
    love.graphics.setColor(1, 1, 1)

    g.camera:draw(function()
        g.world.draw()
        g.player:draw()
    end)

    gooi.draw()
end

function game:keypressed(key, scan, isrepeat)
    if scan == "escape" then
        Gamestate.switch(g.states.menu)
    end
end

function game:mousepressed(...)
    local overGui = false
    for k,v in ipairs(g.controls.gui.sons) do
        if v.ref:overIt() then
            overGui = true
            break
        end
    end
    if not overGui then
        Gamestate.push(g.states.draw)
        require("lib.gesture.detection").mousepressed(...)
    end
end


function game:mousereleased(...)
    if Gamestate:current() == g.states.draw then
        Gamestate.pop()
    end
end

return game