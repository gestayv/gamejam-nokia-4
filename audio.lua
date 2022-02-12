
AUDIO_VOLUME = 0.02

_sound = nil
_music = nil

function love.audio.playSound( sound )
    if _music then
        _music:setVolume(0)
    end
    if _sound and _sound:isPlaying() then
        _sound:stop()
    end
    _sound = sound
    if _sound then
        _sound:setVolume(AUDIO_VOLUME)
        _sound:play()
    end
end

function love.audio.playMusic( music )
    _music = music
    if _music then
        _music:setLooping(true)
        _music:setVolume(0)
        _music:play()
    end
end

function love.audio.update()
    if _music and (not _sound or not _sound:isPlaying()) then
        _music:setVolume(AUDIO_VOLUME)
    end
end

-- Functions above use setVolume to "stop" music
-- Functions below use play and pause for music

-- function love.audio.playSound( sound )
--     if _music then
--         _music:pause()
--     end
--     if _sound and _sound:isPlaying() then
--         _sound:stop()
--     end
--     _sound = sound
    -- _sound:setVolume(AUDIO_VOLUME)
--     _sound:play()
-- end

-- function love.audio.playMusic( music )
--     _music = music
--     if _music then
--         _music:setLooping(true)
--         _music:setVolume(AUDIO_VOLUME)
--     end
-- end

-- function love.audio.update()
--     if _music and not _music:isPlaying() and (not _sound or not _sound:isPlaying()) then
--         if not _music:isPlaying() then
--             _music:play()
--         end
--     end
-- end