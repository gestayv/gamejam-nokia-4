-- Player class, manages player logic duh
Player = Class{}

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.dy = 0     -- speed y axis
    self.dx = 0     -- speed x axis
end

function Player:update(dt)
end

function Player:render()
end