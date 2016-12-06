--[[
	Functions to help with UI like dialog creation.
]]--

local UI = {}

-- Modules
local composer = require "composer"
local fonts = require "modules.fonts"
local imageSheet = require "modules.imageSheet"

--[[
    Returns a button linking to the main menu.
    image - "dark" or "light" to choose the image
    listener - whether or not to add a listener
]]--
function UI.newHomeButton(image, listener)
    assert( image == "light" or image == "dark" or image == "evolve", "image must be 'light' or 'dark' or 'evolve'" )

    local homeBtn
    if image == "light" then
        homeBtn = display.newImage ("images/homeBtn.png", 0, 0 )
            homeBtn.alpha = .50
    elseif image == "dark" then
        homeBtn = display.newImage ("images/homeBtnDark.png",0, 0 )
            homeBtn.alpha = .50
    elseif image == "evolve" then
        homeBtn = display.newImage ("images/homeBtnEvolve.png",0, 0 )
            homeBtn.alpha = .75
    end
    homeBtn.xScale = .65
    homeBtn.yScale = .65
    homeBtn.x = W * .90
    homeBtn.y = H * .90


    if listener == true then
        local goHome = function(e)
            composer.gotoScene("scenes.menu")

            return true
        end

        homeBtn:addEventListener ( "tap", goHome )
    end

    return homeBtn
end

--[[
    Returns a new warning dialog as a display group, and a button to add a listener to.
]]--
function UI.newWarningDialog(warningText)
    local font = fonts.getMarkerFeltBold()
    local fontSize = 22

    local warningDialogGroup = display.newGroup()
    warningDialogGroup.anchorChildren = true 
    warningDialogGroup.anchorX = .5
    warningDialogGroup.anchorY = .5
    warningDialogGroup.x = .5 * W
    warningDialogGroup.y = .5 * H
    warningDialogGroup.alpha = 0

    local background = display.newRect(0, 0, W, H)
    --background.xScale = .7
    --background.yScale = background.xScale     
    background.anchorX = 0
    background.anchorY = 0
    background:setFillColor(0, 0, 0)
        
    local line1Text = display.newText( warningText, 0, 0, font, fontSize )
    line1Text:setFillColor(1, 1, 1)
    line1Text.anchorX = .5
    line1Text.anchorY = .5
    line1Text.x = background.x + background.contentWidth * .5
    line1Text.y = background.y + background.contentHeight * .4

    warningDialogGroup.setText = function(text)
        line1Text.text = text
    end
    
    local yesScale = .25
    local yesBtn = display.newImage("images/check.png")
    yesBtn.xScale = yesScale
    yesBtn.yScale = yesScale
    yesBtn.anchorX = .5
    yesBtn.anchorY = .5
    yesBtn.x = background.contentWidth * .4
    yesBtn.y = background.y + background.contentHeight * .6

 
    local noBtn = display.newImage("images/deny.png")
    noBtn.xScale = yesScale
    noBtn.yScale = yesScale
    noBtn.anchorX = .5
    noBtn.anchorY = .5
    noBtn.x = background.contentWidth * .6
    noBtn.y = yesBtn.y

    warningDialogGroup:insert ( background )
    warningDialogGroup:insert ( line1Text )
    warningDialogGroup:insert( yesBtn )
    warningDialogGroup:insert( noBtn )

    return warningDialogGroup, yesBtn, noBtn
end

