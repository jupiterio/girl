function love.conf(t)
    t.identity = nil -- save dir
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean) 
    t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)

    t.window.title = "CoolMathGames"    -- The window title (string)
    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)-- thi

    t.window.highdpi = true -- need to check on a mac what this does to my game
 
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false -- I won't use joysticks due to the gesture mechanic
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
end