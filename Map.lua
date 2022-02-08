sti = require '../libraries/sti'
require '../Player'
require '../Enemy'

Map = Class{}


function Map:init()
    -- aca cargamos mapa (sprite), tiene que recibir a qué mapa cambiamos
    -- quizas podemos pasar este argumento desde el mapa que salió

    -- cargamos colliders a una table
    -- desde tiled se agregan como una nueva layer

    -- cargamos enemigos a una table
    -- desde tiled se agregan como una nueva layer

    -- cargamos mejoras ocultas (si es que las agregamos)
    -- nuevamente, desde tiled se agregan como una nueva layer

    walls = {}

    player = Player(44, 7, 8, 8)
    
    enemies = {}
    enemy = Enemy(44, 10, 8, 8, 1, 1, 1)

    -- if gameMap.layers["Walls"] then
    --     for i, obj in pairs(gameMap.layers["Walls"].objects) do
    --         wall = world:newRectangleCollider(obj.x + 1, obj.y + 1, obj.width - 2, obj.height - 2)
    --         wall:setType('static')
    --         wall:setCollisionClass('Solid')
    --         wall:setFriction(0)
    --         table.insert(walls, wall)
    --     end
    -- end

    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            wall = world:newRectangleCollider(obj.x + 1, obj.y + 1, obj.width - 2, obj.height - 2)
            wall:setType('static')
            wall:setCollisionClass('Solid')
            wall:setFriction(0)
            table.insert(walls, wall)
        end
    end
end

function Map:update(dt)
end

function Map:render()
end