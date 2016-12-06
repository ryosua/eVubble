-- Modules
local bouncyWalls = require "modules.bouncyWalls"
local bubbleCntl = require "modules.bubbleCntl"
local composer = require "composer"
local controls = require "modules.controls"
local dynamicBackground = require "modules.dynamicBackground"
local fonts = require "modules.fonts"
local memoryManagement = require "modules.memoryManagement"
local musicAndSound = require "modules.musicAndSound"
local physics = require "physics"

local font = fonts.getMarkerFeltBold()
local fontSize = 18
local taps = 0

local background
local bubbleCntlI
local onBackgroundTouch
local player
local runtimeFunction

-- Memory Management
local transitionStash = {}

local scene = composer.newScene()

local function showOverlay()
    local ANIMATION_LENGTH = 250

    local options =
    {
        isModal = true,
        effect = "slideUp",
        time = ANIMATION_LENGTH,
    }

    composer.showOverlay( "scenes.tutorialDecision", options )
end 

local function onTap()
    taps = taps + 1
    if taps == 3 then
        showOverlay()
    end
end

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = nil

    physics.start()
    physics.setGravity(0, 0)

    -- Uncomment to see physics bodies
    --physics.setDrawMode( "hybrid" )

    local wallGroup = bouncyWalls.new()

    bubbleCntlI = bubbleCntl.new(bubbleCntl.thePlayerShouldHaveATail(saves.upgradeSelections), sceneGroup, transitionStash)
    controls.resetControls()

    -- Play pop sound on scene load
    musicAndSound.playSound("pop")
    
    background = display.newImage( "images/background.png" )
    background.x = W / 2
    background.y = H / 2

    -- Create the dynamic background
    local dynamicBackroundLayer = dynamicBackground.newDynamicBackroundLayer()
    
    player = bubbleCntlI.newPlayer(bubbleCntlI.getInitialPlayerSize(), W/2, H/2, 0, 0, sceneGroup)
    wallGroup.update(player)

    runtimeFunction = function( event )
        dynamicBackground.move(dynamicBackroundLayer) -- animate the background

        player.x , player.y = controls.wrapEffect(player)
        controls.movePlayer(player, saves.sensitivity)
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )

    --[[
        If an touch event is detected by the background, then it will stop the controls.
    ]]--
    function onBackgroundTouch(e) 
        if e.phase == "began" then
            -- Set the touch location so a force can be applied in that direction.
            controls.setTouchX(e.x)
            controls.setTouchY(e.y)

            -- Player is now touching the background.
            controls.setTouchingBackground(true)

        elseif e.phase == "ended" then
            -- Player stopped touching the background.
            controls.setTouchingBackground(false)

            onTap()
        end

        return true
    end

    background:addEventListener( "touch", onBackgroundTouch )   

    local hintText = display.newText("Tap to move", W * .5, H * .9, font, fontSize )
    hintText.alpha = .75
    hintText:setFillColor( 0, 0, 0 )

    sceneGroup:insert( background )
    sceneGroup:insert( dynamicBackroundLayer )
    sceneGroup:insert( player )
    sceneGroup:insert( hintText )
    sceneGroup:insert( wallGroup )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
 
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        audio.setVolume(1, {channel = 1}) -- sets channel volume back to 1, because it persists across scenes
        audio.stop()
    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    Runtime:removeEventListener ("enterFrame", runtimeFunction)
    runtimeFunction = nil

    -- Remove event listeners.
    background:removeEventListener( "touch", onBackgroundTouch )  

    player = bubbleCntlI.deleteObject(player)

    memoryManagement.cancelAllTransitions(transitionStash)

    bubbleCntlI.clean()
    bubbleCntlI = nil
    collectgarbage()
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene