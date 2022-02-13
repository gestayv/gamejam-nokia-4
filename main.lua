-- Libraries
push = require 'push'
Class = require 'libraries/hump/class'

Gamestate = require "libraries/hump/gamestate"
main_menu = require "states/main_menu"
game_loop = require "states/game_loop"
stat_screen = require "states/stat_screen"
credits = require "states/credits"
wf = require '../libraries/windfield'
anim8 = require '/libraries/anim8'
Timer = require './libraries/hump/timer'

-- Helpers
require 'collision_extension'
require 'audio'
require 'animations/helpers'
require 'animations/Text'
require 'animations/ScreenTransition'

-- Constant definitions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 84
VIRTUAL_HEIGHT = 48

-------------------------------------
-- WORLD CREATION
-------------------------------------
world = wf.newWorld(0, 60)
debug_mode = false

function love.load()
    love.window.setVSync(1)

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
    world:addCollisionClass('Player Projectile', {ignores = {'Player', 'Player Projectile'}})
    world:addCollisionClass('Ghost', {ignores = {'Player', 'Player Projectile', 'Enemy'}})
    world:addCollisionClass('Item', {ignores = {'Enemy', 'Player Projectile', 'Ghost'}})
    world:addCollisionClass('Level Transition', {ignores = {'Enemy', 'Player Projectile', 'Ghost', 'Item', 'Solid'}})

    -- Manage input
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Timer.update(dt)

    Gamestate.current():update(dt)
    love.audio.update()

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.draw()
    push:apply('start')

    Gamestate.current():draw()
    -- love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 10, 10)

    push:apply('end')
end

function love.keypressed(key)
     -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    -- Delete following code on production
    if key == "escape" then
        love.event.quit()
    end
    if Gamestate.current() == game_loop then
        if key == "1" then
            nextLevel = levels.tutorial
        end
        if key == "2" then
            nextLevel = levels.level_1
        end
        if key == "3" then
            nextLevel = levels.boss_1
        end
        if key == "7" then
            nextLevel = levels.item_test
        end
        if key == "8" then
            nextLevel = levels.flying_bug
        end
        if key == "9" then
            nextLevel = levels.test_level
        end
        if key == "0" then
            debug_mode = not debug_mode
        end
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

function love.graphics.setLightColor()
    love.graphics.setColor(199/255, 240/255, 216/255, 1)
end

function love.graphics.setDarkColor()
    love.graphics.setColor(67/255, 82/255, 61/255, 1)
end

function love.graphics.resetColor()
    love.graphics.setColor(255,255,255)
end

function range_bound(value, max_value, min_value)
    if value > max_value then
        value = max_value
    elseif value < min_value then
        value = min_value
    end
    return value
end

-- From: https://stackoverflow.com/a/53038524
function array_remove(t, fnKeep)
    local j, n = 1, #t;

    for i=1,n do
        if (fnKeep(t, i, j)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end

function round(number)
    return math.floor(number + 0.5)
end