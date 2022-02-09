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
    self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
    self.collider:setCollisionClass('Player_Projectile')
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
    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
end 

function Bullet:destroy()
    self.collider:destroy()
end