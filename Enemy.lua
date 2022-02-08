Enemy = Class{}

TILE_SIZE = 8

function Enemy:init(x, y, width, height, dx, dy, strength)
    self.x = x          -- position x axis
    self.y = y          -- position y axis
    self.width = width  
    self.height = height
    self.dx = 15        -- speed x axis
    self.dy = 5         -- speed y axis
    self.strength = strength
    self.direction = 1
    self.collider = world:newRectangleCollider(x, y, width - 1, height - 1)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFriction(0)
    self.collider:setRestitution(0)
    self.collider:setFixedRotation(true)
    -- self.map = map
end

function Enemy:update(dt)
    vx, vy = self.collider:getLinearVelocity()

    vx = self.dx * self.direction -- direction
    --print(vx)

    --vx = speed_bound(vx, 30, 30)
    self.collider:setLinearVelocity(vx, vy) 
    self.x = self.collider:getX()
    self.y = self.collider:getY()
    self:changeDirection()
end

function Enemy:render()
    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
end

function Enemy:changeDirection()
    if self.collider:enter('Player') or self.collider:exit('Player') or self.collider:stay('Player')  then    
        print(self:collideWithWall(), self:floorOnNextTile())
    end
    if self:collideWithWall() or not self:floorOnNextTile() then
        self.direction = - self.direction
    end
end

function Enemy:collideWithWall()
    if self.collider:enter('Solid') then
        local wallCollider = self.collider:getEnterCollisionData('Solid').collider
        local tx, _ = wallCollider:getPosition()
        local tx1, _, tx2, _ = wallCollider:getBoundingBox()
        --local tw = tx2 - tx
        -- Check if enemy is colliding with side of wall
        local leftX = self.x + (self.width - 1)/2
        local rightX = self.x - (self.width - 1)/2
        if leftX <= tx1 or rightX >= tx2 then 
            return true
        end   
    end
    return false
end

function Enemy:floorOnNextTile()
    -- hacer una query, 
    -- si voy para la derecha, ver la tile x + 1, y + 1
    -- si voy para la izquierda, ver la tile x - 1, y + 1
    -- si no hay collider, cambia la direccion, pero solo cuando estoy a punto de entrar en la tile X que sigue
    current_tile_x = math.floor(self.x/TILE_SIZE)
    current_tile_y = math.floor((self.y + self.height)/TILE_SIZE)
    
    query_tile_x = (current_tile_x + (self.direction * 1)) * TILE_SIZE
    query_tile_y = current_tile_y * TILE_SIZE

    floors = world:queryRectangleArea((self.x + self.direction), self.y + (self.height/2), 4, 4, {"Solid"})
    local count = 0
    for _ in pairs(floors) do count = count + 1 end
    return count > 0
end

function queryTile(x, y) 
    return ":)"
end