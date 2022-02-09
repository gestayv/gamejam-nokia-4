sti = require '../libraries/sti'
camera = require '../libraries/hump/camera'
require '../Player'
require '../Enemy'
gameMap = sti('maps/map_one.lua')

local game_loop = {}

function game_loop:enter()

    walls = {}

    cam = camera()
    player = Player(44, 7, 8, 8)
    
    enemies = {}
    
    if gameMap.layers["Enemy"] then
        for i, obj in pairs(gameMap.layers["Enemy"].objects) do
            enemy = Enemy(obj.x + 1, obj.y + 1, 8, 8, 7, 5, 1)
            table.insert(enemies, enemy)
        end
    end

    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            wall = world:newRectangleCollider(obj.x + 0.2, obj.y + 0.2 , obj.width - 0.4, obj.height - 0.4)
            wall:setType('static')
            wall:setCollisionClass('Solid')
            wall:setFriction(0)
            table.insert(walls, wall)
        end
    end
end

function game_loop:update(dt)
    -- Limit dt spikes when moving window
    -- if dt > 0.02 then dt = 0.02 end
    player:update(dt)
    world:update(dt)
    self:update_list(enemies, dt)
    cam:lookAt(getViewpointForCamera())
end

function game_loop:update_list(list, dt)
    for i, obj in pairs(list) do
        obj:update(dt)
    end
end

function game_loop:draw_list(list, dt)
    for i, obj in pairs(list) do
        obj:render(dt)
    end
end

function game_loop:draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Layer 1"])
        self:draw_list(enemies, dt)
        player:render()
        -- world:draw() -- this draws colliders, uncomment only if needed
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

    coordsx = range_bound(coordsx, rightBound, leftBound)
    coordsy = range_bound(coordsy, bottomBound, topBound)
    
    return coordsx, coordsy
end


return game_loop