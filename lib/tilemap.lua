local Class = require "thirdparty.hump.class"

local anim8 = require "thirdparty.anim8"
local bit = require "bit"
local csv = require "lib.csv"
local tileset = require "lib.tileset" -- important enums
local actions = require "lib.actions"

local g = require "global"

-- This file is kind of a disaster. `tileset.lua` is more disastrous, tho, even if it's just enums
local quads = anim8.newGrid(60, 60, 480, 600)('1-8',1, '1-8',2, '1-8',3, '1-8',4, '1-8',5, '1-8',6, '1-8',7, '1-8',8, '1-8',9, '1-8',10)
local DIRS = tileset.DIRS
local IDS = tileset.IDS
local Tilemap = Class{
    init = function(self, tiles)
        self.raw = csv.parse(csv.stringify(tiles))
        self.background = self.raw[#self.raw][1]
        table.remove(self.raw, #self.raw)
        self.height = #self.raw
        self.width = #self.raw[1]
        self.objects = {}
        self:autoTile()
    end
}

function Tilemap:autoTile()
    self.tiles = {} -- the final tilemap
    self.deco = {} -- drawn over the top of tiles

    for y = 1, self.height do
        self.tiles[y] = {}
        self.deco[y] = {}

        for x = 1, self.width do
            local id = self:getRawTile(x, y)
            local object = tileset.OBJECTS[id]
            if object then -- if it's an object (enemy spawner, player spawnpoint, doors, etc.)
                table.insert(self.objects, {id = id, x = x, y = y})
                id = object.tile -- objects can be put in tiles
            end
            if not tonumber(id) then -- actions don't have numeric ids
                local action = actions[id](x, y, self) -- return a table
                action.id = "action"
                action.x = x
                action.y = y
                table.insert(self.objects, action)
                self.tiles[y][x] = action.tile
                self.deco[y][x] = action.deco
            elseif id > 1000000 then -- doors and entries have ids over 1000000. They're kind of a hack? The door#, goal#, x, y they go to are the last 6 digits
                local code = tostring(id) -- so 1010415 points to the door #1 at the map area_4_15.csv
                local cur, goal, mapx, mapy = tonumber(code:sub(2,2)), tonumber(code:sub(3,3)), tonumber(code:sub(4,5)), tonumber(code:sub(6,7))
                table.insert(self.objects, {
                    id = id > 2000000 and "entry" or "door",
                    x = x,
                    y = y,
                    cur = cur,
                    goal = goal,
                    mapx = mapx,
                    mapy = mapy
                })
                self.tiles[y][x] = IDS.EMPTYID -- can't collide with 'em
                self.deco[y][x] = id > 2000000 and IDS.EMPTYID or math.random(80,83)
            elseif id > IDS.EMPTYID then
                local deco = tileset.DECOS[id]
                if deco then -- Check if it's a deco
                    -- Decos are not actual tiles, they're draw over the top of tiles
                    -- So assign the correct tile id to the `id` variable
                    id = deco.tile
                else
                    -- if there isn't any deco just assign it an empty table, so the
                    -- code below doesn't error out
                    deco = {}
                end
                local tile = tileset.TILES[id] or {}
                -- check if the current tile and is neighbours are the same
                local n  = self:sameTile(x, y, x, y-1)   and DIRS.n or 0
                local ne = self:sameTile(x, y, x+1, y-1) and DIRS.ne or 0
                local e  = self:sameTile(x, y, x+1, y)   and DIRS.e or 0
                local se = self:sameTile(x, y, x+1, y+1) and DIRS.se or 0
                local s  = self:sameTile(x, y, x, y+1)   and DIRS.s or 0
                local sw = self:sameTile(x, y, x-1, y+1) and DIRS.sw or 0
                local w  = self:sameTile(x, y, x-1, y)   and DIRS.w or 0
                local nw = self:sameTile(x, y, x-1, y-1) and DIRS.nw or 0
    
                -- build the binary number representing the neighbours
                local final = n+ne+e+se+s+sw+w+nw
                -- look up the tile to use in the corresponding TILES table in tileset.lua
                self.tiles[y][x] =
                       tile[final] -- lookup the tile as is
                    or tile[bit.band(final, DIRS.cardinal)] -- if there wasn't, don't take into account the corner neighbours and check again
                    or IDS.EMPTYID -- if there wasn't any, just don't put a tile
                self.deco[y][x] =
                      deco[final] -- same as above, just with decos
                   or deco[bit.band(final, DIRS.cardinal)]
                   or IDS.EMPTYID
            else
                self.tiles[y][x] = IDS.EMPTYID
                self.deco[y][x] = IDS.EMPTYID
            end
        end
    end
end

function Tilemap:sameTile(x1,y1,x2,y2)
    local t1 = self:getRawTile(x1, y1)
    local t2 = self:getRawTile(x2, y2)
    if t1 == nil or t2 == nil then return true end -- if any of them are out of bounds, just say they're the same
    if tileset.DECOS[t1] then -- take a look at autoTile() for why i'm doing this
        t1 = tileset.DECOS[t1].tile
    end
    if tileset.DECOS[t2] then -- take a look at autoTile() for why i'm doing this
        t2 = tileset.DECOS[t2].tile
    end
    -- take a look at the TILES table in tileset.lua to see what `similar` is about
    if (tileset.TILES[t1] or {}).similar then
        return tileset.TILES[t1].similar[t2]
    elseif (tileset.TILES[t2] or {}).similar then
        return tileset.TILES[t2].similar[t1]
    else
        -- if all else fails, use the good 'ol == operator
        return t1 == t2
    end
end

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
                local image = tileset.TILESETS[tsetid + 1]
                love.graphics.draw(image, quad, (x - 1)*60, (y - 1)*60, 0, tileset.SCALING[id] or 1)
            end
        end
    end

    for y = y1, y2 do
        for x = x1, x2 do
            local id = (self:getDeco(x, y) or -1)
            if id > -1 then
                local tsetid = math.floor(id/80)
                local quad = quads[id - tsetid*80 + 1]
                local image = tileset.TILESETS[tsetid + 1]
                love.graphics.draw(image, quad, (x - 1)*60, (y - 1)*60, 0, tileset.SCALING[id] or 1)
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