local actions = {}

local g = require "global"

function actions.test()
    return {
        tile = -1,
        deco = 80,
        onJump = function(self) gooi.alert({text = "activated!"}) end,
        onVisible = function(self) g.world.entities["mole"] = require("entities.enemies.mole")((self.x-0.5)*60, (self.y-1)*60) end,
        onTouched = function(self) gooi.alert({text = "touched!"}) end
    }
end

function actions.lobby()
    return {
        tile = -1,
        deco = -1,
        onVisible = function(self) g.game.unlocked.lobby = true end
    }
end

function actions.abBall()
    if g.game.abilities.ball then
        return {
            tile = -1,
            deco = -1
        }
    else
        return {
            tile = -1,
            deco = 80,
            onTouched = function(self) g.states.learn:learn("ball") end
        }
    end
end

return actions