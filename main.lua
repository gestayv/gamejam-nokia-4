push = require 'push'
Class = require 'libraries/hump/class'

Gamestate = require "libraries/hump/gamestate"
main_menu = require "states/main_menu"
game_loop = require "states/game_loop"
wf = require '../libraries/windfield'
world = wf.newWorld(0, 3000)

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

    Gamestate.registerEvents({'update', 'keypressed'})
    Gamestate.switch(main_menu)

    -- Configure world collisions
    world:addCollisionClass('Solid')
    world:addCollisionClass('Player')
    world:addCollisionClass('Player_Projectile', {ignores = {'Player'}})
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- Delte following code on production
    if key == "escape" then
        love.event.push("quit")
    end

    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    push:apply('start')

    Gamestate.current():draw()
    -- love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 10, 10)

    push:apply('end')
end