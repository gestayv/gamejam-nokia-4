Text = Class{}

function Text:init(x, y, text, targetX, targetY, seconds, centering, width)
    self.x = x
    self.y = y
    self.startingX = x
    self.startingY = y
    self.text = text
    self.endX = targetX
    self.endY = targetY
    self.seconds = seconds
    self.animationTime = 0
    self.centering = centering or 'left'
    self.width = width or 40
    self.alive = true
end

function Text:update(dt)
    local time = self.animationTime / self.seconds
    self.x = self.startingX + bezier_blend(time) * (self.endX - self.startingX)
    self.y = self.startingY + bezier_blend(time) * (self.endY - self.startingY)

    self.animationTime = self.animationTime + dt
    if self.animationTime >= self.seconds then
        self.alive = false
    end
end

function Text:render()
    love.graphics.setDarkColor()
    love.graphics.printf(self.text, self.x, self.y, self.width, self.centering)
    love.graphics.setColor(255, 255, 255)
end

function Text:destroy()
end
