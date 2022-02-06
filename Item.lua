-- Item class, one item, two items
Item = Class{}

function Item:init(name, quantity, max)
    this.name = name
    this.quantity = quantity
    this.max = max
    this.min = 0
end

function Item:addQuantity(n)
    if this.quantity + n <= this.max then
        this.quantity = this.quantity + n
        return true
    else
        return false
    end
end

function Item:decreaseQuantity(n)
    if this.quantity - n >= this.min then
        this.quantity = this.quantity - n
        return true
    else
        return false
    end
end