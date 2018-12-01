local world = {}

local Tilemap = require "lib.tilemap"
local tileset = require "lib.tilemap.enums"
local tilecollider = require "thirdparty.tilecollider"

local g = require "global"

local function getTile(x, y)
    if y >= world.map.height then return -1 end
    return world.map:getTile(x+1, y+1) or 0
end

local increasing = (function() local t = {} for i = 1,60 do table.insert(t, i) end return t end)()
local decreasing = (function() local t = {} for i = 60,1,-1 do table.insert(t, i) end return t end)()

local heightmaps = {
    BLSlope = {
        vertical = decreasing
    },
    BRSlope = {
        vertical = increasing
    },

    TLSlope = {
        horizontal = decreasing,
        vertical = decreasing
    },
    TRSlope = {
        horizontal = decreasing,
        vertical = increasing
    },

    BLSlip = {
        horizontal = increasing
    },
    BRSlip = {
        horizontal = increasing
    }
}

local _heightmaps = setmetatable({},{
    __index = function(t, k)
        return heightmaps[tileset.TYPES[k]]
    end
})

local function willResolve(side, tile, gx, gy)
    if tileset.TYPES[tile] then
        if tileset.TYPES[tile] == "BLSlope" and side == "bottom" then return true end
        if tileset.TYPES[tile] == "BRSlope" and side == "bottom" then return true end
        if tileset.TYPES[tile] == "TLSlope" and (side == "top" or side == "left") then return true end
        if tileset.TYPES[tile] == "TRSlope" and (side == "top" or side == "right") then return true end
        if tileset.TYPES[tile] == "BLSlip" and side == "left" then return true end
        if tileset.TYPES[tile] == "BRSlip" and side == "right" then return true end
        return false
    else
        return true
    end
end

local resolved
local function resolve(side, tile, gx, gy)
    if tile == -1 then return false end

    local result = willResolve(side, tile, gx, gy)
    if result then resolved = tile end
    return result
end

function world.init()
    world.handler = tilecollider(getTile, 60, 60, resolve, _heightmaps)
    world.terminalVelocity = 1000
    world.gravity = 1500
end

function world.draw()
    love.graphics.setColor(1,1,1)
    world.map:drawBg(g.camera:getVisible())

    g.camera:draw(function()
        love.graphics.setColor(1, 1, 1)
        world.map:draw(g.camera:getVisible())

        world.forEntity(function(k,entity)
            entity:draw()
        end)
    end)
end


function world.update(dt)
    world.forEntity(function(k,entity)
        entity:update(dt)
    end)

    for i = 1, #world.map.objects do
        local object = world.map.objects[i]
        if object.id ~= "door" and object.id ~= "entry" then
            -- check if it's visible
            local x1,y1,x2,y2 = world.map:getVisibleTiles()
            if x1 <= object.x and object.x <= x2 and
                y1 <= object.y and object.y <= y2 then
                
                if not object.visible then
                    object.visible = true
                    if tonumber(object.id) then
                        if not world.entities[i] or world.entities[i].destroyed then
                            local x, y = (object.x-0.5)*60, (object.y-1)*60
                            if object.id == tileset.IDS.HERCULESID then
                                world.entities[i] = require("entities.enemies.hercules")(x, y)
                            elseif object.id == tileset.IDS.OWLID then
                                world.entities[i] = require("entities.enemies.owl")(x, y+30)
                            end
                        end
                    elseif object.onVisible then
                        object:onVisible()
                    end
                end
            else
                if object.visible then
                    object.visible = false
                end
            end
        end
    end
end

function world.forEntity(f)
    for k,v in pairs(world.entities) do
        if not v.destroyed and f(k,v) then
            break
        end
    end
end

function world.changeMap(n, x, y)
    x, y = math.max(x, 1), math.max(y, 1)

    local gameWidth, gameHeight = love.graphics.getDimensions()
    gameWidth, gameHeight = gameWidth/g.game.scale, gameHeight/g.game.scale

    local mapname = "area_" .. tostring(x) .. "_" .. tostring(y)
    world.map = Tilemap(g.assets.maps[mapname])

    local    mapWidth,    mapHeight = 60*world.map.width, 60*world.map.height
    local boundsWidth, boundsHeight = math.max(mapWidth, gameWidth), math.max(mapHeight, gameHeight)
    -- center the map if it's smaller than the window
    g.camera:setWorld((mapWidth - boundsWidth) / 2, (mapHeight - boundsHeight) / 2, boundsWidth, boundsHeight)

    if world.entities then
        world.forEntity(function(k,entity)
            entity:destroy()
        end)
    end

    world.entities = {}
    local objects = world.map.objects
    for k,v in ipairs(objects) do
        if v.id == "door" or v.id == "entry" then
            if n and v.cur == n then
                g.player.canAct = false
                g.player:reset((v.x-0.5)*60, (v.y-1)*60)
                Timer.after(0.5, function() g.player.canAct = true end)
            end
        elseif v.id == tileset.IDS.PLAYERID then
            if not n then
                g.player:reset((v.x-0.5)*60, (v.y-1)*60)
            end
        end
    end
end

function world.move(creature, dx, dy)
    local bbox = creature.bbox
    local oldx, oldy = creature.x + bbox.ox, creature.y + bbox.oy
    local goalx, goaly = oldx+dx, oldy+dy
    local newx, newy
    local sides = {}

    if dx > 0 then
        resolved = nil
        newx = world.handler:rightResolve(goalx, oldy, bbox.w, bbox.h)
        sides.right = resolved
    elseif dx < 0 then
        resolved = nil
        newx = world.handler:leftResolve(goalx, oldy, bbox.w, bbox.h)
        sides.left = resolved
    else
        resolved = nil
        newx = world.handler:rightResolve(goalx, oldy, bbox.w, bbox.h)
        sides.right = resolved
        if newx == goalx then
            resolved = nil
            newx = world.handler:leftResolve(goalx, oldy, bbox.w, bbox.h)
            sides.left = resolved
        end
    end
	
    if dy > 0 then
        resolved = nil
        newy = world.handler:bottomResolve(newx, goaly, bbox.w, bbox.h)
        sides.bottom = resolved
    elseif dy < 0 then
        resolved = nil
        newy = world.handler:topResolve(newx, goaly, bbox.w, bbox.h)
        sides.top = resolved
    else
        resolved = nil
        newy = world.handler:bottomResolve(newx, goaly, bbox.w, bbox.h)
        sides.bottom = resolved
        if newy == goaly then
            resolved = nil
            newy = world.handler:topResolve(newx, goaly, bbox.w, bbox.h)
            sides.top = resolved
        end
    end

    return newx - bbox.ox, newy - bbox.oy, sides
end

return world