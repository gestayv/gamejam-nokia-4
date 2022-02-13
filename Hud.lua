Hud = Class{}

function Hud:init()
    self.lifeIcon = love.graphics.newImage("/sprites/player_spritesheet.png")
    self.quad = love.graphics.newQuad(0, 16, 8, 8, self.lifeIcon:getDimensions())
    self.healthBarSize = 50
    self.currentLife = self.healthBarSize * player.health/player.maxHealth
end


function Hud:update(dt)
    self.currentLife = self.healthBarSize * player.health/player.maxHealth
end

function Hud:render()
    love.graphics.setDarkColor()
    love.graphics.rectangle("fill", 8, 4, self.currentLife, 2)
    love.graphics.resetColor()
    love.graphics.draw(self.lifeIcon, self.quad, 1, 1)
end