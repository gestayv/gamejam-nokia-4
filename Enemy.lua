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
    if self:collideWithWall() or self:fallOnNextStep() then
        self.direction = - self.direction
    end
end

function Enemy:collideWithWall()
    if self.collider:enter('Solid') then
        local wallCollider = self.collider:getEnterCollisionData('Solid').collider
        local tx1, _, tx2, _ = wallCollider:getBoundingBox()
        -- Check if enemy is colliding with side of wall
        local rightX = self.x + (self.width - 1)/2
        local leftX = self.x - (self.width - 1)/2
        if rightX <= tx1 or leftX >= tx2 then 
            return true
        end   
    end
    return false
end

function Enemy:fallOnNextStep()
    -- Check every frame if the floor is about to end
    if self.collider:stay('Solid') then
        local floorCollider_list = self.collider:getStayCollisionData('Solid')
        for _, collision_data in ipairs(floorCollider_list) do
            local floorCollider = collision_data.collider
            local tx1, ty1, tx2, _ = floorCollider:getBoundingBox()
            -- Check if enemy is colliding with side of wall
            local rightX = self.x + (self.width - 1)/2
            local leftX = self.x - (self.width - 1)/2
            local distanceBeforeFalling = 5
            
            if self.y + (self.height - 1)/2 < ty1 then
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
        local rightX = self.x + (self.width - 1)/2
        local leftX = self.x - (self.width - 1)/2
        
        if self.y + (self.height - 1)/2 < ty1 then
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