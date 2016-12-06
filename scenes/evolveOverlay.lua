-- Modules
local composer = require "composer"
local fonts = require "modules.fonts"
local memoryManagement = require "modules.memoryManagement"
local musicAndSound = require "modules.musicAndSound"
local playerImageSheets = require "modules.imageSheet"
local UI = require "modules.UI"

local blackFade
local button
local hideOverlay
local message
local playerBubble
local purchase
local starCount
local star

--Timer Memory Management
local timerStash = {}
local transitionStash = {}

local function blockTouch(e)
    return true
end

local function getCurrentPlayer(file, index)
    if (file == "playerGrid_1") then
        return display.newImage( playerImageSheets.playerGrid_1, index )

    elseif (file == "playerGrid_2") then
        return display.newImage( playerImageSheets.playerGrid_2, index )
    end
end

local function newCurrentPlayer()
    local currentPlayer = getCurrentPlayer(saves.playerData.frame[1], saves.playerData.frame[2])
    currentPlayer.anchorX = .5
    currentPlayer.anchorY = .5
    currentPlayer.x = (W *.25)
    currentPlayer.y = (H *.4)
    currentPlayer.xScale = .50
    currentPlayer.yScale = currentPlayer.xScale

    return currentPlayer
end

local function refreshPlayerBubble(group)
    if playerBubble ~= nil then
        display.remove( playerBubble )
    end

    playerBubble = newCurrentPlayer()
    playerBubble.x = W * .5
    playerBubble.y = H * .5
    playerBubble:addEventListener( "tap", blockTouch )

    group:insert(playerBubble)

    return playerBubble
end

local scene = composer.newScene()
function scene:create( event )
    local sceneGroup = self.view
    local params = event.params
    local parent = event.parent

    local font = fonts.getSystemFont()
    local markerFont = fonts.getMarkerFeltBold()
    local fontSize = 30

    function hideOverlay()
        params.cntl.hideOverlay(params.event)

        return true
    end

    blackFade  = display.newRect( 0, 0, W, H)
    blackFade.alpha = .925
    blackFade.anchorX = 0
    blackFade.anchorY = 0
    blackFade:setFillColor(0, 0, 0)
    blackFade:addEventListener( "tap", hideOverlay )

    message = display.newText( params.message, 100, 200, markerFont, fontSize)
    message.alpha = .75
    message.x = W * .5
    message.y = H * .15
    message:setFillColor( 1, 1, 1 )
    message.anchorX = .5
    message:addEventListener( "tap", blockTouch )

    function purchase(e)
        params.onPurchaseTap(params.event)
        starCount.text = saves.stars
        message.alpha = 0
        e.target.alpha = 0
        e.target:removeEventListener( "tap", purchase )

        -- Update the player bubble.
        refreshPlayerBubble(sceneGroup)

        -- Play star animation.
        params.cntl.playStarAnimation(playerBubble, transitionStash, sceneGroup)
        musicAndSound.playSound("evolve")

        -- Hide the overlay with a delay.
        timerStash[#timerStash + 1] = timer.performWithDelay(1500, hideOverlay)

        return true
    end

    button = display.newImage( "images/check.png" )
    button.x = W * .85
    button.y = message.y
    local SCALE = .25
    button.xScale = SCALE
    button.yScale = SCALE
    button.anchorY = .5
    button:addEventListener( "tap", purchase )

    local backBtn = display.newImage("images/collapseTrayBtn.png")
    backBtn.x = W * .85
    backBtn.y = H * .9
    backBtn.xScale = .65
    backBtn.yScale = backBtn.xScale
    backBtn.xScale = 0.50
    backBtn.yScale = 0.50

    star = display.newImage("images/starWhite.png", 0, 0)
    star.alpha = .75
    star.anchorX = 0
    star.anchorY = .5
    star.x = W * .1
    star.y = backBtn.y
    star.xScale = .2
    star.yScale = star.xScale
    star:addEventListener( "tap", blockTouch )

    local numberOfStars = saves.stars
    
    starCount = display.newText(numberOfStars,star.x + (star.width * star.xScale),star.y, font, 50)
    starCount:setFillColor(1, 1, 1)
    starCount.alpha = star.alpha
    starCount.anchorX = 0
    starCount.anchorY = star.anchorY
    starCount:addEventListener( "tap", blockTouch )

    sceneGroup:insert( blackFade )

    -- Side effect: inserts image into the group.
    playerBubble = refreshPlayerBubble(sceneGroup)

    sceneGroup:insert( message )
    sceneGroup:insert( button )
    sceneGroup:insert( backBtn )
    sceneGroup:insert( star )
    sceneGroup:insert( starCount )
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

    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    memoryManagement.cancelAllTimers(timerStash)
    memoryManagement.cancelAllTransitions(transitionStash)

    -- Remove event listeners.
    playerBubble:removeEventListener( "tap", blockTouch )
    blackFade:removeEventListener( "tap", hideOverlay )
    message:removeEventListener( "tap", blockTouch )
    button:removeEventListener( "tap", purchase )
    star:removeEventListener( "tap", blockTouch )
    starCount:removeEventListener( "tap", blockTouch )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene