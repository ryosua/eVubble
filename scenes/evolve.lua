-- Modules
local bubbleCntl = require "modules.bubbleCntl"
local composer = require "composer"
local evolveCntl = require "modules.evolveCntl"
local fonts = require "modules.fonts"
local musicAndSound = require "modules.musicAndSound"
local playerImageSheets = require "modules.imageSheet"
local UI = require "modules.UI"
local upgradeCosts = require "modules.upgradeCosts"
local upgradeDescriptions = require "modules.upgradeDescriptions"

local function changeScene(e)
    composer.gotoScene(e.target.scene)
    return true
end

local sheet = imageSheet.enemyImageSheet
local INDICATOR_SCALE = .05
local INDICATOR_SPACING = W * .1

local starCount
local growthUpgradeGroup
local timerUpgradeGroup
local luckUpgradeGroup
local refreshUpgradeGroupsAndStars

local inGameStoreBtn
local noBtn
local reallocateBtn
local warningDialogGroup
local yesBtn

local blockTouch
local reallocateWrapper
local closeDialog
local promptDialog

-- Image sheet indexes
local growthIndex = 2
local timerIndex = 1
local luckIndex = 5

local font = fonts.getSystemFont()
local markerFont = fonts.getMarkerFeltBold()

local UPGRADE_GROUP_X = .1 * W
local UPGRADE_GROUP_Y = .2 * H
local UPGRADE_GROUP_SPACING  = .22 * H

--[[
    Creates a row of indicators for a powerup, to show the user how many they have unlocked.
    
    x - the x position of the first bubble
    y - the y position of the first bubble
    index - the index of powerup on the image sheet
]]--
local function createTripleIndicator(x, y, index, upgradeSelection)
    local indicatorGroup = display.newGroup()
    local numberOfIndicators = 3

    local function createIndicatorFunction(x, y, index)
        local indicator = display.newImage( sheet, index )
        indicator.x = x
        indicator.y = y
        indicator.xScale = INDICATOR_SCALE
        indicator.yScale = INDICATOR_SCALE

        return indicator
    end

    local indicators = {}
    local glows = {}

    -- Create indicators.
    for i = 1, numberOfIndicators do
        local indicator = createIndicatorFunction(x, y, index)
         -- Add the indicator glow.
        local indicatorGlow = display.newImage( "images/selectionIndicator.png" )
        indicatorGlow.x = indicator.x
        indicatorGlow.y = indicator.y
        local scale = .25
        indicatorGlow.xScale = scale
        indicatorGlow.yScale = scale

        indicators[i] = indicator
        glows[i] = indicatorGlow
    end

    -- Space the indicators
    for i = 2, numberOfIndicators do
        indicators[i].x = indicators[i - 1].x +  INDICATOR_SPACING
        glows[i].x = glows[i - 1].x +  INDICATOR_SPACING
    end

    -- Insert all images into the group.
    for i = 1, table.getn(indicators) do
        indicatorGroup:insert(glows[i])
        indicatorGroup:insert(indicators[i])
    end

    -- Hide the indicators that aren't true (getting lazy here).
    for i = 1, numberOfIndicators do
        if i > upgradeSelection - 1 then
            glows[i].alpha = 0
        end
    end

    return indicatorGroup
end

