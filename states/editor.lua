local editor = {}

-- welcome to disaster town
local Tilemap = require "lib.tilemap"
local csv = require "lib.csv"
local actions = require "lib.actions"

local g = require "global"

local gui = gooi.newPanel({
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight()/2.5,
    layout = "grid 5x4",
    group = "editor"
})

local idlabel = gooi.newLabel({
    text = "0",
    w = 25,
    h = 40,
    group = "editor"
})
idlabel:fg({0,0,0,1})
local poslabel = gooi.newLabel({
    text = "1,1",
    w = 25,
    h = 40,
    group = "editor"
})
poslabel:fg({0,0,0,1})

local size = gooi.newText({
    text = "10x10",
    w = 150,
    h = 40,
    group = "editor"
})
local map
local x, y = 1, 1
local id = 0
local setsize = gooi.newButton({
    text = "Set Size",
    w = 100,
    h = 40,
    group = "editor"
}):onRelease(function()
    local _w, _h = tonumber(size:getText():sub(1,2)), tonumber(size:getText():sub(4,5))
    if _w and _h then
        _w, _h = math.max(_w, 10), math.max(_h, 10)
        if not (_w == map.width) or not (_h == map.height) then
            local grid = {}
            for y=1, _h do
                grid[y] = {}
                for x=1, _w do
                    grid[y][x] = map:getRawTile(x, y) or -1
                end
            end
            table.insert(grid, {map.background})
            map = Tilemap(grid)
        end
        _w, _h = tostring(_w), tostring(_h)
        _w = #_w < 2 and "0" .. _w or _w
        _h = #_h < 2 and "0" .. _h or _h
        size:setText(_w .. "x" .. _h)
    end
end)

local isentry = gooi.newCheck({
    text = "entry?",
    w = 125,
    h = 40,
    checked = false,
    group = "editor"
})
local doorid = gooi.newText({
    text = "0",
    w = 150,
    h = 40,
    group = "editor"
})
local doorpos = gooi.newText({
    text = "0,01,01",
    w = 150,
    h = 40,
    group = "editor"
})
local adddoor = gooi.newButton({
    text = "Add Door",
    w = 100,
    h = 40,
    group = "editor"
}):onRelease(function()
    local cur = tonumber(doorid:getText())
    local goal, mapx, mapy = tonumber(doorpos:getText():sub(1,1)), tonumber(doorpos:getText():sub(3,4)), tonumber(doorpos:getText():sub(6,7))
    if cur and goal and mapx and mapy then
        cur = tostring(math.clamp(cur, 0, 9))
        goal, mapx, mapy = tostring(math.clamp(goal, 0, 9)), tostring(math.clamp(mapx, 1, 20)), tostring(math.clamp(mapy, 1, 20))
        mapx = #mapx < 2 and "0" .. mapx or mapx
        mapy = #mapy < 2 and "0" .. mapy or mapy
        doorid:setText(cur)
        doorpos:setText(goal .. "," .. mapx .. "," .. mapy)
        if isentry.checked then
            map.raw[y][x] = tonumber("2" .. cur .. goal .. mapx .. mapy)
        else
            map.raw[y][x] = tonumber("1" .. cur .. goal .. mapx .. mapy)
        end
        map:autotile()
    end
end)

local actionname = gooi.newText({
    text = "",
    w = 150,
    h = 40,
    group = "editor"
})
local addaction = gooi.newButton({
    text = "Add Action",
    w = 100,
    h = 40,
    group = "editor"
}):onRelease(function()
    local name = actionname:getText()
    if actions[name] then
        map.raw[y][x] = name
        map:autotile()
    end
end)

local filename = gooi.newText({
    text = "area_1_1",
    w = 150,
    h = 40,
    group = "editor"
})

local bg = gooi.newText({
    text = "forest",
    w = 150,
    h = 40,
    group = "editor"
})
local setbg = gooi.newButton({
    text = "Set BG",
    w = 100,
    h = 40,
    group = "editor"
}):onRelease(function()
    map.background = bg:getText()
end)

