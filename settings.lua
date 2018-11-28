local TOML = require "thirdparty.lua-toml"

local g = require "global"

local defaultsFile = love.filesystem.read("default.toml")
local defaults = TOML.parse(defaultsFile)
local settingsFile = love.filesystem.read("settings.toml")
local settings = settingsFile and TOML.parse(settingsFile) or {}

local function default(d, t)
    for k, v in pairs(d) do
        if t[k] == nil then
            if type(v) == "table" then
                t[k] = {}
            else
                t[k] = v
            end
        end
        if type(t[k]) == "table" then
            default(v, t[k])
        end
    end
end

default(defaults, settings)

-- settings we can apply right now
local resolution = settings.video.resolution:gmatch("%d+")
local w, h = resolution(), resolution()
love.window.setMode(w, h, {
    borderless = settings.video.borderless,
    fullscreen = settings.video.fullscreen,
    fullscreentype = settings.video.fullscreentype,
    vsync = settings.video.vsync,
    msaa = settings.video.msaa, -- i'm not that much of a gamer but i think i've seen this setting in some games so i'll keep it?
    display = settings.video.display
})

-- internal settings we don't want in the settings file, thus we save in another table
g.game = {}
g.game.scale = love.graphics.getHeight()*settings.video.scale/(60*10)
g.game.mobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
g.game.touch = settings.controls.touch or g.game.mobile
g.game.unlocked = {}
g.game.abilities = {}

return settings