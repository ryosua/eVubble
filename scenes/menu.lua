-- Modules
local composer = require "composer"
local dynamicMenu = require "modules.dynamicMenu"
local dynamicMenuBtns = require "modules.dynamicMenuBtns"
local evubbleGameNetwork = require "modules.evubbleGameNetwork"
local musicAndSound = require "modules.musicAndSound"

local gears
local infoBtn
local runtimeFunction

local scene = composer.newScene()

local function switchScene(e)
    local scene = e.target.scene
    if saves.tutorial == true and e.target.scene == "scenes.level1" then
        scene = "scenes.touchToMove"
        saves.tutorial = false
        loadsave.saveData(saves)
    end

    composer.gotoScene(scene)
    
    return true
end

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = nil

    local background = display.newImage ("images/levelSelectBackground.png", 0, 0 )
    background.x = W / 2
    background.y = H / 2

    local BTN_SCALE = .285
    local dynamicMenuLayer = dynamicMenu.newDynamicMenuLayer()
    local dynamicMenuBtnsLayer = dynamicMenuBtns.newDynamicMenuBtnsLayer(switchScene)

    gears = display.newImage ( "images/gears.png" )
    gears.xScale = .65
    gears. yScale = gears.xScale
    gears.x = W * .90
    gears.y = H * .15
    gears.alpha = .50
    gears.scene = "scenes.options"

    infoBtn = display.newImage ( "images/infoBtn.png" )
    infoBtn.xScale = .65
    infoBtn. yScale = infoBtn.xScale
    infoBtn.x = gears.x
    infoBtn.y = H * .90
    infoBtn.alpha = .50
    infoBtn.scene = "scenes.about"

    runtimeFunction = function( event )
        dynamicMenu.move(dynamicMenuLayer) -- animate the background
        dynamicMenuBtns.move(dynamicMenuBtnsLayer) --animate the buttons
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )

    gears:addEventListener ( "tap", switchScene )
    infoBtn:addEventListener ( "tap", switchScene )

    sceneGroup:insert( background )
    sceneGroup:insert( dynamicMenuLayer )
    sceneGroup:insert( dynamicMenuBtnsLayer )
    sceneGroup:insert( gears )
    sceneGroup:insert( infoBtn )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        -- Play pop sound on scene load
        musicAndSound.playSound("pop")

        if musicAndSound.getMenuMusicPlaying() == false then
            musicAndSound.startMenuMusic()
            musicAndSound.setMenuMusicPlaying(true)
        end

        -- Level1 creates a lot of garbage, and what better place to clean it then here?
        collectgarbage()
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
    gears:removeEventListener ( "tap", switchScene )
    infoBtn:removeEventListener ( "tap", switchScene )
end

function scene:loadGameNetworkButton()
    dynamicMenuBtns.refreshGameNetworkButton()
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene