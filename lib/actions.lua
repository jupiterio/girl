local actions = {}

local g = require "global"

function actions.test()
    return {
        tile = -1,
        deco = 80,
        onJump = function(self) gooi.alert({text = "activated!"}) end,
        onVisible = function(self) g.world.entities["bird"] = require("entities.enemies.owl")((self.x-0.5)*60, (self.y-1)*60) end,
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
    return {
        tile = -1,
        deco = 80,
        onTouched = function(self) g.game.abilities.ball = true end
    }
end

return actions