local Class = require "thirdparty.hump.class"
local Vector = require "thirdparty.hump.vector-light"
local Creature = require "entities.Creature"

local anim8 = require "thirdparty.anim8"

local g = require "global"

-- Barn Owl!
-- Takes off and kamikazes when the player gets close. Touching it damages the player
local owlImage = g.assets.owl
local Owl = Class{__includes = Creature,
    init = function(self, x, y)
        Creature.init(self, {
            type = "Owl",
            x = x,
            y = y,
            bbox = {ox = -15, oy = -15, w = 30, h = 30},
            moveSpeed = 240,
            jumpStrength = 700,
            ghost = true,
            health = 20,
            attackStrength = 10
        })

        local smallGrid = anim8.newGrid(60, 60, owlImage:getWidth(), owlImage:getHeight())
        local bigGrid = anim8.newGrid(60, 120, owlImage:getWidth(), owlImage:getHeight())

        self.anim8.still = anim8.newAnimation(smallGrid("1-2",1), 0.5)
        self.anim8.takingOff = anim8.newAnimation(smallGrid("1-3",2), 0.05, "pauseAtEnd")
        self.anim8.takingOff:pauseAtEnd()
        self.anim8.diving = anim8.newAnimation(bigGrid("4-7",1), 0.1)
        self.anim8.hurt = anim8.newAnimation(bigGrid("1-4",2), 0.1)

        self.facingRight = math.random(1,2) == 1
        self.seenPlayer = false
        self.diving = false
        self.angle = 0
    end
}

function Owl:onUpdate(dt)
    self.dx, self.dy = 0, 0
    if self:distanceToPlayer() < 60*4 and not self.seenPlayer then
        self.seenPlayer = true
        local px, py = g.player.x, g.player.y+30
        self.facingRight = self.x < px
        self.angle = Vector.toPolar(self.x-px, self.y-py) + math.pi/2

        self.anim8.takingOff:gotoFrame(1)
        self.anim8.takingOff:resume()

        self.timer:tween(1, self, {y = self.y-60*3}, "in-out-quad")
        self.timer:after(1, function()
            self.diving = true
            self.timer:tween(1, self, {x = px, y = py}, "in-out-quad")
        end)
        self.timer:after(2, function()
            self.diving = false
            self.seenPlayer = false
        end)
    end
end

function Owl:draw()
    if self.immune then
        love.graphics.setColor(1,0.75,0.75)
        self.anim8.hurt:draw(owlImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 30, 60)
    elseif self.diving then
        self.anim8.diving:draw(owlImage, self.x, self.y, self.angle, self.facingRight and 1 or -1, 1, 30, 60)
    elseif self.seenPlayer then
        self.anim8.takingOff:draw(owlImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 30, 30)
    else
        self.anim8.still:draw(owlImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 30, 30)
    end
    love.graphics.setColor(1,1,1)
end

return Owl