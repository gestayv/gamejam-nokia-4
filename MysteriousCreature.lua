MysteriousCreature = Class{}

function MysteriousCreature:init(x, y)
    self.x = x + 3
    self.y = y
    self.width = 24
    self.height = 32
    self.spriteSheet = love.graphics.newImage('/sprites/mysterious.creature.png')
    self.grid = anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.anim = anim8.newAnimation(self.grid('1-4', 1), 0.5)
    self.alive = true
end

function MysteriousCreature:update(dt)
    self.anim:update(dt)
end

function MysteriousCreature:render()
    self.anim:draw(self.spriteSheet, self.x, self.y)
end

function MysteriousCreature:destroy()
end
