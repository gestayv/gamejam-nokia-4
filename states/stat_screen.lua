local stat_screen = {}

function stat_screen:enter(from)
    self.from = from
    self.animatingEntry = true
    self.animatingLeave = false
    self.topY = VIRTUAL_HEIGHT
    self.speed = 100
    self.topYLimit = 10
    -- music = love.audio.newSource('audio/sounds/blip1.wav', 'static')
    -- love.audio.playMusic(music)
end

function stat_screen:update(dt)
    if self.animatingEntry then
        self.topY = self.topY - self.speed * dt
        if self.topY <= self.topYLimit then
            self.topY = self.topYLimit
            self.animatingEntry = false
        end
    end
    if self.animatingLeave then
        self.topY = self.topY + self.speed * dt
        if self.topY >= VIRTUAL_HEIGHT then
            Gamestate.pop()
        end
    end
end

function stat_screen:draw()
    self.from:draw()
    love.graphics.setDarkColor()
    local boxWidth, boxHeight = VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 10
    local leftX = 0
    local rightX = boxWidth + leftX
    local topY = self.topY
    local bottomY = topY + boxHeight
    love.graphics.rectangle("fill", leftX, topY, boxWidth, boxHeight)
    -- Add lines on each side
    love.graphics.setLightColor()
    love.graphics.rectangle("fill", leftX+2, topY+1, boxWidth-4, 1)
    love.graphics.rectangle("fill", leftX+1, topY+2, 1, boxHeight-4)
    love.graphics.rectangle("fill", boxWidth - 2, topY+2, 1, boxHeight-4)
    love.graphics.rectangle("fill", leftX+2, bottomY-2, boxWidth-4, 1)
    
    -- Add dots on each corner
    love.graphics.rectangle("fill", leftX, topY, 1, 1)
    love.graphics.rectangle("fill", leftX, bottomY-1, 1, 1)
    love.graphics.rectangle("fill", rightX-1, topY, 1, 1)
    love.graphics.rectangle("fill", rightX-1, bottomY-1, 1, 1)
    
    -- Draw stats on screen
    local statsX, statsY = leftX+8, topY+10
    love.graphics.printf('HP', statsX, statsY, boxWidth - statsX*2, 'left')
    love.graphics.printf(player.health .. '/' .. player.maxHealth, statsX, statsY, boxWidth - statsX*2, 'right')
    love.graphics.printf('Attack', statsX, statsY + 12, boxWidth - statsX*2, 'left')
    love.graphics.printf(player.attack, statsX, statsY + 12, boxWidth - statsX*2, 'right')
end

function stat_screen:keypressed(key, code)
    if key == 'p' or key == 'space' or key == 'return' then
        self.animatingEntry = false
        self.animatingLeave = true
    end
end

return stat_screen