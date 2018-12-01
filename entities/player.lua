local Class = require "thirdparty.hump.class"
local Creature = require "entities.creature"

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
            health = 100,
            attackStrength = 10
        })

        self.terminalVelocity = g.world.terminalVelocity*1.75

        local bigGrid = anim8.newGrid(120, 120, girlImage:getWidth(), girlImage:getHeight())
        local smallGrid = anim8.newGrid(60, 60, girlImage:getWidth(), girlImage:getHeight())

        self.anim8.still = anim8.newAnimation(bigGrid('1-2',1), 0.5)
        self.anim8.moving = anim8.newAnimation(bigGrid('1-7',2, '1-7',3), 0.08)
        self.anim8.jumping = anim8.newAnimation(bigGrid('1-4',4), 0.1)
        self.anim8.falling = anim8.newAnimation(bigGrid('5-8',4), 0.1)
        self.anim8.hurt = anim8.newAnimation(bigGrid('1-4',5), 0.1)

        self.anim8.ballRolling = anim8.newAnimation(smallGrid('13-16',1), 0.1)

        self.anim8.demonFalling = anim8.newAnimation(bigGrid('6-1',2,'6-1',1), 0.05, "pauseAtEnd")
        self.anim8.demonFalling:pauseAtEnd()

        self.state = "girl"
    end
}

function Player:reset(x, y)
    self:warp(x, y)
    self.anim8.demonFalling:pauseAtEnd()
    self:changeState("girl")
end

function Player:changeState(state)
    if state == "girl" then
        self.bbox = {ox = -20, oy = -20, w = 40, h = 70}
        self.moveSpeed = 240
        self.jumpStrength = 700
        self.attackStrength = 10
        if self.state ~= "girl" then
            g.assets.sfx.ball2:stop()
            g.assets.sfx.ball2:play()
            self.y = self.y-30
        end
    elseif state == "ball" then
        g.assets.sfx.ball1:stop()
        g.assets.sfx.ball1:play()
        self.bbox = {ox = -20, oy = -20, w = 40, h = 40}
        self.moveSpeed = 300
        self.jumpStrength = 350
        self.attackStrength = 0
    end
    self.state = state
end

local lastdoor = {}
local right = true
function Player:onUpdate(dt)
    local action = self:getAction()
    -- movement
    self.dx, self.dy = 0, 0
    if g.controls.jump() then
        if action then -- if player's in an action
            if action.id == "door" then
                -- if it's a door, change map
                g.world.changeMap(action.goal, action.mapx, action.mapy)
                lastdoor = action
            elseif action.id == "action" then
                -- if it's an action, and there's an :onJump method, call it
                -- else jump
                if action.onJump then
                    action:onJump()
                else
                    self:jump()
                end
            end
        else
            self:jump()
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
        -- if it's reached the last frame, respawn
        if self.anim8.demonFalling.position == 1 then self:kill() return end
        self.anim8.demonFalling:gotoFrame(demonFrame)
    end

    if action and action.id == "action" and
        action.onTouched and not action.touched then
        -- if player is in an action, and action hasn't been touched before,
        -- call :onTouched()
        action:onTouched()
        action.touched = true
    end
end

function Player:getAction()
    for i = 1, #g.world.map.objects do
        local object = g.world.map.objects[i]
        local x,y = self:getTilePos()
        if x == object.x and y == object.y and (object.id == "door" or object.id == "action") then
            return object
        end
    end
    return nil
end

function Player:onKilled()
    self.health = 100
    g.world.changeMap(lastdoor.goal, lastdoor.mapx, lastdoor.mapy)
end

function Player:draw()
    if self.immune and not self.canAct then
        love.graphics.setColor(1,0.75,0.75)
        self.anim8.hurt:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
        love.graphics.setColor(1,1,1)
    elseif self.state == "girl" then
        if self.onGround then
            if self.moving.right or self.moving.left then
                self.anim8.moving:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
            else
                self.anim8.still:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
            end
        else
            -- different hats depending on whether she's going up or down
            if self.speedY < 0 then self.anim8.jumping:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
            else
                -- we don't wanna show the girl during the last frames of the demon's animation
                if self.anim8.demonFalling.position > 3 then self.anim8.falling:draw(girlImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60) end
            end
        end
    elseif self.state == "ball" then
        self.anim8.ballRolling:draw(demonImage, self.x, self.y, 0, right and 1 or -1, 1, 30, 30)
    end

    self.anim8.demonFalling:draw(demonImage, self.x, self.y, 0, right and 1 or -1, 1, 60, 60)
end

return Player