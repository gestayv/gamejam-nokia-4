-- The Sumoga class, it will beat the chick out of you
require 'SumogaEgg'

Sumoga = Class{}

bossSpriteSheet = love.graphics.newImage('/sprites/boss_spritesheet.png')

TILE_SIZE = 8

function Sumoga:init()
    local legX = player.x + 16
    legX = range_bound(legX, 180, 90)
    self.leg = {
        x = legX,
        y = -72,
        width = 16,
        height = 72,
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

    self.head = {
        x = -20,
        y = 0,
        width = 16,
        height = 120,
    }
    self.head.grid = anim8.newGrid(self.head.width, self.head.height, bossSpriteSheet:getWidth(), bossSpriteSheet:getHeight())
    self.head.animations = {
        falling = anim8.newAnimation(grid('3-4', 1), 0.5),
        rising = anim8.newAnimation(grid('5-6', 1), 0.5),
        chase = anim8.newAnimation(grid('5-5', 1), 0.5),
        hitOnFall = anim8.newAnimation(grid('7-8', 1), 0.5),
        hitOnRise = anim8.newAnimation(grid('7-8', 1), 0.5),
    }
    self.head.anim = self.head.animations.chase
    self.head.collider = world:newRectangleCollider(self.head.x, self.head.y, self.head.width, self.head.height)
    self.head.collider:setCollisionClass('Enemy')
    self.head.collider:setGravityScale(0)
    self.head.collider:setFriction(0)
    self.head.collider:setFixedRotation(true)
    self.head.collider:setObject(self)
    
    self.strength = 40
    self.health = player.attack * 30
    self.maxHealth = self.health
    self.movementSpeed = 0
    self.peckTime = 3
    self.actionSpeed = 1
    self.peckStatus = "hidden"
    self.timerActive = false
    self.width = 16
    self.height = 56
    self.alive = true
end

-- como la pelea es scripted, en terminos de como se va a mover y los ataques que va a realizar, va a funcionar
-- un poco distinto a los enemigos comunes y corrientes
function Sumoga:update(dt)
    self.actionSpeed = self:updateActionSpeed()
    lifePercentage = self.maxHealth/self.health
    if lifePercentage > 0.75 then
        self:peck(dt)
    elseif lifePercentage > 0.5 then
        self:eggThrow()
    elseif lifePercentage <= 0 then 
        self:fuckingDies()
    end

    self.leg.collider.setLinearVelocity(0, 0)

    self.leg.x = self.leg.collider:getX()    
    self.head.x = self.head.collider:getX()
    self.leg.y = self.leg.collider:getY()    
    self.head.y = self.head.collider:getY()
end

function Sumoga:render()
    
    self.leg.anim:draw(bossSpriteSheet, round(self.leg.x - self.leg.width/2), round(self.leg.y - self.leg.height/2) + 1)
    self.head.anim:draw(bossSpriteSheet, round(self.head.x - self.head.width/2), round(self.head.y - self.head.height/2))

    -- love.graphics.rectangle("fill", round(self.leg.x - self.leg.width/2), round(self.leg.y - self.leg.height/2), self.leg.width, self.leg.height)
    
    --love.graphics.rectangle("fill", round(self.head.x - self.head.width/2), round(self.head.y - self.head.height/2), self.head.width, self.head.height)
end

function Sumoga:destroy()
    self.leg.collider:destroy()
    self.head.collider:destroy()
end

function Sumoga:peck(dt)
    local fx, fy = 0, 0
    vx, vy = self.head.collider:getLinearVelocity()

    self.head.collider:setGravityScale(1)
    if self.peckStatus == 'spawn' then
        
    elseif self.peckStatus == 'chase' then
        fx, fy = self:peckChase()
    elseif self.peckStatus == 'peck-rise' then
        fx, fy = self:peckRise()
    elseif self.peckStatus == 'peck-attack' then
        fx, fy = self:peckAttack()
    elseif self.peckStatus == 'return' then

    end

    vx = range_bound(vx, enemy.movementSpeed, - enemy.movementSpeed)
    vy = range_bound(vy, 100, -30)

    self.head.collider:applyForce(fx, fy)
    self.head.collider:setLinearVelocity(vx, vy)
end

function Sumoga:peckChase()
    local fx = 0
    self.head.collider:setGravityScale(0)

    -- sprite sigue al jugador basado en la posicion
    if self.x < player.x then
        fx = enemy.dx
    else
        fx = enemy.dx * -1
    end
    if not self.timerActive then
        Timer.after(self.peckTime, function() 
            self.peckStatus = 'peck-rise'
            self.timerActive = false
        end)
        self.timerActive = true
    end
    return fx, 0
end

function Sumoga:peckRise()
    local fx, fy = 0, -30

    if not self.timerActive then
        Timer.after(0.4, function()
            self.peckStatus = 'peck-attack'
            self.timerActive = false
        end)
        self.timerActive = true
    end

    return fx, fy
end

function Sumoga:peckAttack()
    local fx, fy = 0, 40
    self.peckTime = math.random(2, 5 * self.actionSpeed)
    
    if self.collider:enter('Player') or self.collider:enter('Solid') then
        self.peckStatus = 'return'
    end

    return fx, fy
end

function Sumoga:eggThrow()
    egg = SumogaEgg(self.head.x, self.head.y)
    table.insert(enemies, egg)
end

function Sumoga:updateActionSpeed()
    lifePercentage = self.maxHealth/self.health
    self.actionSpeed = math.cos(lifePercentage - 1)
end

function Sumoga:fuckingDies()
    -- rip
    Timer.clear()
end

function Sumoga:takeDamage(damage)
    table.insert(animations, Text(round(self.leg.x - self.leg.width/2), player.y -5, damage, round(self.leg.x - self.leg.width/2), player.y -10, 1))
    table.insert(animations, Text(round(self.head.x - self.head.width/2), self.head.y - self.head.height, damage, round(self.head.x - self.head.width/2), self.head.y - self.head.height - 4, 1))
    love.audio.playSound(hitEnemySound)
    self.health = self.health - damage
    if self.health <= 0 then
        self.health = 0
        self.alive = false
    end
end