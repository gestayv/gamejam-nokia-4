-- Player class, manages player logic duh
require "Bullet"
Player = Class{}

JUMP_SPEED = -500
BULLET_WIDTH = 2
BULLET_HEIGHT = 2

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dx = 50     -- speed x axis
    self.bullets = {}
    self.shootsPerSecond = 1
    self.shootsPerSecondMod = 1
    self.timeSinceLastShot = 0
    self.directionX = 1
    self.collider = world:newRectangleCollider(self.x, self.y, 8, 8)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Player')
    self.jumpable = false

    self.collider:setPreSolve(function(collider_1, collider_2, contact)        
    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Solid' then
        local px, py = collider_1:getPosition()            
        local pw, ph = self.width, self.height
        local tx, ty = collider_2:getPosition()            
        local tx1, ty2, tx2, ty2 = collider_2:getBoundingBox() 
        local tw, th = tx2 - tx, ty2 - ty
        -- Check if player is colliding with top of solid collider to enable jump
        if py + ph/2 < ty - th then self.jumpable = true end
        end   
    end)
  
    self.collider:setObject(self)
end

function Player:update(dt)
    -- TODO: solo poder saltar una vez
    local vx = 0
    local vy = 0
    if love.keyboard.isDown("left", "a") then
        self.directionX = -1
        vx = -1 * self.dx
    elseif love.keyboard.isDown("right", "d") then
        self.directionX = 1
        vx = self.dx
    end

    if love.keyboard.isDown("up", "w") and self:canJump() then
        vy = JUMP_SPEED
        self.jumpable = false
    end

    if love.keyboard.isDown("space") then
        self:shoot()
    end

    self.collider:setLinearVelocity(vx, vy)
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    for key, bullet in pairs(self.bullets) do
        bullet:update(dt)
        if bullet.markForDeletion then
            bullet:destroy()
            table.remove(self.bullets, key)
        end
    end
    self.timeSinceLastShot = self.timeSinceLastShot + dt
    
    -- Desactivate jump when leaving a block to disable
    -- jumping after dropping down the ground
    if self.collider:exit('Solid') then
        self.jumpable = false
    end
end

function Player:render()
    love.graphics.setColor(67/255, 82/255, 61/255, 1)

    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
    for key, bullet in pairs(self.bullets) do
        bullet:render()
    end

    love.graphics.setColor(255,255,255)
end

function Player:shoot()
    if self:canShoot() then
        bullet = Bullet(self.x, self.y, BULLET_WIDTH, BULLET_HEIGHT, self.directionX)
        table.insert(self.bullets, bullet)
        self.timeSinceLastShot = 0
    end
end

function Player:canShoot()
   return self.timeSinceLastShot >= 1 / (self.shootsPerSecond * self.shootsPerSecondMod) 
end

function Player:canJump()
    return self.jumpable
end

function Player:changeShootRate(mod)
    self.shootsPerSecondMod = mod
end