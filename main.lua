push = require 'push'
Class = require 'class'
require 'Player'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 84
VIRTUAL_HEIGHT = 48

function love.load()
    love.window.setTitle('gamejam nokia')
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    player = Player(10, 10, 8, 8);

    smallFont = love.graphics.newFont('Ark.ttf', 8)
    love.graphics.setFont(smallFont)
        
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    gameState = 'main_menu'
end

function love.resize(w, h)
    push:resize(w, h)
end


function love.update(dt)
    player:update(dt)
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    if gameState == 'main_menu' then
        if key == "return" then
            gameState = 'game_loop'
        end
    elseif gameState == 'game_loop' then
        if key == 'left' or key == 'a' then
        elseif key == 'right' or key == 'd' then
        elseif key == 'w' or key == 'up' then
        elseif key == 'space' then
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    if gameState == 'main_menu' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter :)', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'game_loop' then
        player:render()
    end
    
    push:apply('end')
end