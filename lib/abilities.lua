local abilities = {}

local g = require "global"

function abilities.ball()
    if g.game.abilities.ball and abilities.canTransform() then
        if g.player.state == "ball" then
            g.player:changeState("girl")
        else
            g.player:changeState("ball")
        end
    end
end

function abilities.canTransform()
    if g.player.state == "girl" then -- transformations can only go smaller
        return true -- so yes, transform
    else
        -- if player is transformed, you don't want to hit your head
        -- once you transform into the bigger player sprite
        local x, y = g.player:getTilePos()
        local ceiling = g.world.map:getRawTile(x, y - 1)
        -- so if there's a ceiling tile and that tile is empty, transform
        -- else if there's not a ceiling tile or the tile isn't empty, don't transform
        return ceiling and ceiling == -1
    end
end

return abilities