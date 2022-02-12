Enemy = Class{}

anim8 = require '/libraries/anim8'
TILE_SIZE = 8

-- aca definir los tipos de enemigos
enemyProperties = {
    bigEye = {
      health = 20,
      strength = 10,
      width = 8,
      height = 8,
      dx = 15,
      dy = 5,
      movementSpeed = 15,
      spriteRow = 2,
      frames = "1-4",
      frameUpdate = 0.3,
      movementFunction = "ground"
    },
    lizard = {
      health = 40,
      strength = 10,
      width = 8,
      height = 8,
      dx = 10,
      dy = 5,
      movementSpeed = 10,
      spriteRow = 3,
      frames = "1-6",
      frameUpdate = 0.7,
      movementFunction = "ground"
    },
    eyeBat = {
        health = 10,
        strength = 20,
        width = 8,
        height = 8,
        dx = 15,
        dy = 5,
        movementSpeed = 5,
        spriteRow = 1,
        frames = "5-6",
        frameUpdate = 0.2,
        movementFunction = "sky"
      },
    eye = {
        health = 20,
        strength = 10,
        width = 8,
        height = 8,
        dx = 20,
        dy = 1,
        movementSpeed = 20,
        spriteRow = 1,
        frames = "1-4",
        frameUpdate = 0.4,
        movementFunction = "ground"
    },
    flying = {
        health = 20,
        strength = 10,
        width = 8,
        height = 8,
        dx = 20,
        dy = 1,
        movementSpeed = 20,
        spriteRow = 1,
        frames = "1-4",
        frameUpdate = 0.4,
        movementFunction = "ground"
    }
}

spriteSheet = love.graphics.newImage('/sprites/enemies.png')
grid = anim8.newGrid(8, 8, spriteSheet:getWidth(), spriteSheet:getHeight())

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
    self.originalX = x
    self.originalY = y
    self.dx = data.dx
    self.dy = data.dy
    self.movementSpeed = data.movementSpeed
    self.strength = data.strength
    self.health = data.health
    self.width = data.width   -- depende del enemigo
    self.height = data.height -- depende del enemigo    
    self.movementFunction = data.movementFunction
    self.type = propiedades.type

    -- Avoids changing direction indefinitely when pushed into wall
    self._timeSinceDirectionChange = 10

    -- Collisions
    self.collider = world:newRectangleCollider(x, y, self.width, self.height)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFriction(0)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)

    -- donde cargamos esto para evitar que todos los enemigos lo carguen cuando se crean y se cargue una sola vez
    self.animations = {}
    self.animations.right = anim8.newAnimation(grid(data.frames, data.spriteRow), 0.4)
    self.animations.left = anim8.newAnimation(grid(data.frames, data.spriteRow), 0.4):flipH()

    if self.direction == 1 then
        self.anim = self.animations.right
    else
        self.anim = self.animations.left
    end
     
end

function Enemy:update(dt)
    if self.movementFunction == "ground" then
        groundBasedMovement(dt, self)
    else
        skyBasedMovement(dt, self)
    end
    self.anim:update(dt)
end

function Enemy:render()
    self.anim:draw(spriteSheet, round(self.x - 8/2), round(self.y - 8/2))
end

function Enemy:takeDamage(damage)
    table.insert(animations, Text(round(self.x - self.width/2), self.y - self.height, damage, round(self.x - self.width/2), self.y - self.height - 4, 1))
    love.audio.playSound(hitEnemySound)
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
        if self.anim == self.animations.right then
            self.anim = self.animations.left
        else
            self.anim = self.animations.right
        end
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

function groundBasedMovement(dt, enemy)
    local fx = 0
    local fy = 0

    -- debug.debug()
    vx, vy = enemy.collider:getLinearVelocity()

    fx = enemy.dx * enemy.direction

    vx = range_bound(vx, enemy.movementSpeed, - enemy.movementSpeed)
    vy = range_bound(vy, 80, -60)
    
    enemy.collider:applyForce(fx, fy)
    enemy.collider:setLinearVelocity(vx, vy) 
    enemy.x = enemy.collider:getX()
    enemy.y = enemy.collider:getY()
    enemy:changeDirection()

    enemy._timeSinceDirectionChange = enemy._timeSinceDirectionChange + dt
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

function skyBasedMovement(dt, enemy)
    local fx = 0
    local fy = 0

    vx, vy = enemy.collider:getLinearVelocity()
    enemy.collider:setGravityScale(0)

    xDif = enemy.x - player.x
    yDif = enemy.y - player.y
    xDistance = math.pow(math.abs(xDif), 2)
    yDistance = math.pow(math.abs(yDif), 2) 
    if math.sqrt( xDistance + yDistance ) < 40 and player.health > 0 then

        if xDif >= 0 then
            fx = enemy.dx * -1
        else
            fx = enemy.dx
        end

        if yDif >= 0 then
            fy = enemy.dy * -1
        else
            fy = enemy.dy
        end

        vx = range_bound(vx, enemy.movementSpeed, - enemy.movementSpeed)
        vy = range_bound(vy, enemy.movementSpeed, - enemy.movementSpeed)
        enemy.collider:applyForce(fx, fy)
        enemy.collider:setLinearVelocity(vx, vy)        
    else
        xDifToOrigin = enemy.x - enemy.originalX
        yDifToOrigin = enemy.y - enemy.originalY

        if xDifToOrigin >= 0 then
            fx = enemy.dx * -1
        else
            fx = enemy.dx
        end

        if yDifToOrigin >= 0 then
            fy = enemy.dy * -1
        else
            fy = enemy.dy
        end

        vx = range_bound(vx, enemy.movementSpeed, - enemy.movementSpeed)
        vy = range_bound(vy, enemy.movementSpeed, - enemy.movementSpeed)
    
        enemy.collider:applyForce(fx, fy)
        enemy.collider:setLinearVelocity(vx, vy)
    end
    
    

    enemy.x = enemy.collider:getX()
    enemy.y = enemy.collider:getY()
    -- enemy:changeDirection()
    enemy._timeSinceDirectionChange = enemy._timeSinceDirectionChange + dt
end
