-- Modules
local composer = require "composer"
local dynamicBackground = require "modules.dynamicBackground"
local fonts = require "modules.fonts"
local musicAndSound = require "modules.musicAndSound"
local UI = require "modules.UI"

local font = fonts.getMarkerFeltBold()
local fontSize = 30

local runtimeFunction
local threeStarsBtn
local oneStarBtn
local onOneStarBuy
local onThreeStarsBuy

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "scenes.evolve"
    
    local background = display.newImage("images/fade.png", 0, 0 )
    background.x = W * .50
    background.y = H * .50
    background.alpha = .50
    
    local oneStarText = display.newText("Purchase 1 star?", W * .2, H/3 , font, fontSize)
    oneStarText.anchorX = 0

    local threeStarsText = display.newText("Purchase 3 stars?", oneStarText.x, H * 2/3 , font, fontSize)
    threeStarsText.anchorX = 0
    
    oneStarBtn = display.newImage("images/store1Star.png")
    oneStarBtn.x = W * .75
    oneStarBtn.y = oneStarText.y
    oneStarBtn.xScale = .25
    oneStarBtn.yScale  = oneStarBtn.xScale

    threeStarsBtn = display.newImage("images/store3Star.png")
    threeStarsBtn.x = oneStarBtn.x
    threeStarsBtn.y = threeStarsText.y
    threeStarsBtn.xScale = .25
    threeStarsBtn.yScale  = threeStarsBtn.xScale

    local inAppPurchaseControllerI = composer.state.singletonsI.getInAppPurchasesI()

    local spinner = inAppPurchaseControllerI.newSpinner()

    function onOneStarBuy()
        inAppPurchaseControllerI.purchaseOneStar()
        return true
    end

    function onThreeStarsBuy()
        inAppPurchaseControllerI.purchaseThreeStars()
        return true
    end

    oneStarBtn:addEventListener( "tap", onOneStarBuy )
    threeStarsBtn:addEventListener( "tap", onThreeStarsBuy )

    local homeBtn = UI.newHomeButton("light", true)

    -- Create the dynamic background
    local dynamicBackroundLayer = dynamicBackground.newDynamicBackroundLayer()
    
    runtimeFunction = function( event )
        dynamicBackground.move(dynamicBackroundLayer) -- animate the background
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )
    
    sceneGroup:insert( dynamicBackroundLayer )
    sceneGroup:insert( background )
    sceneGroup:insert( oneStarText )
    sceneGroup:insert( threeStarsText )
    sceneGroup:insert( oneStarBtn )
    sceneGroup:insert( threeStarsBtn )
    sceneGroup:insert( homeBtn )
    sceneGroup:insert( spinner )
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

    Runtime:removeEventListener("enterFrame", runtimeFunction)
    runtimeFunction = nil

    -- Remove event listeners.
    oneStarBtn:removeEventListener( "tap", onOneStarBuy )
    threeStarsBtn:removeEventListener( "tap", onThreeStarsBuy )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene