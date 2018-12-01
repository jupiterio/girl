local game = {}

local g = require "global"

function game:enter()
    if g.game.unlocked.lobby then
        g.world.changeMap(0, 1, 3)
    else
        g.world.changeMap(nil, 1, 1)
    end

    gooi.setGroupVisible("game", true)
    g.controls.gui:setVisible(g.game.touch)
end

function game:leave()
    gooi.setGroupVisible("game", false)
end

function game:update(dt)
    if dt > 0.25 then return end
    g.player:update(dt)
    g.world.update(dt)

    g.camera:setPosition(math.floor(g.player.x), math.floor(g.player.y))
end

function game:draw(omitControls)
    love.graphics.setColor(1, 1, 1)

    g.world:draw()
    g.camera:draw(function()
        g.player:draw()
    end)

    if not omitControls then
        gooi.draw("game")
    end
end

function game:keypressed(key, scan, isrepeat)
    if scan == "escape" then
        Gamestate.switch(g.states.menu)
    end
end

function game:touchpressed(id, x, y)
    local overGui = false
    if not g.controls.overGui(x, y) then
        Gamestate.push(g.states.draw)
        g.states.draw:touchpressed(id, x, y)
    end
end

function game:mousepressed(x, y, button, istouch)
    if istouch then return end
    if not g.controls.overGui(x, y) then
        Gamestate.push(g.states.draw)
        g.states.draw:mousepressed(x, y, button, istouch)
    end
end

function game:mousereleased(...)
    -- if the mouse was pressed and the state switched, but the release was caught here, pop()
    -- we don't want that because it causes bugs
    if Gamestate:current() == g.states.draw then
        Gamestate.pop()
    end
end

return game