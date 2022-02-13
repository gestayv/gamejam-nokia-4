SumogaEgg = Class{}

function SumogaEgg:init(x, y)
    self.x = x
    self.y = y
    self.strength = 1
    self.health = player.attack * 15
    self.width = 8
    self.height = 8
    self.alive = true
    self.falling = true
    
    self.collider = world:newRectangleCollider(x, y, self.width, self.height)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFriction(0)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)

    self.grid = anim8.newGrid(8, 8, spriteSheet:getWidth(), spriteSheet:getHeight())

    self.animations = {}
    self.animations.falls = anim8.newAnimation(grid('1-1', 5), 0.5)
    self.animations.breaks = anim8.newAnimation(grid('2-4', 5), 0.2, 'pauseAtEnd')
    self.anim = self.animations.falls
end

function SumogaEgg:update(dt)
    local fx = 0
    local fy = 0

    vx, vy = self.collider:getLinearVelocity()
    vx = range_bound(vx, 0, 0)
    vy = range_bound(vy, 30, 0)
    
    self.collider:applyForce(0, 50)
    self.collider:setLinearVelocity(vx, vy) 
    self.x = self.collider:getX()
    self.y = self.collider:getY()
    self:breaks()
    self.anim:update(dt)
end

function SumogaEgg:render()
    self.anim:draw(spriteSheet, round(self.x - self.width / 2), round(self.y - self.height / 2))
end

function SumogaEgg:takeDamage()
    -- do nothing
end

function SumogaEgg:breaks()
    if (self.collider:enter('Solid') or self.collider:enter('Player') or self.collider:enter('Enemy')) and self.falling then
        self.falling = false
        self.collider:setCollisionClass('Ghost')
        self.anim = self.animations.breaks
        Timer.after(0.6, function() 
            enemy = Enemy(self.x, self.y, {type = 'chick', itemType = 'recovery', drop = 'rng'})
            table.insert(enemies, enemy)
        end)
        Timer.after(1, function() self.alive = false end)
    end
end

function SumogaEgg:destroy()
    self.collider:destroy()
end
