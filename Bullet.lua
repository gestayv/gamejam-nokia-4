-- Bullet class, manages Bullet logic duh
Bullet = Class{}

function Bullet:init(x, y, width, height, direction, attack)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dx = 30     -- speed x axis
    self.direction = direction
    self.attack = attack
    self.markForDeletion = false
    self.collider = world:newRectangleCollider(self.x, self.y, self.width - 2, self.height)
    self.collider:setCollisionClass('Player Projectile')
    self.collider:setGravityScale(0)
    self.collider:setObject(self)
end

function Bullet:update(dt)
    local vx = self.dx * self.direction

    self.collider:setLinearVelocity(vx, 0)
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    if self.collider:enter('Solid') then
        self.markForDeletion = true
    end
    if self.collider:enter('Enemy') then
        local collisionData = self.collider:getEnterCollisionData('Enemy')
        local enemy = collisionData.collider:getObject()
        if enemy then
            enemy:takeDamage(self.attack)
        end

        self.markForDeletion = true
    end
end

function Bullet:render()
    local x = math.floor(self.x - self.width/2 + 0.5)
    local y = math.floor(self.y - self.height/2 + 0.5)
    love.graphics.setDarkColor()
    love.graphics.rectangle("fill", x+1, y, 2, 1)
    love.graphics.rectangle("fill", x+1, y+2, 2, 1)
    love.graphics.rectangle("fill", x, y+1, 1, 1)
    love.graphics.rectangle("fill", x+3, y+1, 1, 1)
    
    love.graphics.setLightColor()
    love.graphics.rectangle("fill", x+1, y+1, 2, 1)
end 

function Bullet:destroy()
    self.collider:destroy()
end