local credits = {}

function credits:enter(from)
    self.from = from
    self.topY = VIRTUAL_HEIGHT
    self.credits = {
        "Thank you",
        "for playing",
        "",
        "",
        "",
        "",
        "Credits",
        "The man",
        "The other man",
        "The another man",
        "",
        "",
        "",
        "Nokia sound font",
        "",
        "Nokia sound pack",
        "",
        "Nokia game jam 4",
        "",
    }
end

function credits:update(dt)
    music:stop()
    love.audio.playMusic(nil)
    self.from:update(dt)
    self.topY = self.topY - dt * 4
end

function credits:draw()
    self.from:draw()
    love.graphics.setDarkColor()
    love.graphics.rectangle("fill", 0, self.topY, VIRTUAL_WIDTH, VIRTUAL_HEIGHT*10)
    local yText = self.topY + 10
    love.graphics.setLightColor()
    for i, text in ipairs(self.credits) do
        love.graphics.printf(text, 0, yText, VIRTUAL_WIDTH, 'center')
        yText = yText + 9
    end
end

function credits:keypressed(key, code)
    if key == 'p' or key == 'space' or key == 'return' then
    end
end

return credits