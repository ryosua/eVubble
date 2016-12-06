local musicAndSound = {}

-- Sounds
local sounds = {}
    sounds.bounce = audio.loadSound("audio/pumpkin.mp3")
    sounds.evolve = audio.loadSound("audio/evolveSound.mp3")
    sounds.highscoreSound = audio.loadSound("audio/highscore.mp3")
    sounds.loseSound = audio.loadSound("audio/loseSound.mp3")
    sounds.pop = audio.loadSound("audio/bubblePopSmall.mp3")
    sounds.powerUpSound = audio.loadSound("audio/powerUp.mp3")
    sounds.starSound = audio.loadSound("audio/starSound.mp3")
    sounds.winSound = audio.loadSound("audio/winSound.mp3")
    
local levelMusicFile = "audio/odyssey.mp3"
local levelMusic = audio.loadStream( levelMusicFile ) -- loadStream can cause latency but uses less memory.

local menuMusicFile = "audio/menuMusic.mp3"
local menuMusic = audio.loadStream( menuMusicFile )

local menuMusicPlaying = false

-- Reserve the first two channels for music, the rest of the channels will be used for sound.
audio.reserveChannels(2)

--[[
    Allows iPod music, and game sounds to be played at the same time.
    This function is constructed from a block of code from the Corona forum, with slight modifications.
]]--
function musicAndSound.enableIpodMusic()
    -- Set the audio mix mode to allow sounds from the app to mix with other sounds from the device
    if audio.supportsSessionProperty == true then
        audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
    end
     
    -- Store whether other audio is playing.  It's important to do this once and store the result now,
        -- as referring to audio.OtherAudioIsPlaying later gives misleading results, since at that point
        -- the app itself may be playing audio
    isOtherAudioPlaying = false
     
    if audio.supportsSessionProperty == true then
        if not(audio.getSessionProperty(audio.OtherAudioIsPlaying) == 0) then
            isOtherAudioPlaying = true
        end
    end
end

local function playMusic(music, channel, loops)
    if (saves.muteToggle == "sound") or (saves.muteToggle == "neither") then
        audio.rewind( music ) 
        audio.play( music, { channel= channel, loops = loops, fadein= 0 }  )
        audio.setVolume(1, {channel = channel})
    end
end

--[[
    Plays a sound only if the sound setting is not muted.
    
    sound - a string to select sound to play
]]--
function musicAndSound.playSound(sound)
    assert((sound == "bounce" or
            sound == "evolve" or
            sound == "highscoreSound" or
            sound == "loseSound" or
            sound == "pop" or
            sound == "powerUpSound" or
            sound == "starSound" or
            sound == "winSound") 
    , "That sound is not recognized." )

    local soundToPlay = sounds[sound]
    
    if saves.muteToggle == "neither" or saves.muteToggle == "music" then
        audio.play(soundToPlay)
    end
end

function musicAndSound.startLevelMusic() 
    playMusic(levelMusic, 1, -1)
end

function musicAndSound.startMenuMusic()
    playMusic(menuMusic, 1, -1)
end

function musicAndSound.getMenuMusicPlaying()
    return menuMusicPlaying
end

function musicAndSound.setMenuMusicPlaying(playing)
    menuMusicPlaying = playing
end

function musicAndSound.stopMusic()
    audio.setVolume(1, {channel = 1}) -- sets channel volume back to 1, because it persists across scenes
    audio.stop()
end

return musicAndSound