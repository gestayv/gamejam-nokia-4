local main_menu = {}

function main_menu:enter()
    self.spriteSheet = love.graphics.newImage('/sprites/title_screen_spritesheet.png')
    self.grid = anim8.newGrid(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.anim = anim8.newAnimation(self.grid('1-2', 1), {1.5, 0.3})
end

function main_menu:update(dt)
    self.anim:update(dt)
end

function main_menu:draw()
    self.anim:draw(self.spriteSheet, 0, 0)
end

function main_menu:keypressed(key, code)
    if key == 'return' or key == 'space' then
        Gamestate.switch(game_loop)
    end
end

return main_menu