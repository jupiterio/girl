local enums = require "lib.tilemap.enums" -- important enums
local actions = require "lib.actions"

local DIRS = enums.DIRS
local IDS = enums.IDS

local function sameTile(self, x1,y1,x2,y2)
    local t1 = self:getRawTile(x1, y1)
    local t2 = self:getRawTile(x2, y2)
    if t1 == nil or t2 == nil then return true end -- if any of them are out of bounds, just say they're the same
    if enums.DECOS[t1] then -- take a look at autotile() for why i'm doing this
        t1 = enums.DECOS[t1].tile
    end
    if enums.DECOS[t2] then -- take a look at autotile() for why i'm doing this
        t2 = enums.DECOS[t2].tile
    end
    -- take a look at the TILES table in enums.lua to see what `similar` is about
    if (enums.TILES[t1] or {}).similar then
        return enums.TILES[t1].similar[t2]
    elseif (enums.TILES[t2] or {}).similar then
        return enums.TILES[t2].similar[t1]
    else
        -- if all else fails, use the good 'ol == operator
        return t1 == t2
    end
end

return function(self)
    self.tiles = {} -- the final tilemap
    self.deco = {} -- drawn over the top of tiles

    for y = 1, self.height do
        self.tiles[y] = {}
        self.deco[y] = {}

        for x = 1, self.width do
            local id = self:getRawTile(x, y)
            local object = enums.OBJECTS[id]
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
                if id > 2000000 then
                    self.deco[y][x] = IDS.EMPTYID
                else
                    if self:getRawTile(x, y-1) == -1 then
                        self.deco[y-1][x] = 88
                        self.deco[y][x] = 96
                    else
                        self.deco[y][x] = 89
                    end
                end
            elseif id > IDS.EMPTYID then
                local deco = enums.DECOS[id]
                if deco then -- Check if it's a deco
                    -- Decos are not actual tiles, they're draw over the top of tiles
                    -- So assign the correct tile id to the `id` variable
                    id = deco.tile
                else
                    -- if there isn't any deco just assign it an empty table, so the
                    -- code below doesn't error out
                    deco = {}
                end
                local tile = enums.TILES[id] or {}
                -- check if the current tile and is neighbours are the same
                local n  = sameTile(self, x, y, x, y-1)   and DIRS.n or 0
                local ne = sameTile(self, x, y, x+1, y-1) and DIRS.ne or 0
                local e  = sameTile(self, x, y, x+1, y)   and DIRS.e or 0
                local se = sameTile(self, x, y, x+1, y+1) and DIRS.se or 0
                local s  = sameTile(self, x, y, x, y+1)   and DIRS.s or 0
                local sw = sameTile(self, x, y, x-1, y+1) and DIRS.sw or 0
                local w  = sameTile(self, x, y, x-1, y)   and DIRS.w or 0
                local nw = sameTile(self, x, y, x-1, y-1) and DIRS.nw or 0
    
                -- build the binary number representing the neighbours
                local final = n+ne+e+se+s+sw+w+nw
                -- look up the tile to use in the corresponding TILES table in enums.lua
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