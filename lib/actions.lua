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

function actions.unlockUG()
    return {
        tile = -1,
        deco = -1,
        onVisible = function(self) g.game.unlocked.underground = true end
    }
end

function actions.UGDoor(x, y, map)
    if g.game.unlocked.underground then
        map.deco[y-1][x] = 88
        table.insert(map.objects, {
            id = "entry",
            x = x,
            y = y,
            cur = 2,
            goal = 0,
            mapx = 3,
            mapy = 3
        })
        return {
            tile = -1,
            deco = 96,
            onJump = function(self)
                g.world.changeMap(0, 2, 3)
            end
        }
    else
        return {
            tile = -1,
            deco = -1
        }
    end
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

function actions.abAirjump()
    if g.game.abilities.airjump then
        return {
            tile = -1,
            deco = -1
        }
    else
        return {
            tile = -1,
            deco = 81,
            onTouched = function(self) g.states.learn:learn("airjump") end
        }
    end
end

function actions.finish()
    return {
        tile = -1,
        deco = -1,
        onTouched = function(self) Gamestate.push(g.states.finished) end
    }
end

return actions