ScreenTransition = Class{}

function ScreenTransition:init(seconds, width, height)
    self.seconds = seconds or 1
    self.width = width or 14
    self.height = height or 8
    self.x = VIRTUAL_WIDTH - self.width
    self.y = VIRTUAL_HEIGHT - self.height
    self.totalSquares = (VIRTUAL_WIDTH / self.width) * (VIRTUAL_HEIGHT / self.height)
    self.halfSeconds = self.seconds/2
    self.squares = {}
    self.animationTime = 0
    self.deletingSquares = false
    self.alive = true
end

function ScreenTransition:update(dt)
    local squareCount = #self.squares
    if not self.deletingSquares then
        local time = self.animationTime / self.halfSeconds
        local squareTarget = bezier_blend(time) * self.totalSquares
        if squareCount < self.totalSquares then
            local squaresToAdd = squareTarget - squareCount + 1
            -- Add squares until target is reached
            for i=1,squaresToAdd do
                table.insert(self.squares, {x= self.x, y = self.y})
                if self.y - self.height < 0 then
                    self.x = self.x - self.width
                    self.y = VIRTUAL_HEIGHT - self.height
                else
                    self.y = self.y - self.height
                end
            end
        else
            self.deletingSquares = true
        end
    else
        -- Delete squares until no squares are left or animation ends
        local time = (self.animationTime - self.halfSeconds) / self.halfSeconds
        local squareTarget =  (1 - bezier_blend(time)) * self.totalSquares
        local squaresToDelete = squareCount - squareTarget + 1
        for i=1,squaresToDelete do
            table.remove(self.squares)
        end
    end

    self.animationTime = self.animationTime + dt
    if self.animationTime >= self.seconds then
        self.alive = false
    end
end

function ScreenTransition:render()
    love.graphics.setDarkColor()
    for i, square in ipairs(self.squares) do
        love.graphics.rectangle('fill', square.x, square.y, self.width, self.height)
    end
    love.graphics.setColor(255, 255, 255)
end

function ScreenTransition:destroy()
    for i=#self.squares,1,-1 do
        table.remove(self.squares, i)
    end
end
