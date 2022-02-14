PickupItem = Class{}

itemProperties = {
    attack = {
        action = function(self)
            local amount = self:defaultAmount(2)
            player.attack = player.attack + amount
            return amount
        end,
        spriteRow = 1,
        frames = "1-1",
        width = 8,
        height = 8,
    },
    recovery = {
        action = function(self)
            local amount = self:defaultAmount(20)
            player:recover(amount)
            return amount
        end,
        spriteRow = 1,
        frames = "3-3",
        width = 8,
        height = 8,
    },
    max_health = {
        action = function(self)
            local amount = self:defaultAmount(15)
            player.maxHealth = player.maxHealth + amount
            player:recover(amount)
            return amount
        end,
        spriteRow = 1,
        frames = "2-2",
        width = 8,
        height = 8,
    }
}

itemSpriteSheet = love.graphics.newImage('/sprites/items.png')
itemGrid = anim8.newGrid(8, 8, itemSpriteSheet:getWidth(), itemSpriteSheet:getHeight())

-- Properties needed: type and amount
function PickupItem:init(x, y, properties)
    self.x = x
    self.y = y

    local data = itemProperties[properties.type]
    if properties.amount then
        self.amount = properties.amount
    end
    function self:action()
        return data.action(self)
    end
    self.anim = anim8.newAnimation(itemGrid(data.frames, data.spriteRow), 1)
    self.width = data.width
    self.height = data.height
    self.alive = true

    self.collider = world:newRectangleCollider(x, y, self.width, self.height)
    self.collider:setCollisionClass('Item')
    self.collider:setFriction(0)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
end

function PickupItem:setPosition(x, y)
    self.collider:setPosition(x, y)
    self.collider:setLinearVelocity(0, 0)
    self.x = x
    self.y = y
end

function PickupItem:update(dt)
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    if self.collider:enter('Player') then
        love.audio.playSound(pickupItemSound)
        local amount = self:action()
        table.insert(animations, Text(round(self.x - self.width/2), self.y - self.height, "+".. amount, round(self.x - self.width/2), self.y - self.height - 4, 1))
        self.alive = false
    end
end

function PickupItem:render()
    self.anim:draw(itemSpriteSheet, round(self.x - self.width/2), round(self.y - self.height/2))
end

function PickupItem:destroy()
    self.collider:destroy()
end

function PickupItem:defaultAmount(defaultAmount)
    local amount = defaultAmount
    if self.amount then
        amount = self.amount
    end
    return amount
end
