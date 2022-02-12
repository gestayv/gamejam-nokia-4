Hud = Class{}

function Hud:init()
    self.heart = love.graphics.newImage("/sprites/player_spritesheet.png")
    self.quad = love.graphics.newQuad(0, 16, 8, 8, self.heart:getDimensions())
    self.healthBarSize = 50
    self.currentLife = self.healthBarSize * player.health/player.maxHealth
end


function Hud:update(dt)
    self.currentLife = self.healthBarSize * player.health/player.maxHealth
end

function Hud:render()
    love.graphics.setDarkColor()
    love.graphics.rectangle("fill", 8, 4, self.currentLife, 2)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.heart, self.quad, 1, 1)
end