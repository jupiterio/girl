local Class = require "thirdparty.hump.class"

local anim8 = require "thirdparty.anim8"
local bit = require "bit"
local csv = require "lib.csv"
local enums = require "lib.tilemap.enums" -- important enums
local actions = require "lib.actions"

local g = require "global"

-- This file is kind of a disaster. `enums.lua` is more disastrous, tho, even if it's just enums
local quads = anim8.newGrid(60, 60, 480, 600)('1-8',1, '1-8',2, '1-8',3, '1-8',4, '1-8',5, '1-8',6, '1-8',7, '1-8',8, '1-8',9, '1-8',10)
local Tilemap = Class{
    init = function(self, tiles)
        self.raw = csv.parse(csv.stringify(tiles))
        self.background = self.raw[#self.raw][1]
        table.remove(self.raw, #self.raw)
        self.height = #self.raw
        self.width = #self.raw[1]
        self.objects = {}
        self:autotile()
    end
}

Tilemap.autotile = require "lib.tilemap.autotile"

function Tilemap:getRawTile(x,y)
    return (self.raw[y] or {})[x]
end

function Tilemap:getTile(x,y)
    return (self.tiles[y] or {})[x]
end

function Tilemap:getDeco(x,y)
    return (self.deco[y] or {})[x]
end

function Tilemap:getVisibleTiles()
    local l,t,w,h = g.camera:getVisible()
    local x1,y1,x2,y2 =
        math.floor(l/60)+1, -- l
        math.floor(t/60)+1, -- t
        math.ceil(w/60), -- w
        math.ceil(h/60) -- h
    x1,y1,x2,y2 =
        math.clamp(x1, 1, self.width),
        math.clamp(y1, 1, self.height),
        math.clamp(x2+x1, 1, self.width),
        math.clamp(y2+y1, 1, self.height)
    return x1,y1,x2,y2
end

function Tilemap:draw(l,t,w,h)
    -- only render what's visible
    --love.graphics.draw(g.assets.bg[self.background], 0, 0)
    local x1,y1,x2,y2 = self:getVisibleTiles(l,t,w,h)
    -- it works like you'd expect
    for y = y1, y2 do
        for x = x1, x2 do
            local id = (self:getTile(x, y) or -1)
            if id > -1 then
                local tsetid = math.floor(id/80)
                local quad = quads[id - tsetid*80 + 1]
                local image = enums.TILESETS[tsetid + 1]
                love.graphics.draw(image, quad, (x - 1)*60, (y - 1)*60, 0, enums.SCALING[id] or 1)
            end
        end
    end

    for y = y1, y2 do
        for x = x1, x2 do
            local id = (self:getDeco(x, y) or -1)
            if id > -1 then
                local tsetid = math.floor(id/80)
                local quad = quads[id - tsetid*80 + 1]
                local image = enums.TILESETS[tsetid + 1]
                love.graphics.draw(image, quad, (x - 1)*60, (y - 1)*60, 0, enums.SCALING[id] or 1)
            end
        end
    end
end

function Tilemap:drawDebug(l,t,w,h)
    love.graphics.setColor(1,1,1,0.5)
    -- only render what's visible
    local x1,y1,x2,y2 = self:getVisibleTiles(l,t,w,h)
    -- it works like you'd expect
    for y = y1, y2 do
        for x = x1, x2 do
            local id = (self:getRawTile(x, y) or -1)
            -- we're dealing with the raw tiles right here, so a lot of times we'll reach doors which have ids over 100000, or actions which have non-numeric ids
            if not tonumber(id) then
                love.graphics.setColor(0,1,0,0.25)
                love.graphics.rectangle("fill", (x - 1)*60, (y - 1)*60, 60, 60)
                love.graphics.setColor(0,0,0)
                love.graphics.print(id, (x - 1)*60, (y - 1)*60)
                love.graphics.setColor(1,1,1,0.5)
            elseif id > 1000000 then
                love.graphics.setColor(0,0,1,0.25)
                love.graphics.rectangle("fill", (x - 1)*60, (y - 1)*60, 60, 60)
                love.graphics.setColor(0,0,0)
                love.graphics.print((id > 2000000 and "Entry" or "Door") .. "#" .. tostring(id):sub(2,2) .. "\n" .. "Goal #" .. tostring(id):sub(3,3) .. "\n" .. tostring(id):sub(4), (x - 1)*60, (y - 1)*60)
                love.graphics.setColor(1,1,1,0.5)
            elseif id > -1 then
                local quad = quads[id + 1]
                love.graphics.draw(g.assets.maps.autotile, quad, (x - 1)*60, (y - 1)*60)
            end
        end
    end
    love.graphics.setColor(1,1,1)
end

return Tilemap