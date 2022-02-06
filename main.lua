push = require 'push'
sti = require 'libraries/sti'
Class = require 'libraries/hump/class'
camera = require 'libraries/hump/camera'
require 'Player'

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

    gameState = 'main_menu'
end

function love.resize(w, h)
    push:resize(w, h)
end

function getViewpointForCamera()
    gameMapPixelWidth = gameMap.width * gameMap.tilewidth
    gameMapPixelHeight = gameMap.height * gameMap.tileheight

    leftBound = push._RWIDTH/2
    rightBound = leftBound + gameMapPixelWidth - VIRTUAL_WIDTH
    topBound = push._RHEIGHT/2
    bottomBound = topBound + gameMapPixelHeight - VIRTUAL_HEIGHT

    coordsx = math.floor(leftBound - VIRTUAL_WIDTH/2 + player.x)
    coordsy = math.floor(topBound - VIRTUAL_HEIGHT/2 + player.y) --push._RWIDTH/2, push._RHEIGHT/2

    -- Bound camera to map size horizontally
    if coordsx < leftBound then
        coordsx = leftBound
    elseif coordsx > rightBound then
        coordsx = rightBound
    end

    -- Bound camera to map size vertically
    if coordsy < topBound then
        coordsy = topBound
    elseif coordsy > bottomBound then
        coordsy = bottomBound
    end


    return coordsx, coordsy
end

function love.update(dt)
    if gameState == 'game_loop' then
        player:update(dt)
        cam:lookAt(getViewpointForCamera())
        -- print(cam:position())
    end
end

function love.keypressed(key)
    -- Delte following code on production
    if key == "escape" then
        love.event.push("quit")
    end
    if gameState == 'main_menu' then
        if key == "return" then
            gameMap = sti('maps/map_one.lua')
            cam = camera()
            gameState = 'game_loop'
        end
    end
end

function love.draw()
    push:apply('start')

    if gameState == 'main_menu' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter :)', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'game_loop' then
        cam:attach()
            gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
            player:render()
        cam:detach()
    end

    push:apply('end')
end