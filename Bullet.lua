-- Bullet class, manages Bullet logic duh
Bullet = Class{}

function Bullet:init(x, y, width, height, direction)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dx = 30     -- speed x axis
    self.direction = direction
    self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
end

function Bullet:update(dt)
    local vx = self.dx * self.direction

    self.collider:setLinearVelocity(vx, -10)
    self.x = math.floor(self.collider:getX())
    self.y = math.floor(self.collider:getY())

    -- self.x = self.x + self.direction * self.dx * dt
end

function Bullet:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end