-- Player class, manages player logic duh
require "Bullet"
Player = Class{}

JUMP_SPEED = 50

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dx = 50     -- speed x axis
    self.dy = 5     -- speed y axis
    self.bullets = {}
    self.shootsPerSecond = 1
    self.shootsPerSecondMod = 1
    self.timeSinceLastShot = 0
    self.directionX = 1
    self.collider = world:newRectangleCollider(self.x, self.y, 8, 8)
    self.collider:setFixedRotation(true)
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

    if love.keyboard.isDown("up", "w") then
        vy = self.dy * -JUMP_SPEED
    end

    if love.keyboard.isDown("space") then
        self:shoot()
    end

    self.collider:setLinearVelocity(vx, vy)
    self.x = math.floor(self.collider:getX())
    self.y = math.floor(self.collider:getY())

    for key, bullet in pairs(self.bullets) do
        bullet:update(dt)
    end
    self.timeSinceLastShot = self.timeSinceLastShot + dt
end

function Player:render()
    love.graphics.setColor(67/255, 82/255, 61/255, 1)

    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    for key, bullet in pairs(self.bullets) do
        bullet:render()
    end

    love.graphics.setColor(255,255,255)
end

function Player:shoot()
    if self:canShoot() then
        bullet = Bullet(self.x, self.y, 2, 2, self.directionX)
        table.insert(self.bullets, bullet)
        self.timeSinceLastShot = 0
    end
end

function Player:canShoot()
   return self.timeSinceLastShot >= 1 / (self.shootsPerSecond * self.shootsPerSecondMod) 
end

function Player:changeShootRate(mod)
    self.shootsPerSecondMod = mod
end