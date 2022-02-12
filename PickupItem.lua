PickupItem = Class{}

itemProperties = {
    attack = {
        action = function(self)
            local amount = self:defaultAmount(5)
            player.attack = player.attack + amount
        end,
        sprite = nil,
        animation = nil,
        width = 5,
        height = 5,
    },
    recovery = {
        action = function(self)
            local amount = self:defaultAmount(30)
            player:recover(amount)
        end,
        sprite = nil,
        animation = nil,
        width = 5,
        height = 5,
    },
    max_health = {
        action = function(self)
            local amount = self:defaultAmount(20)
            player.maxHealth = player.maxHealth + amount
            player:recover(amount)
        end,
        sprite = nil,
        animation = nil,
        width = 5,
        height = 5,
    }
}

-- Properties needed: type and amount
function PickupItem:init(x, y, properties)
    self.x = x
    self.y = y

    local data = itemProperties[properties.type]
    if properties.amount then
        self.amount = properties.amount
    end
    function self:action()
        data.action(self)
    end
    self.sprite = data.sprite
    self.animation = data.animation
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
        self:action()
        self.alive = false
    end

end

function PickupItem:render()
    love.graphics.setDarkColor()
    love.graphics.rectangle('fill', round(self.x - self.width/2) - 1, round(self.y - self.height/2) - 1, self.width+2, self.height+2)
    love.graphics.setLightColor()
    love.graphics.rectangle('fill', round(self.x - self.width/2), round(self.y - self.height/2), self.width, self.height)
    love.graphics.resetColor()
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
