local main_menu = {}


function main_menu:draw()
    love.graphics.setFont(smallFont)
    love.graphics.printf('Press Enter :)', 0, 20, VIRTUAL_WIDTH, 'center')
end

function main_menu:keypressed(key, code)
    if key == 'return' then
        Gamestate.switch(game_loop)
    end
end

return main_menu