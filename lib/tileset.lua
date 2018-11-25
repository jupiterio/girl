local tileset = {}
-- various enums used in tilemap.lua
local g = require "global"

tileset.TILESETS = {
    g.assets.maps.grass,
    g.assets.maps.objects
}

-- neighbour bit flags
tileset.DIRS = {
    n = 1,
    ne = 2,
    e = 4,
    se = 8,
    s = 16,
    sw = 32,
    w = 64,
    nw = 128,
    cardinal = 1+4+16+64, -- n + e + s + w
    whole = 255 -- everything
}
local DIRS = tileset.DIRS
-- works just like any other bit flag mechanism
-- 37 == 100101 == DIRS.n+DIRS.e+DIRS.sw
-- A tile in the north, the east and the southwest

-- Just some ids representing different types of tiles and entity spawners
tileset.IDS = {
    EMPTYID = -1,
    DIRTID = 0,
    AO_GRASSID = 1,
    OT_GRASSID = 2,
    R_DIRTID = 3,
    R_AO_GRASSID = 4,
    UD_GRASSID = 5,
    PLAYERID = 6, -- player spawner. gon' remove this one in favour of doors and portals
    HERCULESID = 7, -- hercules beetle spawner
}
local IDS = tileset.IDS


local function block(tsetid, similar, tile, side) -- for DIRT-like tiles
    local inc = 0 + (tsetid-1)*80
    if side == "right" then inc = inc + 4 end
    return {
        similar = similar, -- assume all the tiles in this array are the same
        tile = tile,
        [DIRS.s+DIRS.e]        = 0+inc, -- if there's a tile in the south and the east, use the tile 0 from the tileset
        [DIRS.s+DIRS.e+DIRS.w] = 1+inc,
        [DIRS.s+DIRS.w]        = 2+inc,
        [DIRS.n+DIRS.s+DIRS.e] = 8+inc,
        [DIRS.cardinal]        = 9+inc,
        [DIRS.n+DIRS.s+DIRS.w] = 10+inc,
        [DIRS.n+DIRS.e]        = 16+inc,
        [DIRS.n+DIRS.e+DIRS.w] = 17+inc,
        [DIRS.n+DIRS.w]        = 18+inc,
        
        [DIRS.whole - DIRS.sw] = 33+inc, -- if there are tiles everywhere except the southwest, use tile 33
        [DIRS.whole - DIRS.se] = 32+inc,
        [DIRS.whole - DIRS.nw] = 41+inc,
        [DIRS.whole - DIRS.ne] = 40+inc,

        [0]             = 3+inc, -- if there are *no* tiles, use tile 3
        [DIRS.s]        = 11+inc,
        [DIRS.s+DIRS.n] = 19+inc,
        [DIRS.n]        = 27+inc,
        [DIRS.e]        = 24+inc,
        [DIRS.e+DIRS.w] = 25+inc,
        [DIRS.w]        = 26+inc,
    }
end

tileset.TILES = {
    [IDS.DIRTID] = block(1, {[IDS.DIRTID] = true, [IDS.R_DIRTID] = true}, nil, "right"),
    [IDS.R_DIRTID] = block(1, {[IDS.DIRTID] = true, [IDS.R_DIRTID] = true}, nil, "right")
}
tileset.TILES[IDS.R_DIRTID][DIRS.s+DIRS.e] = 38
tileset.TILES[IDS.R_DIRTID][DIRS.s+DIRS.w] = 39
tileset.TILES[IDS.R_DIRTID][DIRS.n+DIRS.e] = 46
tileset.TILES[IDS.R_DIRTID][DIRS.n+DIRS.w] = 47

tileset.DECOS = {
    [IDS.AO_GRASSID] = block(1, nil, IDS.DIRTID, "left"),
    [IDS.OT_GRASSID] = {
        tile = IDS.DIRTID,
        [DIRS.s+DIRS.e] = 48,
        [DIRS.e] = 48,
        [DIRS.s+DIRS.e+DIRS.w] = 1,
        [DIRS.e+DIRS.w] = 1,
        [DIRS.s+DIRS.w] = 49,
        [DIRS.w] = 49,
        
        [DIRS.whole - DIRS.sw] = -1,
        [DIRS.whole - DIRS.se] = -1,
        [DIRS.whole - DIRS.nw] = 59,
        [DIRS.whole - DIRS.ne] = 58,

        [0] = 3,
        [DIRS.s] = 11,
        [DIRS.s+DIRS.n] = 19,
        [DIRS.n] = 27,
    },
    [IDS.R_AO_GRASSID] = block(1, nil, IDS.R_DIRTID, "left"),
    [IDS.UD_GRASSID] = {
        tile = IDS.DIRTID,
        [DIRS.n+DIRS.e] = 56,
        [DIRS.e] = 56,
        [DIRS.n+DIRS.e+DIRS.w] = 17,
        [DIRS.e+DIRS.w] = 17,
        [DIRS.n+DIRS.w] = 57,
        [DIRS.w] = 57,
        
        [DIRS.whole - DIRS.sw] = 51,
        [DIRS.whole - DIRS.se] = 50,
        [DIRS.whole - DIRS.nw] = -1,
        [DIRS.whole - DIRS.ne] = -1,

        [0] = 3,
        [DIRS.s] = 11,
        [DIRS.s+DIRS.n] = 19,
        [DIRS.n] = 27,
    },
}
tileset.DECOS[IDS.AO_GRASSID][DIRS.cardinal] = -1
tileset.DECOS[IDS.R_AO_GRASSID][DIRS.cardinal] = -1
tileset.DECOS[IDS.R_AO_GRASSID][DIRS.s+DIRS.e] = 34
tileset.DECOS[IDS.R_AO_GRASSID][DIRS.s+DIRS.w] = 35
tileset.DECOS[IDS.R_AO_GRASSID][DIRS.n+DIRS.e] = 42
tileset.DECOS[IDS.R_AO_GRASSID][DIRS.n+DIRS.w] = 43

tileset.OBJECTS = {
    [IDS.PLAYERID] = { tile = -1 }, -- can be a tile or deco id
    [IDS.HERCULESID] = { tile = -1 } -- can be a tile or deco id
}
tileset.TYPES = {
    [38] = "BRSlope", -- This is for the tile collision handler
    [39] = "BLSlope", -- Assigns slope status to certain tiles
    [46] = "TRSlope", -- "Top Right Slope"
    [47] = "TLSlope",
    -- [n] = "BRSlip" -- "Bottom Right Slippery Slope"
}
tileset.SCALING = {
    [80] = 1.1, -- This is a hack. The doors/portals look like they're floating with 1x scaling
    [81] = 1.1, -- So to fix that, I'm scaling them 1.1x
    [82] = 1.1,
    [83] = 1.1,
}

return tileset