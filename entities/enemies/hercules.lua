local Class = require "thirdparty.hump.class"
local Creature = require "entities.Creature"

local anim8 = require "thirdparty.anim8"

local g = require "global"

-- Hercules Beetle!
-- It just follows the player. Can't really jump. Touching it damages the player.
local herculesImage = g.assets.hercules
local Hercules = Class{__includes = Creature,
    init = function(self, x, y)
        Creature.init(self, {
            type = "Hercules",
            x = x,
            y = y,
            bbox = {ox = -75, oy = -20, w = 150, h = 40},
            moveSpeed = 120,
            jumpStrength = 350,
            flying = false,
            health = 20,
            attackStrength = 10
        })

        local imageGrid = anim8.newGrid(180, 60, herculesImage:getWidth(), herculesImage:getHeight())

        self.anim8.herculesStill = anim8.newAnimation(imageGrid('1-2',1), 0.5)
        self.anim8.herculesMoving = anim8.newAnimation(imageGrid('1-6',2), 0.1)

        self.facingRight = true
    end
}

function Hercules:update(dt)
    local distance = self:distanceToPlayer()
    self.dx, self.dy = 0, 0
    if distance > 60*5 then
        self.moveSpeed = 120
        if not (self.moving.right or self.moving.left) then
            self.facingRight = not self.facingRight
        end
    elseif distance > 30 then
        self.moveSpeed = 180
        if math.abs(g.player.x - self.x) > math.random(30, 100) then
            self.facingRight = g.player.x > self.x
        end
        if not (self.moving.right or self.moving.left) then
            self:jump(dt)
        end
    end
    self:move(dt, self.facingRight and "r" or "l")

    Creature.update(self, dt)
end

function Hercules:draw()
    if self.onGround then
        if self.moving.right or self.moving.left then
            self.anim8.herculesMoving:draw(herculesImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 90, 30)
        else
            self.anim8.herculesStill:draw(herculesImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 90, 30)
        end
    else
        self.anim8.herculesStill:draw(herculesImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 90, 30)
    end
end

return Hercules