local Class = require "thirdparty.hump.class"
local Creature = require "entities.Creature"

local anim8 = require "thirdparty.anim8"

local g = require "global"

local girlImage = g.assets.girl
local demonImage = g.assets.demon
local Player = Class{__includes = Creature,
    init = function(self, x, y)
        Creature.init(self, {
            name = "player",
            type = "player",
            x = x,
            y = y,
            bbox = {ox = -20, oy = -20, w = 40, h = 70},
            moveSpeed = 240,
            jumpStrength = 700,
            flying = false,
            health = 100
        })

        self.canAct = true
        self.terminalVelocity = g.world.terminalVelocity*1.75

        local imageGrid = anim8.newGrid(120, 120, girlImage:getWidth(), girlImage:getHeight())

        self.anim8.girlStill = anim8.newAnimation(imageGrid('1-2',1), 0.5)
        self.anim8.girlMoving = anim8.newAnimation(imageGrid('1-7',2, '1-7',3), 0.08)
        self.anim8.girlJumping = anim8.newAnimation(imageGrid('1-4',4), 0.1)
        self.anim8.girlFalling = anim8.newAnimation(imageGrid('5-8',4), 0.1)

        self.anim8.demonFalling = anim8.newAnimation(imageGrid('6-1',2,'6-1',1), 0.05, "pauseAtEnd")
        self.anim8.demonFalling:pauseAtEnd()
    end
}

function Player:reset(x, y)
    self:warp(x, y)
    self.anim8.demonFalling:pauseAtEnd()
end

local right = true
function Player:update(dt)
    -- movement
    self.dx, self.dy = 0, 0
    if g.controls.jump() and self.canAct then
        local action = self:getAction()
        if action then
            if action.id == "door" then
                table.foreach(action, print)
                g.world.changeMap(action.goal, action.mapx, action.mapy)
            elseif action.id == "action" then
                action:onJump(self)
            end
        else
            self:jump(dt)
        end
    end
    if g.controls.down() then
        -- crouch?
    end
    if g.controls.left() then
        right = false
        self:move(dt, "l")
    end
    if g.controls.right() then
        right = true
        self:move(dt, "r")
    end

    Creature.update(self, dt)

    -- animation stuff
    if self.actualSpeedY < g.world.terminalVelocity then -- if her speed is lower than the terminal velocity, play the animation (it's reversed)
        self.anim8.demonFalling:resume()
    else -- if her speed is higher than the terminal velocity, play the animation in reverse according to her velocity based on an arbitrary personal terminal velocity
        self.anim8.demonFalling:pause()
        -- the velocity used here is what she should be falling at if the world didn't have a terminal velocity
        local overflow = self.actualSpeedY-g.world.terminalVelocity -- -terminalVelocity because we only want speeds higher than that vel
        local limit = self.terminalVelocity-g.world.terminalVelocity -- -terminalVelocity because we only want speeds higher than that vel
        -- calculate which frame to show based on speed
        local demonFrame = math.floor(overflow/limit*11)+1
        demonFrame = 13-math.clamp(demonFrame, 1, 12)
        -- if it's reached the last frame, respawn (TODO: Don't restart the game)
        if self.anim8.demonFalling.position == 1 then Gamestate.switch(g.states.game) return end
        self.anim8.demonFalling:gotoFrame(demonFrame)
    end

    self:checkForEnemies()
end

function Player:checkForEnemies()
    for i = 1, #g.world.objects do
        local object = g.world.objects[i]
        if (not object.id) and object:distanceToPlayer() < 100 then
            --Gamestate.push(g.states.pause)
            break
        end
    end
end

function Player:getAction()
    for i = 1, #g.world.objects do
        local object = g.world.objects[i]
        if object.id then
            local x,y = self:getTilePos()
            if x == object.x and y == object.y and not (object.id == "entry") then
                return object
            end
        end
    end
    return nil
end

function Player:draw()
    if self.onGround then
        if self.moving.right or self.moving.left then
            self.anim8.girlMoving:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
        else
            self.anim8.girlStill:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
        end
    else
        -- different hats depending on whether she's going up or down
        if self.speedY < 0 then self.anim8.girlJumping:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
        else
            -- we don't wanna show the girl during the last frames of the demon's animation
            if self.anim8.demonFalling.position > 3 then self.anim8.girlFalling:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60) end
        end
    end
    self.anim8.demonFalling:draw(demonImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
end

return Player