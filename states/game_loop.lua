sti = require '../libraries/sti'
camera = require '../libraries/hump/camera'
require '../Player'

local game_loop = {}

function game_loop:enter()
    cam = camera()
    player = Player(44, 10, 8, 8);
end

function game_loop:update(dt)
    world:update(dt)
    player:update(dt)
    cam:lookAt(getViewpointForCamera())
end

function game_loop:draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Layer 1"])
        player:render()
        -- world:draw()
    cam:detach()
end


function getViewpointForCamera()
    gameMapPixelWidth = gameMap.width * gameMap.tilewidth
    gameMapPixelHeight = gameMap.height * gameMap.tileheight

    leftBound = push._RWIDTH/2
    rightBound = leftBound + gameMapPixelWidth - VIRTUAL_WIDTH
    topBound = push._RHEIGHT/2
    bottomBound = topBound + gameMapPixelHeight - VIRTUAL_HEIGHT

    coordsx = math.floor(leftBound - VIRTUAL_WIDTH/2 + player.x + 0.5)
    coordsy = math.floor(topBound - VIRTUAL_HEIGHT/2 + player.y + 0.5)

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