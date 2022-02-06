push = require 'push'
Class = require 'class'
sti = require 'libraries/sti'
camera = require 'libraries/camera'
require 'Player'
sti = require 'libraries/sti'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 84
VIRTUAL_HEIGHT = 48

cam_x = 0
cam_y = 0

function love.load()
    love.window.setTitle('gamejam nokia')
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    player = Player(44, 22, 8, 8);

    smallFont = love.graphics.newFont('Ark.ttf', 8)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        pixelperfect = true,
    })

    gameMap = sti('maps/map_one.lua')
    cam = camera()

    gameState = 'main_menu'
end

function love.resize(w, h)
    push:resize(w, h)
end

function getViewpointForCamera()
    coordsx = math.floor(push._RWIDTH/2 - VIRTUAL_WIDTH/2 + player.x)
    coordsy = math.floor(push._RHEIGHT/2 - VIRTUAL_HEIGHT/2 + player.y) --push._RWIDTH/2, push._RHEIGHT/2
    return coordsx, coordsy
end

function love.update(dt)
    player:update(dt)
    cam:lookAt(getViewpointForCamera())
    -- print(cam:position())
end

function love.keypressed(key)
    if gameState == 'main_menu' then
        if key == "return" then
            gameState = 'game_loop'
        end
    end
end

function love.draw()
    push:apply('start')
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])


        if gameState == 'main_menu' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Enter :)', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameState == 'game_loop' then
            player:render()
        end
    cam:detach()
    push:apply('end')
end