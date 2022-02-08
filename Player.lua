-- Player class, manages player logic duh
require "Bullet"
require "Pet"
Player = Class{}

INITIAL_JUMP_FORCE = -60
JUMP_FORCE = -40
HORIZONTAL_FORCE = 30
BULLET_WIDTH = 2
BULLET_HEIGHT = 2
MAX_MOVEMENT_SPEED = 30
MAX_FALL_SPEED = 80
MAX_JUMP_SPEED = -40
-- TO DO: Move these constants into the class itself
-- to be able to updgrade movement speed

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.bullets = {}
    self._fireRate = 1
    self.fireRateMod = 0
    self.timeSinceLastShot = 0
    self.directionX = 1
    self.collider = world:newRectangleCollider(self.x, self.y, 8, 8)
    self.collider:setFixedRotation(true)
    self.collider:setFriction(0)
    self.collider:setCollisionClass('Player')
    self.jumpable = false
    self.jumping = false
    self.airTime = 0

    self.pet = Pet()

    -- Player stats
    self.baseHealth = 5
    self.maxHealth = self.baseHealth
    self.health = self.maxHealth
    self.attack = 1

    self.collider:setPreSolve(function(collider_1, collider_2, contact)        
    if collider_1.collision_class == 'Player' and (collider_2.collision_class == 'Solid' or collider_2.collision_class == 'Enemy') then
        local tx1, ty1, tx2, ty2 = collider_2:getBoundingBox()
        -- Check if player is colliding with top of solid collider to enable jump
        if self.y + self.height/2 < ty1 and vy >= 0 then 
            self.jumpable = true
            self.airTime = 0
        end
        --elseif py + ph/2 > ty + th then self.jumping = false end
        end   
    end)
  
    self.collider:setObject(self)
end

function Player:update(dt)
    self:movementUpdate(dt)
    self:fireUpdate(dt)
    self.pet:update(dt)
end

function Player:render()
    love.graphics.setColor(67/255, 82/255, 61/255, 1)

    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
    for key, bullet in pairs(self.bullets) do
        bullet:render()
    end

    if not self:canFire() then
        -- love.graphics.setColor(199/255, 240/255, 216/255, 1)
        -- love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height + 0.5), self.width, 3)

        love.graphics.setColor(67/255, 82/255, 61/255, 1)
        fillPercent = self.timeSinceLastShot / self:fireRate()
        love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5 ), math.floor(self.y - self.height + 2 + 0.5), (self.width) * fillPercent, 1)
    end

    love.graphics.setColor(255,255,255)
end

function Player:fire()
    if self:canFire() then
        bullet = Bullet(self.x, self.y, BULLET_WIDTH, BULLET_HEIGHT, self.directionX)
        table.insert(self.bullets, bullet)
        self.timeSinceLastShot = 0
    end
end

function Player:fireRate()
    return (self._fireRate + self.fireRateMod) 
end

function Player:canFire()
   return self.timeSinceLastShot >= 1 / self:fireRate()
end

function Player:canJump()
    return self.jumpable
end

function Player:movementUpdate(dt)
    local fx = 0
    local fy = 0
    vx, vy = self.collider:getLinearVelocity()
    if love.keyboard.isDown("left", "a") then
        self.directionX = -1
        fx = -1 * HORIZONTAL_FORCE
    elseif love.keyboard.isDown("right", "d") then
        self.directionX = 1
        fx = HORIZONTAL_FORCE
    end
    if love.keyboard.wasReleased("left", "a", "right", "d") then
        vx = 0
    end

    if love.keyboard.wasPressed("up", "w") and self:canJump() then
        fy = INITIAL_JUMP_FORCE
        self.jumping = true
        self.jumpable = false
    end
    if love.keyboard.wasReleased("up", "w") then
        self.jumping = false
        self.airTime = 0
    end
    if self.jumping then
        self.airTime = self.airTime + dt
        
        fy = (JUMP_FORCE) + math.exp(3 * self.airTime) - 1
        --self.dy = self.dy * 0.9 -- damping
        if vy <= MAX_JUMP_SPEED then
            self.jumping = false
            vy = MAX_JUMP_SPEED
        end
    end
    
    -- limit fall speed
    if vy > MAX_FALL_SPEED then
        vy = MAX_FALL_SPEED
    end
    -- limit horizontal speed
    if vx > MAX_MOVEMENT_SPEED then
        vx = MAX_MOVEMENT_SPEED
    elseif vx < -MAX_MOVEMENT_SPEED then
        vx = -MAX_MOVEMENT_SPEED
    end

    self.collider:applyForce(fx, fy)
    self.collider:setLinearVelocity(vx, vy) -- Bound velocity
    self.x = self.collider:getX()
    self.y = self.collider:getY()
    
    -- Desactivate jump when leaving a block to disable
    -- jumping after dropping down the ground
    if self.collider:exit('Solid') or self.collider:exit('Enemy') then
        self.jumpable = false
    end
end

function Player:fireUpdate(dt)
    
    if love.keyboard.wasPressed("space") then
        self:fire()
    end

    for key, bullet in pairs(self.bullets) do
        bullet:update(dt)
    end
    for key, bullet in pairs(self.bullets) do
        if bullet.markForDeletion then
            bullet:destroy()
            table.remove(self.bullets, key)
        end
    end
    self.timeSinceLastShot = self.timeSinceLastShot + dt
    self.fireRateMod = self.pet:getBuff('fireRate')
end

-- Battle functions
function Player:damage()
    return self.attack + self.pet:getBuff('damage')
end

function Player:healthUpdate()
    local newHealth = self.baseHealth + self.pet:getBuff('health')
    local healthDiff = newHealth - self.maxHealth

    self.maxHealth = newHealth

    if self.health + healthDiff > 0 then
        self.health = self.health + healthDiff
    else 
        self.health = 1
    end
end