local load = gooi.newButton({
    text = "Load",
    w = 100,
    h = 40,
    group = "editor"
}):onRelease(function()
    local f = io.open("assets/maps/" .. filename:getText() .. ".csv", "r")
    if f then
        local grid = csv.parse(f:read("*a"))
        f:close()
        map = Tilemap(grid)

        x = 1
        y = 1

        local _w, _h = tostring(map.width), tostring(map.height)
        _w = #_w < 2 and "0" .. _w or _w
        _h = #_h < 2 and "0" .. _h or _h
        size:setText(_w .. "x" .. _h)

        bg:setText(map.background)
    end
end)
local save = gooi.newButton({
    text = "Save",
    w = 100,
    h = 40,
    group = "editor"
}):onRelease(function()
    local f = io.open("assets/maps/" .. filename:getText() .. ".csv", "w+")
    local csvd = csv.stringify(map.raw) .. "\n" .. map.background
    f:write(csvd)
    f:flush()
    f:close()

    local f = io.open("assets/maps/" .. filename:getText() .. ".csv", "r")
    if f then
        g.assets.maps[filename:getText()] = csv.parse(f:read("*a"))
        f:close()
    end
end)

local showmap = gooi.newCheck({
    text = "Show Tiled Map",
    w = 200,
    h = 40,
    checked = true,
    group = "editor"
})

gui:setColspan(2,1, 3)
gui:setColspan(3,2, 2)
gui:add(
    doorid,
    doorpos,
    isentry,
    actionname,
    adddoor,
    addaction,
    size,
    filename,
    bg,
    setsize,
    load,
    save,
    setbg,
    showmap,
    idlabel,
    poslabel
)

function editor:enter()
    g.camera:setWorld(-math.huge, -math.huge, math.huge, math.huge)
    local grid = {}
    for y=1, 10 do
        grid[y] = {}
        for x=1, 10 do
            grid[y][x] = -1
        end
    end
    table.insert(grid, {"forest"})
    map = Tilemap(grid)

    love.keyboard.setKeyRepeat(true)

    gooi.setGroupVisible("editor", true)
end

function editor:leave()
    love.keyboard.setKeyRepeat(false)

    gooi.setGroupVisible("editor", false)
end

function editor:update(dt)
    if love.keyboard.isScancodeDown("space") then
        map.raw[y][x] = id
        map:autotile()
    end

    poslabel:setText(tostring(x) .. " , " .. tostring(y))
    idlabel:setText(id)
    g.camera:setPosition(math.floor((x-0.5)*60), math.floor((y-0.5)*60))
end

function editor:keypressed(key, scan, isrepeat)
    if scan == "w" then
        y=y-1
    end
    if scan == "s" then
        y=y+1
    end
    if scan == "a" then
        x=x-1
    end
    if scan == "d" then
        x=x+1
    end
    if scan == "left" then
        id=math.max(id-1, -1)
    end
    if scan == "right" then
        id=id+1
    end
    if scan == "escape" then
        Gamestate.switch(g.states.menu)
    end
    x, y = math.clamp(x, 1, map.width), math.clamp(y, 1, map.height)
end

function editor:draw()
    love.graphics.setColor(1, 1, 1)

    map:drawBg(g.camera:getVisible())
    g.camera:draw(function()
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle("fill", -1000, -1000, 1000, map.height*60+2000)
        love.graphics.rectangle("fill", map.width*60, -1000, 1000, map.height*60+2000)
        love.graphics.rectangle("fill", 0, -1000, map.width*60, 1000)
        love.graphics.rectangle("fill", 0, map.height*60, map.width*60, 1000)
        love.graphics.setColor(1,1,1)
        map:drawDebug(g.camera:getVisible())
        if showmap.checked then
            map:draw(g.camera:getVisible())
        end

        love.graphics.setColor(0,0,0)
        love.graphics.circle("fill", (x-0.5)*60, (y-0.5)*60, 2)
        love.graphics.setColor(1,1,1)
    end)

    gooi.draw("editor")
end

return editor