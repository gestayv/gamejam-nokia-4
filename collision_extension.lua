function isHorizontalCollision(x, width, collider)
    local tx1, ty1, tx2, _ = collider:getBoundingBox()
    -- Check if enemy is colliding with side of wall
    local rightX = x + (width - 1)/2
    local leftX = x - (width - 1)/2
    return rightX <= tx1 or leftX >= tx2
end

function isCollidingOnTop(y, height, collider)
    local _, ty1, _, _ = collider:getBoundingBox()
    local bottomY = y + height/2
    return bottomY <= ty1
end

function isCollidingOnLeft(x, width, collider)
    local tx1, _, _, _ = collider:getBoundingBox()
    local rightX = x + width/2
    return rightX <= tx1
end

function isCollidingOnRight(x, width, collider)
    local _, _, tx2, _ = collider:getBoundingBox()
    local leftX = x - width/2
    return leftX >= tx2
end

function isCollidingOnBottom(y, height, collider)
    local _, _, _, ty2 = collider:getBoundingBox()
    local topY = y - height/2
    print(topY, ty2)
    return topY >= ty2
end

-- direction values: 'top', 'bottom', 'left', 'right'
function exitDirectionFromCollision(direction, playerCollider, transitionCollider)
    local x, y = playerCollider:getPosition()
    local px1, py1, px2, py2 = playerCollider:getBoundingBox()
    local width, height = px2 - px1, py2 - py1

    if direction == 'top' then
        return isCollidingOnTop(y, height, transitionCollider)
    elseif direction == 'left' then
        return isCollidingOnLeft(x, width, transitionCollider)
    elseif direction == 'right' then
        return isCollidingOnRight(x, width, transitionCollider)
    elseif direction == 'bottom' then
        return isCollidingOnBottom(y, height, transitionCollider)
    end
end