-- Player class, manages player logic duh
Player = Class{}

GRAVITY = 40
JUMP_SPEED = 50

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dy = 5     -- speed y axis
    self.dx = 50     -- speed x axis
    self.collider = world:newRectangleCollider(self.x, self.y, 8, 8)
    self.collider:setFixedRotation(true)
end

function Player:update(dt)
    -- TODO: solo poder saltar una vez
    local vx = 0
    local vy = 0
    if love.keyboard.isDown("left", "a") then
        vx = -1 * self.dx
    elseif love.keyboard.isDown("right", "d") then
        vx = self.dx
    end

    if love.keyboard.isDown("up", "w") then
        vy = self.dy * -JUMP_SPEED
    end

    self.collider:setLinearVelocity(vx, vy)
    self.x = math.floor(self.collider:getX())
    self.y = math.floor(self.collider:getY())
end

function Player:render()
    love.graphics.setColor(67/255, 82/255, 61/255, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(255,255,255)
end