ScreenTransition = Class{}

function ScreenTransition:init(seconds, width, height)
    self.seconds = seconds or 1
    self.width = width or 14
    self.height = height or 8
    self.x = VIRTUAL_WIDTH - self.width
    self.y = VIRTUAL_HEIGHT - self.height
    self.totalSquares = (VIRTUAL_WIDTH / self.width) * (VIRTUAL_HEIGHT / self.height)
    self.fourthSeconds = self.seconds/4
    self.squares = {}
    self.animationTime = 0
    self.status = 'add-squares'
    self.alive = true
end

function ScreenTransition:update(dt)
    local squareCount = #self.squares
    if self.status == 'add-squares' then
        print("add-squares", self.animationTime)
        local time = self.animationTime / self.fourthSeconds
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
            self.status = 'stay'
        end
    elseif self.status == 'stay' then
        local time = (self.animationTime - (self.fourthSeconds*2)) / self.fourthSeconds
        if time >= 1 then
            self.status = 'delete'
        end
    else
        -- Delete squares until no squares are left or animation ends
        local time = (self.animationTime - (self.fourthSeconds*3)) / self.fourthSeconds
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
