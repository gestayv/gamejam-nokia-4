-- The Sumoga class, it will beat the chick out of you
require 'SumogaEgg'

Sumoga = Class{}

bossSpriteSheet = love.graphics.newImage('/sprites/boss_spritesheet.png')

TILE_SIZE = 8

function Sumoga:init()
    local legX = player.x + 24
    legX = range_bound(legX, 188, 90)
    self.leg = {
        x = legX,
        y = -36,
        width = 16,
        height = 72,
        movementSpeed = 0,
        falling = true,
    }
    self.leg.grid = anim8.newGrid(self.leg.width, self.leg.height, bossSpriteSheet:getWidth(), bossSpriteSheet:getHeight())
    self.leg.animations = {
        idle = anim8.newAnimation(self.leg.grid('1-2', 1), 0.5)
    }
    self.leg.anim = self.leg.animations.idle
    self.leg.collider = world:newRectangleCollider(self.leg.x, self.leg.y, self.leg.width, self.leg.height)
    self.leg.collider:setCollisionClass('Enemy')
    self.leg.collider:setFixedRotation(true)
    self.leg.collider:setObject(self)
    self.leg.collider:setLinearVelocity(0, 40) -- Initial boost of speed

    self.head = {
        x = -20,
        y = 0,
        width = 16,
        height = 120,
        movementSpeed = 18,
    }
    self.head.grid = anim8.newGrid(self.head.width, self.head.height, bossSpriteSheet:getWidth(), bossSpriteSheet:getHeight())
    self.head.animations = {
        falling = anim8.newAnimation(self.head.grid('3-4', 1), 0.5),
        rising = anim8.newAnimation(self.head.grid('5-6', 1), 0.5),
        chase = anim8.newAnimation(self.head.grid('5-5', 1), 0.5),
        hitOnFall = anim8.newAnimation(self.head.grid('7-8', 1), 0.5),
        hitOnRise = anim8.newAnimation(self.head.grid('7-8', 1), 0.5),
    }
    self.head.anim = self.head.animations.chase
    self.head.collider = world:newRectangleCollider(self.head.x, self.head.y, self.head.width, self.head.height)
    self.head.collider:setCollisionClass('Enemy')
    self.head.collider:setGravityScale(0)
    self.head.collider:setFriction(0)
    self.head.collider:setFixedRotation(true)
    self.head.collider.sumoga = true
    self.head.collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1.sumoga and collider_1.collision_class == 'Enemy' and collider_2.collision_class == 'Enemy' then
            contact:setEnabled(false)
        end   
    end)
    self.head.collider:setObject(self)
    
    self.strength = 40
    self.health = player.attack * 51
    self.maxHealth = self.health
    self.dx = 60
    self.dy = 10
    self.peckTime = 3
    self.eggTime = 2
    self.actionSpeed = 1
    self.peckStatus = nil
    self.eggStatus = nil
    self.peckTimerActive = false
    self.eggTimerActive = false
    self.alive = true
    self.moveLegOutside = false
end

-- como la pelea es scripted, en terminos de como se va a mover y los ataques que va a realizar, va a funcionar
-- un poco distinto a los enemigos comunes y corrientes
function Sumoga:update(dt)
    self:updateActionSpeed()
    lifePercentage = self.health/self.maxHealth
    if lifePercentage <= 0 then 
        self:fuckingDies()
    end
    if lifePercentage <= 0.5 then
        if not self.eggStatus then
            self.eggStatus = 'spawn'
        end
    end
    if lifePercentage <= 0.75 then
        if not self.peckStatus then
            self.peckStatus = 'spawn'
            self.head.collider:setPosition(player.x, -20)
            self.moveLegOutside = true
        end
    end

    self.leg.x = self.leg.collider:getX()    
    self.head.x = self.head.collider:getX()
    self.leg.y = self.leg.collider:getY()    
    self.head.y = self.head.collider:getY()

    if self.peckStatus then
        self:peck(dt)
    end
    if self.eggStatus then
        self:eggThrow()
    end

    local _, vy = self.leg.collider:getLinearVelocity()
    if not self.peckStatus then
        if vy <= 0 then
            if self.leg.falling then
                screen_shake(0.5)
                self.leg.falling = false
            end
            self.leg.collider:setLinearVelocity(0, 0)
        end
    elseif self.moveLegOutside then
        if self.leg.x < 209 then
            -- yeet the leg to the right of the screen
            self.leg.collider:setCollisionClass('Level Transition') -- Ignores solid
            self.leg.collider:applyLinearImpulse(2.3, -3)
        else
            self.leg.collider:setX(209)
            if self.leg.y > 60.2 then
                self.leg.collider:setY(60.2)
                self.leg.collider:setLinearVelocity(0, 0)
                self.leg.collider:setGravityScale(0)
                self.moveLegOutside = false
            end
        end
    end
    self.leg.anim:update(dt)
    self.head.anim:update(dt)
end

function Sumoga:render()
    self.leg.anim:draw(bossSpriteSheet, round(self.leg.x - self.leg.width/2), round(self.leg.y - self.leg.height/2) + 1)
    self.head.anim:draw(bossSpriteSheet, round(self.head.x - self.head.width/2), round(self.head.y - self.head.height/2) + 2)
end

function Sumoga:destroy()
    self.leg.collider:destroy()
    self.head.collider:destroy()
    camShake = false
    Timer.clear()

    -- Kill all enemies
    for i, obj in ipairs(enemies) do
        obj.alive = false
    end
end

