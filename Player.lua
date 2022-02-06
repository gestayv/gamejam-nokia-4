-- Player class, manages player logic duh
Player = Class{}

GRAVITY = 4

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dy = 5     -- speed y axis
    self.dx = 30     -- speed x axis
end

function Player:update(dt)
    self.dy = self.dy + GRAVITY * dt
    
    if love.keyboard.isDown("left", "a") then
        self.x = self.x - (self.dx * dt);
    elseif love.keyboard.isDown("right", "d") then
        self.x = self.x + self.dx * dt;
    end

    if love.keyboard.isDown("up", "w") then
        self.dy = -1
        self.y = self.y - self.dy * dt;
    elseif love.keyboard.isDown("down", "s") then
        self.y = self.y + self.dy * dt;
    end

    self.y = self.y + self.dy
end

function Player:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end