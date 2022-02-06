sti = require '../libraries/sti'
camera = require '../libraries/hump/camera'
require '../Player'

local game_loop = {}

function game_loop:enter()
    gameMap = sti('maps/map_one.lua')

    walls = {}

    cam = camera()
    player = Player(44, 10, 8, 8);
    
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            wall = world:newRectangleCollider(obj.x + 1, obj.y + 1, obj.width - 2, obj.height - 2)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end
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