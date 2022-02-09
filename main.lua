push = require 'push'
Class = require 'libraries/hump/class'

Gamestate = require "libraries/hump/gamestate"
main_menu = require "states/main_menu"
game_loop = require "states/game_loop"
wf = require '../libraries/windfield'
world = wf.newWorld(0, 60)
require 'collision_extension'

anim8 = require '/libraries/anim8'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 84
VIRTUAL_HEIGHT = 48

cam_x = 0
cam_y = 0

function love.load()
    love.window.setTitle('gamejam nokia')
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('Ark.ttf', 8)
    love.graphics.setFont(smallFont)
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        pixelperfect = true,
    })

    Gamestate.registerEvents({'update', 'keypressed', 'keyreleased'})
    Gamestate.switch(main_menu)

    -- Configure world collisions
    world:addCollisionClass('Solid')
    world:addCollisionClass('Enemy')
    world:addCollisionClass('Player')
    world:addCollisionClass('Player_Projectile', {ignores = {'Player', 'Player_Projectile'}})

    -- Manage input
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
     -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    -- Delte following code on production
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key)
     -- add to our table of keys released this frame
    love.keyboard.keysReleased[key] = true
end

function love.keyboard.wasPressed(...)
    local args = {...}
    for i,key in pairs(args) do
        if love.keyboard.keysPressed[key] then
            return true
        end
    end
    return false
end

function love.keyboard.wasReleased(...)
    local args = {...}
    for i,key in pairs(args) do
        if love.keyboard.keysReleased[key] then
            return true
        end
    end
    return false
end

function love.update(dt)
    Gamestate.current():update(dt)

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.draw()
    push:apply('start')

    Gamestate.current():draw()
    -- love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 10, 10)

    push:apply('end')
end

function range_bound(value, max_value, min_value)
    if value > max_value then
        value = max_value
    elseif value < min_value then
        value = min_value
    end
    return value
end