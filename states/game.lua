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

function game:touchpressed(id, x, y)
    local overGui = false
    for k,v in ipairs(g.controls.gui.sons) do
        if v.ref:overIt(x, y) and g.controls.gui.visible then
            overGui = true
            break
        end
    end
    if not overGui and not gooi.showingDialog then
        Gamestate.push(g.states.draw)
        g.states.draw:touchpressed(id, x, y)
    end
end

function game:mousepressed(x, y, button, istouch)
    if istouch then return end

    local overGui = false
    for k,v in ipairs(g.controls.gui.sons) do
        if v.ref:overIt(x, y) and g.controls.gui.visible then
            overGui = true
            break
        end
    end
    if not overGui and not gooi.showingDialog then
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