--[[
    One upgrade group consists of the black box, indicator group, label, description,
    and the buttons.
]]--
local function createUpgradeGroup(labelText, upgradeSelections, x, y)
    local upgradeGroup = display.newGroup()

    local cost
    local descriptionText
    local indicatorIndex

    local growthSelection = upgradeSelections[1]
    local timerSelection = upgradeSelections[2]
    local luckSelection = upgradeSelections[3]
    local upgradeSelection

    -- Set branch specfic variables based on the label passed.
    if labelText == "Growth" then
        cost = upgradeCosts[upgradeSelections[1]]
        descriptionText = upgradeDescriptions.growth[upgradeSelections[1]]
        indicatorIndex = growthIndex
        upgradeSelection = growthSelection
        growthSelection = growthSelection + 1
    elseif labelText == "Timer" then
        cost = upgradeCosts[upgradeSelections[2]]
        descriptionText = upgradeDescriptions.timer[upgradeSelections[2]]
        indicatorIndex = timerIndex
        upgradeSelection = timerSelection
        timerSelection = timerSelection + 1
    elseif labelText == "Luck" then
        cost = upgradeCosts[upgradeSelections[3]]
        descriptionText = upgradeDescriptions.luck[upgradeSelections[3]]
        indicatorIndex = luckIndex
        upgradeSelection = luckSelection
        luckSelection = luckSelection + 1
    end

    -- DEBUG
    assert( descriptionText ~= nil, "descriptionText can not be nil." )
    assert( indicatorIndex ~= nil, "indicatorIndex can not be nil." )

    local BOX_WIDTH = W * .7
    local BOX_HEIGHT = H * .2
    local BOX_ALPHA = .50
    local box = display.newRect(x, y, BOX_WIDTH, BOX_HEIGHT )
    box.anchorX = 0
    box.anchorY = .5
    box.alpha = BOX_ALPHA
    box:setFillColor( 0, 0, 0 )

    local LABEL_X_SPACING = W * .01
    local LABEL_SIZE = 20
    local label = display.newText(labelText ,x + LABEL_X_SPACING, y, markerFont, LABEL_SIZE)
    label.anchorX = 0
    label.anchorY = 1

    local DESCRIPTION_X_SPACING = W * .03
    local DESCRIPTION_SIZE = 15
    local description = display.newText(descriptionText, x + LABEL_X_SPACING + DESCRIPTION_X_SPACING, y, markerFont, DESCRIPTION_SIZE)
    description.anchorX = 0
    description.anchorY = 0

    local INDICATOR_X_SPACING = W * .2
    local INDICATOR_Y_SPACING = H * .05
    local indicator = createTripleIndicator(x + INDICATOR_X_SPACING, y - INDICATOR_Y_SPACING, indicatorIndex, upgradeSelection)
    indicator.anchorX = 0
    indicator.anchorY = .5

    local button = display.newImage(sheet, indicatorIndex)
    button.xScale = .125
    button.yScale = button.xScale
    button.x = x + BOX_WIDTH * 1.15
    button.y = y
    button.alpha = .75
    button.cost = cost
    button.growthSelection = growthSelection
    button.timerSelection = timerSelection
    button.luckSelection = luckSelection
    button.starCountText = starCount

    local costLabel
    local star

    if cost ~= nil then
        costLabel = display.newText(tostring(cost) ,button.x + button.x * .01 , button.y - button.y * .03, markerFont, LABEL_SIZE * 1.5)

        star = display.newImage("images/starWhite.png", 0, 0)
        star.anchorX = 1
        star.anchorY = .5
        star.x = costLabel.x - costLabel.x  * .015
        star.y = costLabel.y
        star.xScale = .12
        star.yScale = star.xScale
    else
        button.alpha = 0
    end

    upgradeGroup:insert(box)
    upgradeGroup:insert(indicator)
    upgradeGroup:insert(label)
    upgradeGroup:insert(description)
    upgradeGroup:insert(button)
    if costLabel ~= nil then
        upgradeGroup:insert(costLabel)
        upgradeGroup:insert(star)
    end

    --[[
        An accsessor for the button object so a listener can be added outside this function
    ]]--
    function upgradeGroup.getButton()
        return button
    end

    return upgradeGroup
end

local function createUpgradeGroups(group)
    -- Update text
    starCount.text = saves.stars

    -- Create new groups.
    local upgradeSelections = saves.upgradeSelections

    growthUpgradeGroup = createUpgradeGroup("Growth", upgradeSelections, UPGRADE_GROUP_X, UPGRADE_GROUP_Y)
    timerUpgradeGroup = createUpgradeGroup("Timer", upgradeSelections, UPGRADE_GROUP_X, UPGRADE_GROUP_Y + UPGRADE_GROUP_SPACING)
    luckUpgradeGroup = createUpgradeGroup("Luck", upgradeSelections, UPGRADE_GROUP_X, UPGRADE_GROUP_Y + (2 * UPGRADE_GROUP_SPACING))

    local function purchaseListener(e)
        evolveCntl.onUpgradeTap(e)
        refreshUpgradeGroupsAndStars(group)
    end

    local groups = {growthUpgradeGroup, timerUpgradeGroup, luckUpgradeGroup}

    for i = 1, table.getn(groups) do
        if upgradeSelections[i] ~= 4 then
            local button = groups[i].getButton()
            button.onPurchaseTap = purchaseListener
            button:addEventListener( "tap",  evolveCntl.showEvolveOverlay)
        end
    end
end

function refreshUpgradeGroupsAndStars(group)
    -- Remove old images.
    display.remove( growthUpgradeGroup )
    display.remove( timerUpgradeGroup )
    display.remove( luckUpgradeGroup )
    
    createUpgradeGroups(group)

    -- Add them to the group.
    group:insert( group.numChildren - 1, growthUpgradeGroup)
    group:insert( group.numChildren - 1, timerUpgradeGroup)
    group:insert( group.numChildren - 1, luckUpgradeGroup)
end

