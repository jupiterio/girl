local gamera = require "thirdparty.gamera"
local csv = require "lib.csv"
local gBuilder = require "lib.gesture.builder" -- debug
require "thirdparty.gooi" -- why do you global
Gamestate = require "thirdparty.hump.gamestate" -- *this* is something that should probably global
Timer = require "thirdparty.hump.timer" -- this too

local g = require "global"

function math.clamp(number, min, max)
    return math.min(math.max(number, min), max)
end

function love.load()
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.setDefaultFilter("nearest", "nearest")

    g.settings = require("settings")

    if not g.game.mobile then gooi.desktopMode() end
    local green = component.colors.green
    gooi.setStyle({
        tooltipFont = love.graphics.newFont(love.window.toPixels(14)),
        font = love.graphics.newFont(love.window.toPixels(16)),
        bgColor = {green[1], green[2], green[3], 0.5},
        fgColor = component.colors.white,
        tooltipFont = love.graphics.newFont(love.window.toPixels(14)), -- tooltips are smaller than the main font
        font = love.graphics.newFont(love.window.toPixels(16))
    })

    -- important libaries
    g.assets = require("thirdparty.cargo").init({
        dir = "assets",
        loaders = {
            csv = function(path) return csv.parse(love.filesystem.read(path)) end
        }
    })(true)
    g.controls = require "lib.controls"

    -- when making states don't need to add them to no table
    g.states = setmetatable({}, {__index = function(table, key) return require("states." .. key) end})

    -- prepare the physics world
    g.world = require "lib.world"
    g.world.init()
    g.player = require("entities.player")()

    -- start the camera
    g.camera = gamera.new(0, 0, 60*50, 60*50)
    g.camera:setScale(g.game.scale)

    -- start the game
    Gamestate.registerEvents()
    Gamestate.switch(g.states.menu)
end

function love.update(dt)
    gooi.update(dt)
    Timer.update(dt)
end

function love.mousepressed(x, y, button, istouch, presses) if not istouch then gooi.pressed() end end
function love.mousemoved(x, y, dx, dy, istouch) if not istouch then  gooi.moved() end end
function love.mousereleased(x, y, button, istouch, presses) if not istouch then  gooi.released() end end
function love.touchpressed(...) gooi.pressed(...) end
function love.touchmoved(...) gooi.moved(...) end
function love.touchreleased(...) gooi.released(...) end
function love.textinput(...) gooi.textinput(...) end
function love.keypressed(...) gooi.keypressed(...) end
function love.keyreleased(...) gooi.keyreleased(...) end