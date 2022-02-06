sti = require '../libraries/sti'
camera = require '../libraries/hump/camera'
require '../Player'

local game_loop = {}

function game_loop:enter()
    gameMap = sti('maps/map_one.lua')
    cam = camera()
    player = Player(44, 22, 8, 8);
end

function game_loop:update(dt)
    player:update(dt)
    cam:lookAt(getViewpointForCamera())
end

function game_loop:draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        player:render()
    cam:detach()
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


return game_loop