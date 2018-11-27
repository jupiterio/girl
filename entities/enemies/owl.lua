local Class = require "thirdparty.hump.class"
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
            bbox = {ox = -20, oy = -20, w = 40, h = 40},
            moveSpeed = 240,
            jumpStrength = 700,
            ghost = true,
            health = 20
        })

        local imageGrid = anim8.newGrid(60, 60, owlImage:getWidth(), owlImage:getHeight())

        self.anim8.still = anim8.newAnimation(imageGrid("1-2",1), 0.5)
        --self.anim8.moving = anim8.newAnimation(imageGrid("1-6",2), 0.1)

        self.facingRight = math.random(1,2) == 1
        self.seenPlayer = false
    end
}

function Owl:update(dt)
    self.dx, self.dy = 0, 0
    if self:distanceToPlayer() < 60*4 and not self.seenPlayer then
        self.seenPlayer = true
        self.facingRight = self.x < g.player.x
        self.timer:tween(1, self, {y = self.y-60*3}, "in-out-quad")
        self.timer:after(1, function()
            self.timer:tween(1, self, {x = g.player.x, y = g.player.y}, "in-out-quad")
        end)
    end

    Creature.update(self, dt)
end

function Owl:draw()
    self.anim8.still:draw(owlImage, self.x, self.y, 0, self.facingRight and 1 or -1, 1, 30, 30)
end

return Owl