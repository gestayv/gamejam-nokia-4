-- Bullet class, manages Bullet logic duh
Bullet = Class{}

function Bullet:init(x, y, width, height, direction)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dx = 30     -- speed x axis
    self.direction = direction
    self.markForDeletion = false
    self.collider = world:newRectangleCollider(self.x, self.y, self.width - 1, self.height - 1, {mass = 0})
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
end

function Bullet:render()
    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
end 

function Bullet:destroy()
    self.collider:destroy()
end