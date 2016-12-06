-- Modules
local composer = require "composer"
local dynamicOptions = require "modules.dynamicOptions"
local fonts = require "modules.fonts"
local memoryManagement = require "modules.memoryManagement"
local musicAndSound = require "modules.musicAndSound"
local platform = require "modules.platform"
local UI = require "modules.UI"

local closeDialog
local changeMute
local changeTutorialSettings
local closeTutorialDialog
local musicMute
local musicOnOff 
local noButton
local promptDialog
local promptTutorialDialog
local reset
local resetData
local runtimeFunction
local sensitivity
local soundMute
local soundOnOff
local tutorialDialog
local tutorialYesButton
local tutorialNoButton
local tutorialBtn
local tutorialOff
local warningDialog
local yesBtn

local function showSensitivityOverlay(e)
    musicAndSound.playSound("pop")

    local options =
    {
        isModal = true,
        effect = "slideUp",
        --time = 400,
    }

    composer.showOverlay( "scenes.optionsOverlay", options )
end

--[[
    This function does only one thing - return true.
    This means that when the player clicks on the background, the dialog box will close unless they
    click the dialogBox itself because it the event will be handled (that's what returning true does)
]]
local function blockTouch(e) 
    return true
end

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "scenes.menu"

    local font = fonts.getMarkerFeltBold()
    local fontSize = 25
    local spacing = (H * .11 )--spacing between options in y direction
    local xSpacing = (W * .03)

    local background = display.newImage ("images/options.png", 0, 0 )
    background.x = W / 2
    background.y = H / 2

    local dynamicOptionsLayer = dynamicOptions.newDynamicOptionsLayer()

    local textX = (W * .35)
    local textY = H * .40

    local homeBtn = UI.newHomeButton("dark", true)

    reset = display.newImage( "images/resetBtn.png",0 ,0 )
    reset.x = W * .10
    reset.y = homeBtn.y
    reset.xScale = .65
    reset.yScale = reset.xScale
    reset.alpha = .50
    reset.anchorX = .5
    reset.anchorY = .5
 
    warningDialog, yesBtn, noButton = UI.newWarningDialog("Reset all Data?")

    function closeDialog()
        musicAndSound.playSound("pop")
        warningDialog.alpha = 0
        return true
    end
    warningDialog:addEventListener( "tap", blockTouch )
    noButton:addEventListener( "tap",  closeDialog)

    soundOnOff = display.newImage( "images/soundBtn.png", W*.5 - (1.5*spacing), H*.675 )
    soundOnOff.on_off = "sound2"
    soundOnOff.anchorX = .5
    soundOnOff.anchorY = .5
    soundOnOff.xScale = 0.25
    soundOnOff.yScale = soundOnOff.xScale

    musicOnOff = display.newImage( "images/musicBtn.png", soundOnOff.x - (3*spacing), soundOnOff.y)
    musicOnOff.on_off = "music2"
    musicOnOff.anchorX = .5
    musicOnOff.anchorY = .5
    musicOnOff.xScale = soundOnOff.xScale
    musicOnOff.yScale = soundOnOff.xScale

    -- Mute images
    soundMute = display.newImage( "images/soundMute.png", soundOnOff.x, soundOnOff.y)
    soundMute.on_off = "soundMute"
    soundMute.anchorX = soundOnOff.anchorX
    soundMute.anchorY = soundOnOff.anchorY
    soundMute.xScale = soundOnOff.xScale
    soundMute.yScale = soundOnOff.xScale
    soundMute.alpha = 0

    musicMute = display.newImage( "images/musicMute.png", musicOnOff.x, musicOnOff.y )
    musicMute.on_off = "musicMute"
    musicMute.anchorX = musicOnOff.anchorX
    musicMute.anchorY = musicOnOff.anchorY
    musicMute.xScale = soundOnOff.xScale
    musicMute.yScale = soundOnOff.xScale
    musicMute.alpha = 0

    sensitivity = display.newImage( "images/sensitivityBtn.png", soundOnOff.x + (3*spacing), soundOnOff.y )
    sensitivity.scene = "scenes.optionsOverlay"
    sensitivity.anchorX = .5
    sensitivity.anchorY = .5
    sensitivity.xScale = soundOnOff.xScale
    sensitivity.yScale = soundOnOff.xScale
    
    tutorialBtn = display.newImage( "images/TutorialBtn.png", sensitivity.x + (3*spacing), musicOnOff.y )
    tutorialBtn.anchorX = musicOnOff.anchorX
    tutorialBtn.anchorY = musicOnOff.anchorY
    tutorialBtn.xScale = soundOnOff.xScale
    tutorialBtn.yScale = soundOnOff.xScale
    tutorialBtn.alpha = 0
    
    tutorialOff = display.newImage( "images/TutorialOff.png", sensitivity.x + (3*spacing), musicOnOff.y )
    tutorialOff.anchorX = musicOnOff.anchorX
    tutorialOff.anchorY = musicOnOff.anchorY
    tutorialOff.xScale = soundOnOff.xScale
    tutorialOff.yScale = soundOnOff.xScale
    tutorialOff.alpha = 1

    local enableText = "Enable tutorial before next play?"
    local disableText = "Disable tutorial before next play?"

    local tutorialText

    if saves.tutorial == false then
        tutorialText = enableText
        tutorialOff.alpha = 1
            tutorialBtn.alpha = 0
    else
        tutorialText = disableText
        tutorialOff.alpha = 0
        tutorialBtn.alpha = 1
    end
    
    tutorialDialog, tutorialYesButton, tutorialNoButton = UI.newWarningDialog(enableText)

    function promptDialog(e)
        musicAndSound.playSound("pop")

        if warningDialog.alpha == 0 then
            warningDialog.alpha = 1
        else
            warningDialog.alpha = 0
        end

        return true
    end
    
    function promptTutorialDialog()
        musicAndSound.playSound("pop")

        if saves.tutorial == false then
            tutorialText = enableText
        else
            tutorialText = disableText
        end

        tutorialDialog.setText(tutorialText)
        tutorialDialog.alpha = 1
    
        return true
    end

    function closeTutorialDialog()
        musicAndSound.playSound("pop")
        tutorialDialog.alpha = 0
        return true
    end
    tutorialDialog:addEventListener("tap", blockTouch)

    -- Mute Options:
        -- neither (default)
        -- both
        -- music
        -- sound

    if saves.muteToggle == "neither" then
        musicOnOff.alpha = 1
        soundOnOff.alpha = 1
        musicMute.alpha = 0
        soundMute.alpha = 0
        musicOnOff.pushed = false
        soundOnOff.pushed = false

    elseif saves.muteToggle == "both" then
        musicOnOff.alpha = 0
        soundOnOff.alpha = 0
        musicMute.alpha = 1
        soundMute.alpha = 1
        musicOnOff.pushed = true
        soundOnOff.pushed = true

    elseif saves.muteToggle == "music" then
        musicOnOff.alpha = 0
        soundOnOff.alpha = 1
        musicMute.alpha = 1
        soundMute.alpha = 0
        musicOnOff.pushed = true
        soundOnOff.pushed = false

    elseif saves.muteToggle == "sound" then
        musicOnOff.alpha = 1
        soundOnOff.alpha = 0
        musicMute.alpha = 0
        soundMute.alpha = 1
        musicOnOff.pushed = false
        soundOnOff.pushed = true
    end

    sensitivity:addEventListener ( "tap", showSensitivityOverlay )

    function resetData(e)
        if warningDialog.alpha == 1  then

            memoryManagement.eraseAllData()

            musicOnOff.alpha = 1
            soundOnOff.alpha = 1
            musicMute.alpha = 0
            soundMute.alpha = 0
            tutorialOff.alpha = 0
            tutorialBtn.alpha = 1
            musicOnOff.pushed = false
            soundOnOff.pushed = false

            warningDialog.alpha = 0

            musicAndSound.playSound("pop")
        end

        return true
    end

    function changeMute(e)
        local soundSettingBefore = saves.muteToggle

        if warningDialog.alpha == 0  then

            if e.target.on_off == "music2" and e.target.pushed == false then
                e.target.alpha = 0
                musicMute.alpha = 1
                e.target.pushed = true

            elseif e.target.on_off == "sound2" and e.target.pushed == false then
                e.target.alpha = 0
                soundMute.alpha = 1
                e.target.pushed = true

            elseif (e.target.on_off == "soundMute") then
                e.target.alpha = 0
                soundOnOff.alpha = 1
                soundOnOff.pushed = false

            elseif (e.target.on_off == "musicMute") then
                e.target.alpha = 0
                musicOnOff.alpha = 1
                musicOnOff.pushed = false

            elseif e.target.pushed then
                --regardless of the button, set it to false, make black
                e.target.pushed = false
                if (e.target.on_off == "music2") or (e.target.on_off == "sound2") then
                    e.target.alpha = 1
                else
                e.target:setFillColor(0, 0, 0)
                end

            end

            -- Look at which buttons are pushed and saves accordingly.
            if (musicOnOff.pushed and soundOnOff.pushed) then
                saves.muteToggle = "both"

            elseif (musicOnOff.pushed) then
                saves.muteToggle = "music"

            elseif (soundOnOff.pushed) then
                saves.muteToggle = "sound"

            elseif (not musicOnOff.pushed ) and (not soundOnOff.pushed ) then
                saves.muteToggle = "neither"
            end

            if (soundSettingBefore == "sound" or soundSettingBefore == "neither")  and (saves.muteToggle == "music" or saves.muteToggle == "both") then
                musicAndSound.stopMusic()
                musicAndSound.setMenuMusicPlaying(false)
            elseif (soundSettingBefore == "music" or soundSettingBefore == "both")  and (saves.muteToggle == "sound" or saves.muteToggle == "neither") then
                musicAndSound.startMenuMusic()
                musicAndSound.setMenuMusicPlaying(true)
            end

            -- Save mute toggle.
            loadsave.saveData(saves)

            musicAndSound.playSound("pop")
        end

        return true
    end

    runtimeFunction = function( event )
        dynamicOptions.move(dynamicOptionsLayer) -- animate the background
    end
    
    function changeTutorialSettings()
        if saves.tutorial == false then
            saves.tutorial = true
            loadsave.saveData(saves)
            tutorialBtn.alpha = 1
            tutorialOff.alpha = 0
        else
            saves.tutorial = false
            loadsave.saveData(saves)
            tutorialBtn.alpha = 0
            tutorialOff.alpha = 1
        end

        closeTutorialDialog()
        
        return true
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )

    musicOnOff:addEventListener ("tap", changeMute )
    soundOnOff:addEventListener ("tap", changeMute )
    soundMute:addEventListener ("tap", changeMute )
    musicMute:addEventListener ("tap", changeMute )
    reset:addEventListener ("tap", promptDialog )
    yesBtn:addEventListener ( "tap", resetData )
    tutorialYesButton:addEventListener ( "tap", changeTutorialSettings )
    tutorialNoButton:addEventListener ("tap", closeTutorialDialog)
    tutorialBtn:addEventListener( "tap", promptTutorialDialog )
    tutorialOff:addEventListener( "tap", promptTutorialDialog )

    sceneGroup:insert( background )
    sceneGroup:insert( dynamicOptionsLayer )
    sceneGroup:insert( homeBtn )
    sceneGroup:insert( musicOnOff )
    sceneGroup:insert( soundOnOff )
    sceneGroup:insert( soundMute )
    sceneGroup:insert( musicMute )
    sceneGroup:insert( sensitivity )
    sceneGroup:insert( tutorialBtn )
    sceneGroup:insert( tutorialOff )
    sceneGroup:insert( warningDialog )
    sceneGroup:insert( reset )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        -- Play pop sound on scene load
        musicAndSound.playSound("pop")
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    Runtime:removeEventListener ("enterFrame", runtimeFunction)
    runtimeFunction = nil

    -- Remove event listeners.
    warningDialog:removeEventListener( "tap", blockTouch )
    noButton:removeEventListener( "tap",  closeDialog)
    tutorialDialog:removeEventListener("tap", blockTouch)
    sensitivity:removeEventListener ( "tap", showSensitivityOverlay )
    musicOnOff:removeEventListener ("tap", changeMute )
    soundOnOff:removeEventListener ("tap", changeMute )
    soundMute:removeEventListener ("tap", changeMute )
    musicMute:removeEventListener ("tap", changeMute )
    reset:removeEventListener ("tap", promptDialog )
    yesBtn:removeEventListener ( "tap", resetData )
    tutorialYesButton:removeEventListener ( "tap", changeTutorialSettings )
    tutorialNoButton:removeEventListener ("tap", closeTutorialDialog)
    tutorialBtn:removeEventListener( "tap", promptTutorialDialog )
    tutorialOff:removeEventListener( "tap", promptTutorialDialog )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene