-- Modules
local composer = require "composer"
local fonts = require "modules.fonts"
local musicAndSound = require "modules.musicAndSound"
local widget = require "widget"

local sensitivity

local function changeScene(e)
    composer.gotoScene(e.target.scene)

    return true
end

--[[
    Adjusts the touch sensitiviy.
]]--
local function sliderListener(e)
    if e.phase == "ended" then
        saves.sensitivity = e.value
        loadsave.saveData(saves)
    end
end

local function hideSensitivityOverlay(e)
    musicAndSound.playSound("pop")
    composer.hideOverlay("slideDown")
end

local scene = composer.newScene()
function scene:create( event )
    local sceneGroup = self.view

    local font = fonts.getMarkerFeltBold()
    local fontSize = 25

    local blackFade  = display.newRect( 0, 0, W, H )
    blackFade.alpha = .925
    blackFade.anchorX = 0
    blackFade.anchorY = 0
    blackFade:setFillColor(0, 0, 0)

    local sensitivityTxt = display.newText( "Sensitivity", W * .50, H*.40, font, fontSize )
    sensitivityTxt:setFillColor(1, 1, 1)
    sensitivityTxt.anchorX = .5
    sensitivityTxt.anchorY = 0
 
    sensitivity = display.newImage( "images/collapseTrayBtn.png", W * .5, H * .5)
    sensitivity.scene = "scenes.optionsOverlay"
    sensitivity.x = (W * .90)
    sensitivity.y = H * .90
    sensitivity.alpha = .75
    sensitivity.anchorX = .5
    sensitivity.anchorY = .5
    sensitivity.xScale = 0.50
    sensitivity.yScale = 0.50
    sensitivity:addEventListener("tap", hideSensitivityOverlay)

    local slider = widget.newSlider
    {
        sheet = imageSheet.sliderSheet,
        leftFrame = 1,
        middleFrame = 2,
        rightFrame = 3,
        fillFrame = 4,
        frameWidth = 55,
        frameHeight = 50,
        handleFrame = 5,
        handleWidth = 50,
        handleHeight = 50,
        top = H*.50,
        left = (W * .25),
        orientation = "horizontal",
        width = W * .50,
        value = tonumber(saves.sensitivity),
        listener = sliderListener
    }

    sceneGroup:insert( blackFade )
    sceneGroup:insert( sensitivity )
    sceneGroup:insert( sensitivityTxt )
    sceneGroup:insert( slider )
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
    sensitivity:addEventListener("tap", hideSensitivityOverlay)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene