local Class = require "thirdparty.hump.class"
local Creature = require "entities.creature"

local anim8 = require "thirdparty.anim8"

local g = require "global"

-- Star-Nosed Mole!
-- Sleeps. When it hears the player approach, it startles and launches to the direction of the player
local moleImage = g.assets.mole
local Mole = Class{__includes = Creature,
    init = function(self, x, y)
        Creature.init(self, {
            type = "Mole",
            x = x,
            y = y,
            bbox = {ox = -50, oy = -20, w = 100, h = 40},
            moveSpeed = 240,
            jumpStrength = 500,
            health = 20,
            attackStrength = 10
        })

        local imageGrid = anim8.newGrid(120, 60, moleImage:getWidth(), moleImage:getHeight())

        self.anim8.still = anim8.newAnimation(imageGrid("1-2",1), 0.5)
        self.anim8.sleeping = anim8.newAnimation(imageGrid("3-5",1), 0.5)
        self.anim8.startled = anim8.newAnimation(imageGrid(6,1), math.huge)
        self.anim8.launch = anim8.newAnimation(imageGrid("1-4",2), 0.1)
        self.anim8.hurt = anim8.newAnimation(imageGrid("1-4",3), 0.1)

        self.facingRight = math.random(1,2) == 1
        self.heardPlayer = false
        self.launching = false
        self.woke = false
    end
}

function Mole:onUpdate(dt)
    local pWalking = g.player.onGround and (g.player.moving.left or g.player.moving.right)
    self.dx, self.dy = 0, 0
    if self:distanceToPlayer() < 60*3 and pWalking and
       not self.woke and not self.heardPlayer then

        self.woke = true
        self.heardPlayer = true
        self.facingRight = self.x < g.player.x

        self:jump()

        self.timer:after(0.75, function()
            self.launching = true
            self:jump()
        end)
    end
    if self.launching then
        if self.onGround then
            self.launching = false
            self.heardPlayer = false
            self.timer:after(0.5, function()
                self.facingRight = not self.facingRight
            end)
            self.timer:after(1, function()
                self.facingRight = not self.facingRight
            end)
            self.timer:after(1.5, function()
                self.woke = false
            end)
        else
            self:move(dt, self.facingRight and "r" or "l")
        end
    end
end

function Mole:draw()
    if self.immune then
        love.graphics.setColor(1,0.75,0.75)
        self.anim8.hurt:draw(moleImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 60, 30)
    elseif self.launching then
        self.anim8.launch:draw(moleImage, self.x, self.y, self.angle, self.facingRight and 1 or -1, 1, 60, 30)
    elseif self.heardPlayer then
        self.anim8.startled:draw(moleImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 60, 30)
    elseif self.woke then
        self.anim8.still:draw(moleImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 60, 30)
    else
        self.anim8.sleeping:draw(moleImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 60, 30)
    end
    love.graphics.setColor(1,1,1)
end

return Mole