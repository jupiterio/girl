local Class = require("thirdparty.hump.class")

local g = require "global"

local Creature = Class{
    init = function(self, options)
        self.name = options.name or tostring(math.random(99999999))
        self.type = options.type or "creature"
        self.x = options.x or 0
        self.y = options.y or 0
        self.bbox = options.bbox or {ox = -1/2, oy = -1/2, w = 1, h = 1}
        self.moveSpeed = options.moveSpeed or 240
        self.health = options.health or 100
        self.moving = {}

        self.ghost = options.ghost or false
        self.flying = self.ghost or options.flying or false

        if not self.flying then
            self.jumpStrength = options.jumpStrength or 700
            self.speedY = 0
            self.actualSpeedY = 0

            self.onGround = false
        end

        self.anim8 = {}
    end
}

function Creature:warp(x, y)
    -- self.collider:moveTo(x, y)
    self.x = x
    self.y = y
    if not self.flying then
        self.actualSpeedY = 0
        self.speedY = 0
    end
    self.dx = 0
    self.dy = 0
end

function Creature:jump(dt)
    if not self.flying and self.onGround then
        self.actualSpeedY = -self.jumpStrength
        self.onGround = false
    end
end

function Creature:move(dt, direction)
    if self.flying and direction == "u" then
        self.dy = self.dy + -self.moveSpeed * dt
    elseif self.flying and direction == "d" then
        self.dy = self.dy + self.moveSpeed * dt
    elseif direction == "l" then
        self.dx = self.dx + -self.moveSpeed * dt
    elseif direction == "r" then
        self.dx = self.dx + self.moveSpeed * dt
    end
end

function Creature:getTilePos()
    return math.floor(self.x/60)+1, math.floor(self.y/60)+1
end

function Creature:update(dt)
    -- gravity
    if not self.flying then
        self.actualSpeedY = self.actualSpeedY + g.world.gravity * dt -- this doesn't have a speed limit
        self.speedY = math.min(self.actualSpeedY, g.world.terminalVelocity) -- this does. this is what we use to move the Creature
        self.dy = self.speedY * dt -- apply the limited speed
    end

    -- collision
    local oldx, oldy = self.x, self.y
    local newx, newy, resolved
    if self.ghost then
        newx, newy, resolved = self.x + self.dx, self.y + self.dy, {}
    else
        newx, newy, resolved = g.world.move(self, self.dx, self.dy)
    end

    if not self.flying then
        if resolved.bottom then
            self.onGround = true
            self.actualSpeedY = 0
        elseif resolved.top then
            self.onGround = false
            self.actualSpeedY = 0
        elseif math.abs(self.actualSpeedY) > 500 then
            self.onGround = false
        end
    end
    self.moving.up    = newy < oldy
    self.moving.down  = newy > oldy
    self.moving.left  = newx < oldx
    self.moving.right = newx > oldx

    self.x = newx
    self.y = newy

    for _,animation in pairs(self.anim8) do
        animation:update(dt)
    end
end

function Creature:draw() end -- dummy function

function Creature:drawBbox()
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line", self.x + self.bbox.ox, self.y + self.bbox.oy, self.bbox.w, self.bbox.h)
    love.graphics.circle("fill", self.x, self.y, 2)
    love.graphics.setColor(1,1,1)
end

function Creature:destroy() -- remove all references to other things basically, just to make sure
    if self.onDestroyed then self:onDestroyed() end
    for k in pairs(self) do
        self[k] = nil
    end
    self.destroyed = true
end

function Creature:distanceToPlayer()
    return math.sqrt((g.player.x - self.x)*(g.player.x - self.x) + (g.player.y - self.y)*(g.player.y - self.y))
end

return Creature