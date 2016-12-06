-- Modules
local composer = require "composer"
local fonts = require "modules.fonts"
local imageSheet = require "modules.imageSheet"

local continue
local figure

local function switchScene(e)
    composer.gotoScene(e.target.scene)
    
    return true
end

local scene = composer.newScene()
function scene:create( event )
    local sceneGroup = self.view

    local font = fonts.getMarkerFeltBold()
    local fontSize = 20

    local function hideOverlay()
        params.cntl.hideOverlay(params.event)

        return true
    end

    local blackFade  = display.newRect( 0, 0, W, H)
    blackFade.alpha = .95
    blackFade.anchorX = 0
    blackFade.anchorY = 0
    blackFade:setFillColor(0, 0, 0)

    local textW = W * .5

    local continueText = display.newText("Continue with tutorial?" , textW, H * .20, font, fontSize)
    continueText:setFillColor( 1, 1, 1 )
    continueText.anchorX = .5

    local figureText = display.newText("Skip for now (it can be turned on in options)." , textW, continueText.y + H * .40, font, fontSize)
    figureText:setFillColor( 1, 1, 1 )
    figureText.anchorX = .5
  
    local BTN_SCALE = .250
    local VERTICAL_SPACE = H*.10
    
    continue = display.newImage("images/check.png")
    continue.xScale = BTN_SCALE
    continue.yScale = BTN_SCALE
    continue.anchorX = .50
    continue.anchorY = 0
    continue.x = textW
    continue.y = continueText.y + VERTICAL_SPACE
    continue.scene = "scenes.tutorial"
    continue:addEventListener( "tap", switchScene )
    
    figure = display.newImage("images/deny.png")
    figure.xScale = BTN_SCALE
    figure.yScale = BTN_SCALE
    figure.anchorX = .50
    figure.anchorY = 0
    figure.x = textW
    figure.y = figureText.y + VERTICAL_SPACE
    figure.scene =  "scenes.level1"
    figure:addEventListener( "tap", switchScene )

    sceneGroup:insert( blackFade )
    sceneGroup:insert( continueText )
    sceneGroup:insert( continue )
    sceneGroup:insert( figureText )
    sceneGroup:insert( figure )
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

    -- Remove event listeners.
    continue:removeEventListener( "tap", switchScene )
    figure:removeEventListener( "tap", switchScene )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene