local main_menu = {}


function main_menu:update(dt)
end

function main_menu:draw()
    love.graphics.setDarkColor()
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setLightColor()
    love.graphics.printf('Title screen', 1, 20, VIRTUAL_WIDTH, 'center')
end

function main_menu:keypressed(key, code)
    if key == 'return' then
        Gamestate.switch(game_loop)
    end
end

return main_menu