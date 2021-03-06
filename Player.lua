-- Player class, manages player logic duh
require "Bullet"
require "Pet"
Player = Class{}

INITIAL_JUMP_FORCE = -60
JUMP_FORCE = -30
HORIZONTAL_FORCE = 25
BULLET_WIDTH = 4
BULLET_HEIGHT = 3
MAX_MOVEMENT_SPEED = 20
MAX_FALL_SPEED = 80
MAX_JUMP_SPEED = -42
-- TO DO: Move these constants into the class itself
-- to be able to updgrade movement speed

function Player:init(x, y, width, height)
    self.x = x      -- position x axis
    self.y = y      -- position y axis
    self.width = width  
    self.height = height
    self.bullets = {}
    self._fireRate = 1
    self.fireRateMod = 0
    self.timeSinceLastShot = 0
    self.directionX = 1
    self.collider = world:newRectangleCollider(self.x, self.y, width, height)
    self.collider:setFixedRotation(true)
    self.collider:setFriction(0)
    self.collider:setCollisionClass('Player')
    self.jumpable = false
    self.jumping = false
    self.airTime = 0 -- Used to dampen force applied during jump
    self.timeSinceLastHit = 0
    self.alive = true
    self.dying = false

    self.pet = Pet()

    -- Player stats
    self.baseHealth = 50
    self.maxHealth = self.baseHealth
    self.health = self.maxHealth
    self.attack = 10
    self.invincibilityTime = 1.3

    self.collider:setPreSolve(function(collider_1, collider_2, contact)        
        if collider_1.collision_class == 'Player' and (collider_2.collision_class == 'Solid') then
            vx, vy = collider_1:getLinearVelocity()
            -- Enable jump when colliding on top of solid objects
            if isCollidingOnTop(self.y, self.height, collider_2) and vy >= 0 then 
                if not self.jumpable and self.airTime >= 0.1 then
                    love.audio.playSound(landSound)
                end
                self.jumpable = true
                self.airTime = 0
            end
        end   
    end)
  
    self.collider:setObject(self)
    self.spriteSheet = love.graphics.newImage('/sprites/player_spritesheet.png')
    self.grid = anim8.newGrid(8, 8, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.right = anim8.newAnimation(self.grid('1-3', 1), 0.4)
    self.animations.left = anim8.newAnimation(self.grid('1-3', 1), 0.4):flipH()
    self.animations.jump = anim8.newAnimation(self.grid('5-6', 1), 0.4)
    self.animations.idle = anim8.newAnimation(self.grid('4-5', 1), 2)
    self.animations.death = anim8.newAnimation(self.grid('1-9', 2), 0.4, 'pauseAtEnd')

    self.anim = self.animations.left
    self.test = false
end

function Player:update(dt)
    if player.alive then
        self:movementUpdate(dt)
        self:fireUpdate(dt)
        self:resolveEnemyCollisions(dt)
        self.pet:update(dt)
    else
        if not self.dying then
            self.collider:setCollisionClass('Ghost')
            self.anim = self.animations.death
            self.dying = true
            love.audio.playSound(gameOverSound)
        end
    end
    self.anim:update(dt)
    self:checkTransitions()
end

function Player:render()
    self.anim:draw(self.spriteSheet, round(self.x - 8/2), round(self.y - 8/2))
    for key, bullet in pairs(self.bullets) do
        bullet:render()
    end

    if not self:canFire() then
        -- love.graphics.setLightColor()
        -- love.graphics.rectangle("fill", round(self.x - self.width/2), round(self.y - self.height), self.width, 3)

        love.graphics.setDarkColor()
        fillPercent = self.timeSinceLastShot / self:fireRate()
        love.graphics.rectangle("fill", round(self.x - self.width/2), round(self.y - self.height + 2), (self.width) * fillPercent, 1)
    end
end

function Player:setPosition(x, y)
    self.collider:setPosition(x, y)
    self.x = x
    self.y = y
end

function Player:fire()
    if self:canFire() then
        love.audio.playSound(shootSound)
        bullet = Bullet(self.x, self.y, BULLET_WIDTH, BULLET_HEIGHT, self.directionX, self:damage())
        table.insert(self.bullets, bullet)
        self.timeSinceLastShot = 0
    end
end

function Player:fireRate()
    return (self._fireRate + self.fireRateMod) 
end

function Player:canFire()
   return self.timeSinceLastShot >= 1 / self:fireRate()
end

function Player:canJump()
    return self.jumpable
end

function Player:movementUpdate(dt)
    local isMoving = false
    local fx = 0
    local fy = 0
    vx, vy = self.collider:getLinearVelocity()
    if love.keyboard.isDown("left", "a") then
        self.directionX = -1
        fx = -1 * HORIZONTAL_FORCE
        self.anim = self.animations.left
        isMoving = true
    elseif love.keyboard.isDown("right", "d") then
        self.directionX = 1
        fx = HORIZONTAL_FORCE
        self.anim = self.animations.right
        isMoving = true
    end
    if not love.keyboard.isDown("left", "a", "right", "d") then
        vx = 0
    end

    if love.keyboard.wasPressed("up", "w") and self:canJump() then
        fy = INITIAL_JUMP_FORCE
        self.jumping = true
        self.jumpable = false
        love.audio.playSound(jumpSound)
    end
    if love.keyboard.wasReleased("up", "w") then
        self.jumping = false
        -- self.airTime = 0
    end
    if self.jumping then
        self.airTime = self.airTime + dt
        
        fy = (JUMP_FORCE) + math.exp(3 * self.airTime) - 1
        if vy <= MAX_JUMP_SPEED then
            self.jumping = false
            vy = MAX_JUMP_SPEED
        end
    end
    
    -- Limit speeds
    vy = range_bound(vy, MAX_FALL_SPEED, MAX_JUMP_SPEED)
    vx = range_bound(vx, MAX_MOVEMENT_SPEED, -MAX_MOVEMENT_SPEED)

    self.collider:applyForce(fx, fy)
    self.collider:setLinearVelocity(vx, vy) -- Bound velocity
    self.x = self.collider:getX()
    self.y = self.collider:getY()
    
    -- Desactivate jump when leaving a block to disable
    -- jumping after dropping down the ground
    if self.collider:exit('Solid') then
        self.jumpable = false
        self.airTime = 0.2 -- Just used to play landing sound inside preSolve
        local wallData = self.collider:getExitCollisionData('Solid').collider
        if isCollidingOnBottom(player.y, player.height, wallData) then
            self.jumping = false
        end
    end

    if not self.jumpable then 
        self.anim = self.animations.jump
        self.anim:gotoFrame(2)
    end
    if not isMoving and self.jumpable then
        self.anim = self.animations.idle
    end
end

function Player:fireUpdate(dt)
    
    if love.keyboard.wasPressed("space") then
        self:fire()
    end

    for i=#self.bullets,1,-1 do
        local bullet = self.bullets[i]
        bullet:update(dt)
        if bullet.markForDeletion then
            bullet:destroy()
            table.remove(self.bullets, i)
        end
    end
    self.timeSinceLastShot = self.timeSinceLastShot + dt
    self.fireRateMod = self.pet:getBuff('fireRate')
end

function Player:checkTransitions()
    if self.collider:exit('Level Transition') then
        local transitionLevel = self.collider:getExitCollisionData('Level Transition').collider
        if exitDirectionFromCollision(transitionLevel.exit_direction, self.collider, transitionLevel) then
            nextLevel = transitionLevel.target
        end
    end
end

-- Battle functions
function Player:damage()
    return self.attack + self.pet:getBuff('damage')
end

function Player:resolveEnemyCollisions(dt)
    if self.collider:enter("Enemy") and self:canTakeDamage() then
        local collisionData = self.collider:getEnterCollisionData('Enemy')
        self:resolveEnemyDamage(collisionData)
    end
    if self.collider:stay("Enemy") and self:canTakeDamage() then
        local enemyColliderList = self.collider:getStayCollisionData('Enemy')
        for _, collisionData in ipairs(enemyColliderList) do
            self:resolveEnemyDamage(collisionData)
        end
    end
    if self.collider:exit("Enemy") then end

    self.timeSinceLastHit = self.timeSinceLastHit + dt
end

function Player:resolveEnemyDamage(collisionData)
    local enemy = collisionData.collider:getObject()
    if enemy then
        local ex, ey = collisionData.collider:getPosition()
        local ex1, ey1, ex2, ey2 = collisionData.collider:getBoundingBox()
        local e_width, e_height = ex2 - ex1, ey2 - ey1
        local manhattanDistance = math.abs(self.x - ex) + math.abs(self.y - ey)

        local touchCornersDistance = self.width/2 + e_width/2 + self.height/2 + e_height / 2 + 1
        -- Avoid bug where a collision (most of the time) doesn't get canceled
        if manhattanDistance < touchCornersDistance then
            self:takeDamage(enemy.strength)
            local ix = (self.x - ex) * 6
            -- Add -2.2 to rise character a little when hit horizontally
            local iy = (self.y - ey - 2.2) * 0.5
            -- The following bounds were selected by testing numbers pragmatically
            ix = range_bound(ix, 30, -30)
            iy = range_bound(iy, 3.5, -3.5)
            self.collider:applyLinearImpulse(ix, iy)
            self.timeSinceLastHit = 0
        else
            -- Forcefully exit the collision otherwise
            table.insert(self.collider.collision_events['Enemy'], {collision_type = 'exit', collider_1 = self.collider, collider_2 = collisionData.collider, contact = {}})
        end
    end
end

function Player:canTakeDamage()
    return self.timeSinceLastHit >= self.invincibilityTime
end

function Player:takeDamage(damage)
    love.audio.playSound(hitPlayerSound)
    table.insert(animations, Text(round(self.x - self.width / 2), self.y - self.height, damage, round(self.x - self.width / 2), self.y - self.height - 4, 1))
    self.health = self.health - damage
    if self.health <= 0 then
        self.health = 0
        self.alive = false
    end
end

function Player:recover(amount)
    self.health = self.health + amount
    if self.health >= self.maxHealth then
        self.health = self.maxHealth
    end
end

function Player:healthUpdate()
    local newHealth = self.baseHealth + self.pet:getBuff('health')
    local healthDiff = newHealth - self.maxHealth

    self.maxHealth = newHealth

    if self.health + healthDiff > 0 then
        self.health = self.health + healthDiff
    else 
        self.health = 1
    end
end

function Player:destroy()
    self.collider:destroy()
end