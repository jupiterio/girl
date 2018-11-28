local save = {}

local binser = require "thirdparty.binser"

local g = require "global"

function save.save()
    local savetable = {
        health = g.player.health,
        abilities = g.game.abilities,
        unlocked = g.game.unlocked
    }
    local savedata = binser.s(savetable)
    love.filesystem.write("save.dat", savedata)
end

function save.load()
    local savedata = love.filesystem.read("save.dat")
    if savedata then
        local savetable = binser.dn(savedata, 1)
        g.player.health = savetable.health
        g.game.abilities = savetable.abilities
        g.game.unlocked = savetable.unlocked
        return true
    else
        return false
    end
end

setmetatable(save, {__call = save.save})

return save