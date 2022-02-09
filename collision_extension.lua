function isHorizontalCollision(x, width, collider)
    local tx1, ty1, tx2, _ = collider:getBoundingBox()
    -- Check if enemy is colliding with side of wall
    local rightX = x + (width - 1)/2
    local leftX = x - (width - 1)/2
    return rightX <= tx1 or leftX >= tx2
end

function isCollidingOnTop(y, height, collider)
    local _, ty1, _, _ = collider:getBoundingBox()
    return y + height/2 < ty1
end