--[[
    Returns a pause dialog as a display group.
]]--
function UI.newPauseDialog(x, y)
    local pauseMenu = display.newGroup()
    
    local menuOutline = display.newImage("images/menuOutline.png")
        menuOutline.anchorX = 0
        menuOutline.anchorY = 0
        menuOutline.x = x
        menuOutline.y = y
        menuOutline.xScale = .5
        menuOutline.yScale = menuOutline.xScale
        menuOutline.alpha = .65
        
    local menuXSpace = (menuOutline.contentWidth * .4)
    
    local playBtn = display.newImage("images/smallPlayBtn.png")
        playBtn.anchorX = 0
        playBtn.anchorY = 0
        playBtn.x = menuOutline.x + (menuOutline.contentWidth * .12)
        playBtn.y = menuOutline.y + (menuOutline.contentHeight * .16)
        playBtn.alpha = .50
        playBtn.xScale = .5
        playBtn.yScale = playBtn.xScale
        
    local homeBtn = UI.newHomeButton("dark")
        homeBtn.anchorX = 0
        homeBtn.anchorY = 0
        homeBtn.x =  playBtn.x + menuXSpace
        homeBtn.y = playBtn.y
        homeBtn.xScale = .50
        homeBtn.yScale = homeBtn.xScale
        
    pauseMenu.alpha = 0

    pauseMenu:insert( menuOutline )
    pauseMenu:insert( playBtn )
    pauseMenu:insert( homeBtn )

    return pauseMenu, playBtn, homeBtn
end