function Sumoga:peck(dt)
    local fx, fy = 0, 0

    self.head.collider:setGravityScale(1)
    if self.peckStatus == 'spawn' then
        self.head.anim = self.head.animations.falling
        fx, fy = self:peckSpawn(dt)
    elseif self.peckStatus == 'chase' then
        self.head.anim = self.head.animations.chase
        fx, fy = self:peckChase()
    elseif self.peckStatus == 'peck-rise' then
        self.head.anim = self.head.animations.rising
        fx, fy = self:peckRise()
    elseif self.peckStatus == 'peck-attack' then
        self.head.anim = self.head.animations.falling
        fx, fy = self:peckAttack()
    elseif self.peckStatus == 'grounded' then
        self.head.anim = self.head.animations.falling
        self:peckGrounded()
    elseif self.peckStatus == 'return' then
        self.head.anim = self.head.animations.rising
        fx, fy = self:peckReturn()
    end

    local vx, vy = self.head.collider:getLinearVelocity()
    vx = range_bound(vx, self:increaseMod(self.head.movementSpeed), self:increaseMod(-self.head.movementSpeed))
    vy = range_bound(vy, self:increaseMod(80), self:increaseMod(-20))

    self.head.collider:applyForce(self:increaseMod(fx), self:increaseMod(fy))
    self.head.collider:setLinearVelocity(vx, vy)
end

function Sumoga:peckSpawn(dt)
    local fx, fy = 0, 0
    self.head.collider:setGravityScale(0)

    -- sprite sigue al jugador basado en la posicion
    fx = self:followPlayerFx()
    fx = fx * (1 / self.actionSpeed)

    if self.head.y < 8 then
        self.head.y = self.head.y + self:increaseMod(self.dy) * dt
        self.head.collider:setY(self.head.y)
    else 
        self.head.collider:setY(8)
        self.peckStatus = 'chase'
    end
    local vx, vy = self.head.collider:getLinearVelocity()
    self.head.collider:setLinearVelocity(vx, 0)

    return fx, fy
end

function Sumoga:peckChase()
    self.head.collider:setGravityScale(0)
    local fx = self:followPlayerFx()

    self:peckAfter(self.peckTime, function() 
        self.peckStatus = 'peck-rise'
    end)

    return fx, 0
end

function Sumoga:followPlayerFx()
    -- sprite sigue al jugador basado en la posicion
    if self.head.x  + 2 < player.x then
        fx = self:increaseMod(self.dx)
    else
        fx = self:increaseMod(self.dx) * -1
    end
    return fx
end

function Sumoga:peckRise()
    local fx, fy = 0, -600

    self:peckAfter(self:decreaseMod(1), function()
        self.peckStatus = 'peck-attack'
        self.head.collider:setLinearVelocity(0, 0)
    end)

    local vx, vy = self.head.collider:getLinearVelocity()
    self.head.collider:setLinearVelocity(0, vy)
    return fx, fy
end

function Sumoga:peckAttack()
    local fx, fy = 0, 1000
    self.peckTime = math.random(self:decreaseMod(2), self:decreaseMod(6))
    
    if self.head.collider:enter('Player') then
        self.peckStatus = 'return'
    elseif self.head.collider:enter('Solid') then
        self.peckStatus = 'grounded'
        screen_shake(0.5)
    end

    return fx, fy
end

function Sumoga:peckGrounded()
    self:peckAfter(self:decreaseMod(1.5), function()
        self.peckStatus = 'return'
    end)
    self.head.collider:setLinearVelocity(0, 0)
end

function Sumoga:peckReturn()
    local fx, fy = 0, -600

    self:peckAfter(self:decreaseMod(1), function()
        self.peckStatus = 'spawn'
    end)

    return fx, fy
end

function Sumoga:eggThrow()
    self:eggAfter(self.eggTime, function()
        egg = SumogaEgg(player.x, player.y - 60)
        egg.collider:setLinearVelocity(0, 10)
        table.insert(enemies, egg)
        self.eggTime = love.math.random(2.2, self:decreaseMod(4.5))
    end)
end

function Sumoga:updateActionSpeed()
    lifePercentage = self.health/self.maxHealth
    self.actionSpeed = math.cos(lifePercentage - 1)
end

function Sumoga:increaseMod(number)
    return number * (1 / self.actionSpeed)
end

function Sumoga:decreaseMod(number)
    return number * (self.actionSpeed)
end


function Sumoga:fuckingDies()
    Gamestate.push(credits)
end

function Sumoga:takeDamage(damage)
    local headTextY = player.y - 5
    local legTextY = player.y - 5
    -- Limit y text to the bottom of each collider
    if headTextY > round(self.head.y + self.head.height / 2) then
        headTextY = round(self.head.y + self.head.height / 2)
    end
    if legTextY > round(self.leg.y + self.leg.height / 2) then
        legTextY = round(self.leg.y + self.leg.height / 2)
    end
    
    table.insert(animations, Text(round(self.leg.x - self.leg.width/2), legTextY, damage, round(self.leg.x - self.leg.width/2), legTextY -5, 1.4))
    table.insert(animations, Text(round(self.head.x - self.head.width/2), headTextY, damage, round(self.head.x - self.head.width/2), headTextY -5, 1.4))
    love.audio.playSound(hitEnemySound)
    self.health = self.health - damage
    if self.health <= 0 then
        self.health = 0
        self.alive = false
    end
end

-- Timer wrapper
function Sumoga:peckAfter(seconds, callback)
    if not self.peckTimerActive then
        Timer.after(seconds, function()
            callback()
            self.peckTimerActive = false
        end)
        self.peckTimerActive = true
    end
end

function Sumoga:eggAfter(seconds, callback)
    if not self.eggTimerActive then
        Timer.after(seconds, function()
            callback()
            self.eggTimerActive = false
        end)
        self.eggTimerActive = true
    end
end