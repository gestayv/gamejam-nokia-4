Sumoga = Class{}

TILE_SIZE = 8

function Sumoga:init()
    -- necesitamos indicar en que fase va y manejar el hp de cada fase de forma separada
    -- cuando cambia la fase tenemos que cambiar el sprite, o el spritesheet en caso de ser necesario
    
    -- self.spriteSheet = love.graphics.newImage('/sprites/enemies.png')
    -- self.grid = anim8.newGrid(8, 8, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    -- self.animations = {}
end

-- como la pelea es scripted, en terminos de como se va a mover y los ataques que va a realizar, va a funcionar
-- un poco distinto a los enemigos comunes y corrientes
function Sumoga:update(dt)
end

function Sumoga:render()
    love.graphics.rectangle("fill", math.floor(self.x - self.width/2 + 0.5), math.floor(self.y - self.height/2 + 0.5), self.width, self.height)
end

function Sumoga:destroy()
    self.collider:destroy()
end

function Sumoga:changeDirection()
    -- Para que funcione el stay, se deben llamar ambos: el enter y el exit
    if self.collider:exit('Solid') then end
    if self:collideWithWall() or self:collidingWithWall() or self:fallOnNextStep() then
       self.direction = - self.direction
    end
end