--[[
    Creates a new swatch group with a default score, sequence, and streak of 0.
]]--
function UI.newSwatchGroup()
    local swatchGroup = display.newGroup()

    local swatchSheet = imageSheet.swatchSheet

    local font = fonts.getSystemFont()
    local fontSize = 20

    local SCORE_ANCHOR_X = 0
    local SCORE_ANCHOR_Y = 0.5
    local SCORE_ALPHA = .65
    local SWATCH_INDENT = (W*.025)
    
    local INITIAL_SCORE = 0 
    local scoreText = display.newText(INITIAL_SCORE,.825 * W ,.075    * H, font, fontSize)
        scoreText:setFillColor(0,0,0)
        scoreText.anchorX = SCORE_ANCHOR_X
        scoreText.anchorY = SCORE_ANCHOR_Y
        scoreText.alpha = SCORE_ALPHA
        
    local scoreSwatch = display.newImage(swatchSheet, 1)
        scoreSwatch.xScale = .60
        scoreSwatch.yScale = scoreSwatch.xScale
        scoreSwatch.x = scoreText.x - (2.5* scoreText.width)
        scoreSwatch.y = scoreText.y
        scoreSwatch.alpha = .50
        scoreSwatch.anchorX = SCORE_ANCHOR_X
        scoreSwatch.anchorY = SCORE_ANCHOR_Y
    
    local INITIAL_SEQUENCE = 1
    local sequenceNumberText = display.newText(INITIAL_SEQUENCE, scoreText.x + SWATCH_INDENT, (scoreText.y + .115*H), font, fontSize)
        sequenceNumberText:setFillColor(0,0,0)
        sequenceNumberText.anchorX = SCORE_ANCHOR_X
        sequenceNumberText.anchorY = SCORE_ANCHOR_Y
        sequenceNumberText.alpha = SCORE_ALPHA

    local function createSeqSwatch(earnedAStar)
        local seqSwatch
        if earnedAStar == false then
            seqSwatch = display.newImage(swatchSheet, 2)
        elseif earnedAStar == true then
            seqSwatch = display.newImage(swatchSheet, 4)
        end

        seqSwatch.xScale = .60
        seqSwatch.yScale = scoreSwatch.xScale
        seqSwatch.x = (scoreSwatch.x  + SWATCH_INDENT)
        seqSwatch.y = sequenceNumberText.y
        seqSwatch.alpha = .50
        seqSwatch.anchorX = SCORE_ANCHOR_X
        seqSwatch.anchorY = SCORE_ANCHOR_Y

        return seqSwatch
    end

    local seqSwatch = createSeqSwatch(false)

    local INITIAL_STREAK = 0
    local streakText = display.newText(INITIAL_STREAK, scoreText.x + (2*SWATCH_INDENT) ,(sequenceNumberText.y + .115*H), font, fontSize)
    streakText:setFillColor(0,0,0)
    streakText.anchorX = SCORE_ANCHOR_X
    streakText.anchorY = SCORE_ANCHOR_Y
    streakText.alpha = SCORE_ALPHA

    local function createStreakSwatch(newHighStreak)
        local streakSwatch
        if newHighStreak == false then
            streakSwatch = display.newImage(swatchSheet, 3)
        elseif newHighStreak == true then
            streakSwatch = display.newImage(swatchSheet, 5)
        end

        streakSwatch.xScale = .60
        streakSwatch.yScale = scoreSwatch.xScale
        streakSwatch.x = seqSwatch.x + SWATCH_INDENT
        streakSwatch.y = streakText.y
        streakSwatch.alpha = .50
        streakSwatch.anchorX = SCORE_ANCHOR_X
        streakSwatch.anchorY = SCORE_ANCHOR_Y

        return streakSwatch
    end

    local streakSwatch = createStreakSwatch(false)

    -- Insert into swatchGroup
    swatchGroup:insert( scoreSwatch )
    swatchGroup:insert( scoreText )
    swatchGroup:insert( seqSwatch )
    swatchGroup:insert( sequenceNumberText )
    swatchGroup:insert( streakSwatch )
    swatchGroup:insert( streakText )

    swatchGroup.update = function(score, sequence, streak, showScore, showSequence, showStreak, newHighStreak, earnedAStar)
        scoreText.text = score
        sequenceNumberText.text = sequence
        streakText.text = streak

        -- Set everything visible to start...
        scoreText.alpha = 1
        scoreSwatch.alpha = 1
        sequenceNumberText.alpha = 1
        seqSwatch.alpha = 1
        streakText.alpha = 1
        streakSwatch.alpha = 1

        -- Update the sequence swatch.
        display.remove(seqSwatch)
        seqSwatch = createSeqSwatch(earnedAStar)
        swatchGroup:insert( 3, seqSwatch )

        -- Update the sreak swatch.
        display.remove(streakSwatch)
        streakSwatch = createStreakSwatch(newHighStreak)
        swatchGroup:insert( 5, streakSwatch )
        
        -- ...hide by request.
        if showScore == false then
            scoreText.alpha = 0
            scoreSwatch.alpha = 0
        end
        
        if showSequence == false then
            sequenceNumberText.alpha = 0
            seqSwatch.alpha = 0
        end

        if showStreak == false then
            streakText.alpha = 0
            streakSwatch.alpha = 0
        end
    end

    -- Set the swatch group off screen and invisible to start.
    swatchGroup.alpha = 0
    swatchGroup.x = swatchGroup.contentWidth -- starts at 0

    return swatchGroup
end

--[[
    Put the evolve text over the labels.
]]--
function UI.newEvolveTabText(growthTab, timerTab, luckTab)
    local group = display.newGroup()

    local font = fonts.getMarkerFeltBold()
    local fontSize = 22
    local fontDarkener = 5
    
    local growthText = display.newText( "GROWTH", growthTab.x + growthTab.contentWidth / 3, growthTab.y + growthTab.contentHeight/3, font, fontSize )
    growthText:setTextColor (.145/fontDarkener,.031/fontDarkener,.031/fontDarkener)
    local timerText = display.newText( "TIMER", timerTab.x + timerTab.contentWidth / 3, timerTab.y + timerTab.contentHeight/3, font, fontSize )
    timerText:setTextColor (.012/fontDarkener,.027/fontDarkener,.090/fontDarkener)
    local luckText = display.newText( "LUCK", luckTab.x + luckTab.contentWidth / 3, luckTab.y + luckTab.contentHeight/3, font, fontSize )
    luckText:setTextColor (.192/fontDarkener,.157/fontDarkener,.024/fontDarkener)
    
    group:insert( growthText )
    group:insert( timerText )
    group:insert( luckText )

    return group
end

return UI