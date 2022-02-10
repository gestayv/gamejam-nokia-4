Enemy = Class{}

TILE_SIZE = 8

-- aca definir los tipos de enemigos
enemyProperties = {
    bigEye = {
      health = 2,
      strength = 1,
      width = 8,
      height = 8,
      dx = 15,
      dy = 5,
      movementSpeed = 15,
      spriteRow = 2,
      frames = "1-4"
    },
    lizard = {
      health = 0,
      strength = 0,
      width = 0,
      height = 0,
      dx = 0,
      dy = 0,
      movementSpeed = 0,
      spriteRow = 2,
      frames = "1-6"
    },
    eyeBat = {
        health = 1,
        strength = 2,
        width = 8,
        height = 8,
        dx = 15,
        dy = 5,
        movementSpeed = 20,
        spriteRow = 1,
        frames = "1-4"
      },
    eye = {
        health = 0,
        strength = 0,
        width = 0,
        height = 0,
        dx = 0,
        dy = 0,
        movementSpeed = 0,
        spriteRow = 1,
        frames = "1-6"
    },
    flying = {
        health = 1,
        strength = 1,
        width = 8,
        height = 8,
        dx = 1,
        dy = 1,
        movementSpeed = 1,
        spriteRow = 1,
        frames = "1-6"
    },
}

--------------------------------------------------------------------------
-- TODO: Crear funciones unicas de movimiento para enemigos voladores, 
-- las funciones se pueden guardar en variables asi que quizas podriamos
-- definir todo aca, despues lo guardamos en un self y a eso le pasamos el 
-- dt en el update
--------------------------------------------------------------------------
function Enemy:init(x, y, propiedades)
    self.x = x          -- position x axis
    self.y = y          -- position y axis
    self.direction = 1
    self.alive = true
    -- self.map = map

    -- Unique data
    data = enemyProperties[propiedades.type]
    self.dx = data.dx
    self.dy = data.dy
    self.movementSpeed = data.movementSpeed
    self.strength = data.strength
    self.health = data.health
    self.width = data.width   -- depende del enemigo
    self.height = data.height -- depende del enemigo    

    -- Avoids changing direction indefinitely when pushed into wall
    self._timeSinceDirectionChange = 10

    -- Collisions
    self.collider = world:newRectangleCollider(x, y, self.width, self.height)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFriction(0)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)

    -- donde cargamos esto para evitar que todos los enemigos lo carguen cuando se crean y se cargue una sola vez
    self.spriteSheet = love.graphics.newImage('/sprites/enemies.png')
    self.grid = anim8.newGrid(8, 8, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
end

function Enemy:update(dt)
    local fx = 0
    local fy = 0
    vx, vy = self.collider:getLinearVelocity()

    fx = self.dx * self.direction

    vx = range_bound(vx, self.movementSpeed, - self.movementSpeed)
    vy = range_bound(vy, 80, -60)
    
    self.collider:applyForce(fx, fy)
    self.collider:setLinearVelocity(vx, vy) 
    self.x = self.collider:getX()
    self.y = self.collider:getY()
    self:changeDirection()

    self._timeSinceDirectionChange = self._timeSinceDirectionChange + dt
end

function Enemy:render()
    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self.health = 0
        self.alive = false
    end
end

function Enemy:destroy()
    self.collider:destroy()
end

function Enemy:changeDirection()
    -- Para que funcione el stay, se deben llamar ambos: el enter y el exit
    if self.collider:exit('Solid') then end
    if self:collideWithWall() or self:collidingWithWall() or self:fallOnNextStep() then
       self.direction = - self.direction
    end
end

function Enemy:collideWithWall()
    if self.collider:enter('Solid') then
        local wallCollider = self.collider:getEnterCollisionData('Solid').collider
        if isHorizontalCollision(self.x, self.width, wallCollider) then 
            self._timeSinceDirectionChange = 0
            return true
        end   
    end
    return false
end

function Enemy:collidingWithWall()
    if self.collider:stay('Solid') then
        local wall_collider_list = self.collider:getStayCollisionData('Solid')
        for _, collision_data in ipairs(wall_collider_list) do
            if isHorizontalCollision(self.x, self.width, collision_data.collider) and self._timeSinceDirectionChange > 0.5 then 
                self._timeSinceDirectionChange = 0
                return true
            end  
        end
    end
    return false
end

function Enemy:fallOnNextStep()
    -- Check every frame if the floor is about to end
    if self.collider:stay('Solid') then
        local floor_collider_list = self.collider:getStayCollisionData('Solid')
        for _, collision_data in ipairs(floor_collider_list) do
            local floorCollider = collision_data.collider
            local tx1, ty1, tx2, _ = floorCollider:getBoundingBox()
            -- Check if enemy is about to fall off the floor
            local rightX = self.x + (self.width)/2
            local leftX = self.x - (self.width)/2
            local distanceBeforeFalling = 5
            
            -- Enemy is on top of collider
            if self.y + (self.height)/2 < ty1 then
                if self.direction == 1 then
                    return leftX + distanceBeforeFalling > tx2
                else
                    return rightX - distanceBeforeFalling < tx1
                end
            end
        end
    end

    -- Jump back if dropping down on next frame
    --[[ if self.collider:exit('Solid') then
        local floorCollider = self.collider:getExitCollisionData('Solid').collider
        local tx1, ty1, tx2, _ = floorCollider:getBoundingBox()
        -- Check if enemy is colliding with side of wall
        local rightX = self.x + (self.width)/2
        local leftX = self.x - (self.width)/2
        
        if self.y + (self.height)/2 < ty1 then
            if self.direction == 1 then
                self.collider:applyForce(0, -60)
                return leftX+1 > tx2
            else
                self.collider:applyForce(0, -60)
                return rightX-1 < tx1
            end
        end
    end ]]
    return false
end

function queryTile(x, y) 
    return ":)"
end