--[[
    Removes all applied upgrades and gives the player all spent stars back.
]]--
local function reallocate(group)
    saves.upgradeSelections = {1, 1, 1}
    saves.playerData = evolveCntl.getDefault()
    saves.stars = saves.stars + saves.starsSpent
    saves.starsSpent = 0
    loadsave.saveData(saves)

    refreshUpgradeGroupsAndStars(group)
end

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "scenes.menu"

    warningDialogGroup, yesBtn, noBtn = UI.newWarningDialog("Recycle stars?")

    function closeDialog()
        warningDialogGroup.alpha = 0
        musicAndSound.playSound("pop")
        return true
    end

    function reallocateWrapper()
        reallocate(sceneGroup)
        closeDialog()
        return true
    end

    local background  = display.newImage( "images/loseScreen.png" )
    background.alpha = 1
    background.anchorX = 0
    background.anchorY = 0
    background:setFillColor(1, 1, 1)

    local bottomBar = display.newRect( 0, H, W, .2 * H )
    bottomBar.anchorX = 0
    bottomBar.anchorY = 1
    bottomBar:setFillColor( 0, 0, 0 )

    local homeBtn = UI.newHomeButton("evolve", true)
	
	local star = display.newImage("images/starWhite.png", 0, 0)
	star.alpha = .75
	star.anchorX = .5
    star.anchorY = .5
	star.x = W * .1
	star.y = homeBtn.y
	star.xScale = .2
	star.yScale = star.xScale

	local numberOfStars = saves.stars
	
	starCount = display.newText(numberOfStars,star.x + W * .03,star.y, font, 50)
	starCount:setFillColor(1, 1, 1)
	starCount.alpha = star.alpha
	starCount.anchorX = 0
	starCount.anchorY = star.anchorY

    reallocateBtn = display.newImage( "images/reallocate.png" )
    reallocateBtn.x = ((homeBtn.x - starCount.x) / 3) + starCount.x
    reallocateBtn.y = homeBtn.y
    reallocateBtn.xScale = .20
    reallocateBtn.yScale = reallocateBtn.xScale
    reallocateBtn.alpha = .75
    reallocateBtn.anchorX = .50
	reallocateBtn.anchorY = .50

    inGameStoreBtn = display.newImage("images/starCart.png")
    inGameStoreBtn.x = ((homeBtn.x - starCount.x) * (2/3)) + starCount.x
    inGameStoreBtn.y = homeBtn.y
    inGameStoreBtn.xScale = .18
    inGameStoreBtn.yScale = inGameStoreBtn.xScale
    inGameStoreBtn.alpha = .75
    inGameStoreBtn.anchorX = .50
    inGameStoreBtn.anchorY = .50
    inGameStoreBtn.scene = "scenes.inGameStore"

    inGameStoreBtn:addEventListener( "tap", changeScene )

    createUpgradeGroups(sceneGroup)

    --[[
        This function does only one thing - return true.
        This means that when the player clicks on the background, the dialog box will close unless they
        click the dialogBox itself because it the event will be handled (that's what returning true does)
    ]]
    function blockTouch(e) 
        return true
    end

    function promptDialog(e)
        musicAndSound.playSound("pop")
            
        if warningDialogGroup.alpha == 0 then
            warningDialogGroup.alpha = 1
        else
            warningDialogGroup.alpha = 0
        end
        
        return true
    end
	
	--Listeners
    warningDialogGroup:addEventListener ( "tap", blockTouch )
    yesBtn:addEventListener( "tap", reallocateWrapper )
    noBtn:addEventListener( "tap", closeDialog )
    reallocateBtn:addEventListener( "tap", promptDialog )

    -- Insert to sceneGroup
    sceneGroup:insert( background )
    sceneGroup:insert( bottomBar )
    sceneGroup:insert( homeBtn )
	sceneGroup:insert( star )
	sceneGroup:insert( starCount )
    sceneGroup:insert( reallocateBtn )
    sceneGroup:insert( inGameStoreBtn )

    sceneGroup:insert( growthUpgradeGroup )
    sceneGroup:insert( timerUpgradeGroup )
    sceneGroup:insert( luckUpgradeGroup )
    
    sceneGroup:insert( warningDialogGroup )
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

    -- Remove event listeners.
    -- Not removing this one because there are multiple listeners with the same name, and not sure that I know how to handle that.
    -- button:addEventListener( "tap",  evolveCntl.showEvolveOverlay)

    inGameStoreBtn:removeEventListener( "tap", changeScene )
    warningDialogGroup:removeEventListener ( "tap", blockTouch )
    yesBtn:removeEventListener( "tap", reallocateWrapper )
    noBtn:removeEventListener( "tap", closeDialog )
    reallocateBtn:removeEventListener( "tap", promptDialog )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene