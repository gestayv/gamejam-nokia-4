sti = require '../libraries/sti'
camera = require '../libraries/hump/camera'

require '../Player'
require '../Enemy'
require '../PickupItem'
require '../Hud'

gameMap = nil

local game_loop = {}

levels = {}
levels.tutorial = {
    musicFile = 'audio/music/stage_music_nokia.wav',
    musicType = 'stream',
    mapFile = 'maps/map_level_1.lua'
}
levels.test_level = {
    musicFile = 'audio/music/bad_melody.wav',
    musicType = 'stream',
    mapFile = 'maps/map_test.lua'
}
levels.flying_bug = {
    musicFile = 'audio/music/boss_music_nokia.wav',
    musicType = 'stream',
    mapFile = 'maps/flying_bug.lua'
}
levels.item_test = {
    musicFile = 'audio/music/stage_music_nokia.wav',
    musicType = 'stream',
    mapFile = 'maps/item_test.lua'
}
levels.level_1 = {
    musicFile = 'audio/music/bad_melody.wav',
    musicType = 'static',
    mapFile = 'maps/map_level_2.lua'
}
levels.boss_1 = {
    musicFile = 'audio/music/bad_melody.wav',
    musicType = 'static',
    mapFile = 'maps/map_boss_1.lua'
}

nextLevel = nil

function game_loop:enter()
    -- Load all sounds
    shootSound = love.audio.newSource('audio/sounds/blip2.wav', 'static')
    landSound = love.audio.newSource('audio/sounds/blip4.wav', 'static')
    hitPlayerSound = love.audio.newSource('audio/sounds/blip8.wav', 'static')
    hitEnemySound = love.audio.newSource('audio/sounds/blip9.wav', 'static')
    jumpSound = love.audio.newSource('audio/sounds/blip14.wav', 'static')
    gameOverSound = love.audio.newSource('audio/sounds/negative1.wav', 'static')
    pickupItemSound = love.audio.newSource('audio/sounds/good3.wav', 'static')
    sounds = {shootSound, landSound, hitPlayerSound, hitEnemySound, jumpSound, gameOverSound, pickupItemSound}

    animations = {}

    cam = camera()
    player = Player(0, 0, 6, 8)
    hud = Hud()
    game_loop:switch_level(levels.tutorial)
end

function game_loop:switch_level(level)
    -- Destroy previous level if switching levels
    if nextLevel then
        game_loop:destroy_last_level()
        nextLevel = nil
    end

    gameMap = sti(level.mapFile)

    music = love.audio.newSource(level.musicFile, level.musicType)
    love.audio.playMusic(music)
    
    walls = {}
    enemies = {}
    transitions = {}
    items = {}

    
    if gameMap.layers["Player"] then
        for i, obj in pairs(gameMap.layers["Player"].objects) do
            player:setPosition(obj.x, obj.y)
        end
    end

    if gameMap.layers["Enemies"] then
        for i, obj in pairs(gameMap.layers["Enemies"].objects) do
            enemy = Enemy(obj.x, obj.y + 1, obj.properties)
            table.insert(enemies, enemy)
        end
    end
    
    if gameMap.layers["Items"] then
        for i, obj in pairs(gameMap.layers["Items"].objects) do
            -- Add one to x to center 5x5 or 6x6 item on 8x8 tiles
            item = PickupItem(obj.x + 1, obj.y, obj.properties)
            table.insert(items, item)
        end
    end

    if gameMap.layers["Hitboxes"] then
        for i, obj in pairs(gameMap.layers["Hitboxes"].objects) do
            wall = world:newRectangleCollider(obj.x + 0.2, obj.y + 0.2 , obj.width - 0.4, obj.height - 0.4)
            wall:setType('static')
            wall:setCollisionClass('Solid')
            wall:setFriction(0)
            table.insert(walls, wall)
        end
    end

    if gameMap.layers["Level Transitions"] then
        for i, obj in pairs(gameMap.layers["Level Transitions"].objects) do
            levelTransition = world:newRectangleCollider(obj.x + 0.2, obj.y + 0.2 , obj.width - 0.4, obj.height - 0.4)
            levelTransition.exit_direction = obj.properties.exit_direction
            levelTransition.target = levels[obj.properties.target]
            levelTransition:setType('static')
            levelTransition:setCollisionClass('Level Transition')
            levelTransition:setFriction(0)
            levelTransition:setPreSolve(function(transitionCollider, playerCollider, contact)
                if transitionCollider.collision_class == 'Level Transition' and playerCollider.collision_class == 'Player' then
                    contact:setEnabled(false)
                end
            end)

            table.insert(transitions, levelTransition)
        end
    end
end

function game_loop:destroy_last_level()
    love.audio.playMusic(nil)
    if music then
        music:stop()
        music:release()
    end

    self:destroy_list(walls)
    self:destroy_list(enemies)
    self:destroy_list(items)
    self:destroy_list(transitions)
end

function game_loop:leave()
    self:destroy_last_level()
    love.audio.playSound(nil)
    for i, sound in ipairs(sounds) do
        sound:stop()
        sound:release()
    end

    player:destroy()
end

function game_loop:update(dt)
    -- Switch levels
    if nextLevel then
        game_loop:switch_level(nextLevel)
    end

    -- Limit dt spikes when moving window
    if dt > 0.02 then dt = 0.02 end
    -- First update the world to load collisions
    world:update(dt)
    -- Then update the player to damage enemy with bullets
    player:update(dt)
    -- Then the enemies so they take player damage or damage him
    self:update_list(enemies, dt)
    self:update_list(items, dt)
    self:update_list(animations, dt)
    cam:lookAt(getViewpointForCamera())

    hud:update(dt)
end

function game_loop:keypressed(key, code)
    -- Game over
    if not player.alive then
        if love.keyboard.wasPressed('return') then
            Gamestate.switch(main_menu)
        end
    else 
        if key == 'p' or key == 'return' then
            Gamestate.push(stat_screen)
        end
    end
end

function game_loop:update_list(list, dt)
    for i=#list,1,-1 do
        local obj = list[i]
        obj:update(dt)
        if not obj.alive then
            obj:destroy()
            table.remove(list, i)
        end
    end
end

function game_loop:draw_list(list)
    for i, obj in pairs(list) do
        obj:render()
    end
end

function game_loop:destroy_list(list)
    for i, obj in pairs(list) do
        obj:destroy()
    end
end

function game_loop:draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Layer 1"])
        self:draw_list(enemies)
        self:draw_list(items)
        self:draw_list(animations)
        player:render()
        if debug_mode then
            world:draw() -- this draws colliders, uncomment only if needed
        end
    cam:detach()
    hud:render()
    if not player.alive then
        love.graphics.setDarkColor()
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT / 2 - player.height)
        love.graphics.setLightColor()
        love.graphics.printf('Game over', 0, 0, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter', 0, 9, VIRTUAL_WIDTH, 'center')
    end
end


function getViewpointForCamera()
    gameMapPixelWidth = gameMap.width * gameMap.tilewidth
    gameMapPixelHeight = gameMap.height * gameMap.tileheight

    leftBound = push._RWIDTH/2
    rightBound = leftBound + gameMapPixelWidth - VIRTUAL_WIDTH
    topBound = push._RHEIGHT/2
    bottomBound = topBound + gameMapPixelHeight - VIRTUAL_HEIGHT

    coordsx = round(leftBound - VIRTUAL_WIDTH/2 + player.x)
    coordsy = round(topBound - VIRTUAL_HEIGHT/2 + player.y)

    coordsx = range_bound(coordsx, rightBound, leftBound)
    coordsy = range_bound(coordsy, bottomBound, topBound)
    
    return coordsx, coordsy
end


return game_loop