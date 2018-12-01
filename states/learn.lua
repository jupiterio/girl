local learn = {}

local detection = require "lib.gesture.detection"
local shapes = require "lib.gesture.shapes"

local g = require "global"

local indications = {
    ball = {
        "You've learnt the ball ability!",
        "Draw a circle " .. (g.game.touch and "using your finger" or "using the mouse") ..
        " starting from the top and you'll transform into a ball that can fit in small spaces"
    },
    airjump = {
        "You've learnt the air jump!",
        "Draw a sideways s " .. (g.game.touch and "using your finger" or "using the mouse") ..
        " starting from the left and you'll do a jump in the air"
    }
}

function learn:learn(state)
    self.state = state
    for k,v in ipairs(shapes) do
        if v.name == state then
            self.shape = v.points
            break
        end
    end

    self.text = indications[state]
    if self.text and self.shape then
        local result = {}
        for k,v in ipairs(self.shape) do
            result[k] = {}
            result[k].x = love.graphics.getWidth()/2 + v.x*g.game.scale/g.settings.video.scale
            result[k].y = love.graphics.getHeight()/2 + v.y*g.game.scale/g.settings.video.scale
        end
        self.shape = result
        Gamestate.push(g.states.learn)
    else
        print(state .. " doesn't exist. What are you trying to learn?")
    end
end

function learn:enter()
    self.pressed = false
    self.index = 1
    self.length = 2
end

function learn:update(dt)
    if g.controls.jump() and not self.pressed then
        self.pressed = true
        self.index = self.index + 1
        if self.index == #self.text+1 then
            Gamestate.pop()
            g.game.abilities[self.state] = true
        end
    end

    if not g.controls.jump() and self.pressed then
        self.pressed = false
    end

    self.length = self.length + 50*dt
    if self.length > #self.shape then
        self.length = 2
    end
end

function learn:draw()
    love.graphics.setShader(g.assets.shaders.sepia)
    g.states.game:draw(true)
    love.graphics.setShader()

    detection.drawStroke(self.shape, math.floor(self.length))
    love.graphics.setColor(0,0,0)
    love.graphics.printf(self.text[self.index], 50, 50, love.graphics.getWidth()-100, "center")
    love.graphics.setColor(1,1,1)

    gooi.draw("game")
end

return learn