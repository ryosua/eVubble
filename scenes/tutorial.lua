-- Modules
local composer = require "composer"
local fonts = require "modules.fonts"
local dynamicBackground = require "modules.dynamicBackground"
local musicAndSound = require "modules.musicAndSound"
local imageSheet = require "modules.imageSheet"
local memoryManagement = require "modules.memoryManagement"

local nextBtn
local changeSlide

local scene = composer.newScene()
local function switchScene()
    composer.gotoScene("scenes.level1")
    
    return true
end

--Timer Memory Management
local transitionStash = {}

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "scenes.menu"

    local font = fonts.getMarkerFeltBold()
    local fontSize = 20

    local blackGround = display.newImage( "images/background.png", 0, 0 )
    blackGround.anchorX = 0
    blackGround.anchorY = 0
    
    local hints =
    {
        "Pop bubbles to increase score",
        "The color queue shows which bubbles are next in the sequence",
        "Pop from left to right in the color queue",
        "Pop an entire sequence without a mistake to get a streak",
        "Clear unbeaten sequences to collect stars",
        "Explore the glowing powerup bubbles",
        "Timer Extension",
        "Reduces player size",
        "Counts for any color",
        "Pops 4 bubbles",
        "Slows bubbles down",
        "Score multiplier",
        "Bubble pops + streak bonus + time bonus = score",
        "...And you're almost out of time"
    }

    --[[
    Gets the player image file from the saved frame table.
    ]]--
    local function getPlayerImage(frame)
        local file = frame[1]
        local index = frame[2]

        if (file == "playerGrid_1") then
            return display.newImage( imageSheet.playerGrid_1, index )

        elseif (file == "playerGrid_2") then
            return display.newImage( imageSheet.playerGrid_2, index )
        end
    end

    nextBtn = display.newImage("images/nextBtn.png")
    nextBtn.xScale = .5
    nextBtn.yScale = nextBtn.xScale
    nextBtn.x = .5 * W
    nextBtn.y = .8 * H
    nextBtn.alpha = .3
    
    local player = getPlayerImage(saves.playerData.frame)
    player.xScale = .25
    player.yScale = player.xScale
    player.x = W *.35
    player.y = H *.45
    
    local blueEnemy = display.newImage(imageSheet.enemyImageSheet, 1)
    blueEnemy.xScale = .10
    blueEnemy.yScale = blueEnemy.xScale
    blueEnemy.x = W *.75
    blueEnemy.y = H *.65
    
    local blueEnemy2 = display.newImage(imageSheet.enemyImageSheet, 1)
    blueEnemy2.xScale = .09
    blueEnemy2.yScale = blueEnemy2.xScale
    blueEnemy2.x = W *.65
    blueEnemy2.y = H *.90
    blueEnemy2.alpha = 0
    
    local redEnemy = display.newImage(imageSheet.enemyImageSheet, 2)
    redEnemy.xScale = .115
    redEnemy.yScale = redEnemy.xScale
    redEnemy.x = W *.75
    redEnemy.y = H *.65
    redEnemy.alpha = 0
    
    local greenEnemy = display.newImage(imageSheet.enemyImageSheet, 3)
    greenEnemy.xScale = .105
    greenEnemy.yScale = greenEnemy.xScale
    greenEnemy.x = W *.675
    greenEnemy.y = H *.725
    greenEnemy.alpha = 0
    
    local swatchSheet = imageSheet.swatchSheet
    
    local queueSheet = require "modules.queueImageSheet"

    local font = fonts.getSystemFont()
    local fontSize = 20

    local SCORE_ANCHOR_X = 0
    local SCORE_ANCHOR_Y = 0.5
    local SCORE_ALPHA = .65
    local SWATCH_INDENT = (W*.025)
    
    local scoreText = display.newText(1,.825 * W ,.075    * H, font, fontSize)
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
       
    local sequenceNumberText = display.newText(2, scoreText.x + SWATCH_INDENT, (scoreText.y + .115*H), font, fontSize)
    sequenceNumberText:setFillColor(0,0,0)
    sequenceNumberText.anchorX = SCORE_ANCHOR_X
    sequenceNumberText.anchorY = SCORE_ANCHOR_Y
    sequenceNumberText.alpha = 0
        
    local sequenceNumberText2 = display.newText(4, scoreText.x + SWATCH_INDENT, (scoreText.y + .115*H), font, fontSize)
    sequenceNumberText2:setFillColor(0,0,0)
    sequenceNumberText2.anchorX = SCORE_ANCHOR_X
    sequenceNumberText2.anchorY = SCORE_ANCHOR_Y
    sequenceNumberText2.alpha = 0
        
    local seqSwatch
    seqSwatch = display.newImage(swatchSheet, 2)
    seqSwatch.xScale = .60
    seqSwatch.yScale = scoreSwatch.xScale
    seqSwatch.x = (scoreSwatch.x  + SWATCH_INDENT)
    seqSwatch.y = sequenceNumberText.y
    seqSwatch.alpha = 0
    seqSwatch.anchorX = SCORE_ANCHOR_X
    seqSwatch.anchorY = SCORE_ANCHOR_Y
        
    local seqSwatch2
    seqSwatch2 = display.newImage(swatchSheet, 4)
    seqSwatch2.xScale = .60
    seqSwatch2.yScale = scoreSwatch.xScale
    seqSwatch2.x = (scoreSwatch.x  + SWATCH_INDENT)
    seqSwatch2.y = sequenceNumberText.y
    seqSwatch2.alpha = 0
    seqSwatch2.anchorX = SCORE_ANCHOR_X
    seqSwatch2.anchorY = SCORE_ANCHOR_Y
        
    local streakText = display.newText(3, scoreText.x + (2*SWATCH_INDENT) ,(sequenceNumberText.y + .115*H), font, fontSize)
    streakText:setFillColor(0,0,0)
    streakText.anchorX = SCORE_ANCHOR_X
    streakText.anchorY = SCORE_ANCHOR_Y
    streakText.alpha = 0

    local streakSwatch = display.newImage(swatchSheet, 5)
    streakSwatch.xScale = .60
    streakSwatch.yScale = scoreSwatch.xScale
    streakSwatch.x = streakText.x - (2.5* streakText.width)
    streakSwatch.y = streakText.y
    streakSwatch.alpha = 0
    streakSwatch.anchorX = SCORE_ANCHOR_X
    streakSwatch.anchorY = SCORE_ANCHOR_Y
    
    local bluePU = display.newImage(imageSheet.powerupImageSheet,1)
    bluePU.xScale = .10
    bluePU.yScale = .10
    bluePU.x = W*.11
    bluePU.y = H*.83
    bluePU.alpha = 0
    
    local redPU = display.newImage(imageSheet.powerupImageSheet,2)
    redPU.xScale = .11
    redPU.yScale = .11
    redPU.x = W*.75
    redPU.y = H*.96
    redPU.alpha = 0
    
    local multiPU = display.newImage(imageSheet.enemyImageSheet,7)
    multiPU.xScale = .105
    multiPU.yScale = .105
    multiPU.x = W*.36
    multiPU.y = H*.65
    multiPU.alpha = 0
    
    local yellowPU = display.newImage(imageSheet.powerupImageSheet,5)
    yellowPU.xScale = .12
    yellowPU.yScale = .12
    yellowPU.x = W*.62
    yellowPU.y = H*.28
    yellowPU.alpha = 0
    
    local orangePU = display.newImage(imageSheet.powerupImageSheet,4)
    orangePU.xScale = .115
    orangePU.yScale = .115
    orangePU.x = W*.92
    orangePU.y = H*.77
    orangePU.alpha = 0
    
    local purplePU = display.newImage(imageSheet.powerupImageSheet,6)
    purplePU.xScale = .11
    purplePU.yScale = .11
    purplePU.x = W*.29
    purplePU.y = H*.15
    purplePU.alpha = 0

    local PADDING = 50
    local FADE_FACTOR = .26
    local QUEUE_SCALE = .08
    local QUEUE_SCALE_FIRST = .0975
    
    local blueQueue = display.newImage(queueSheet, 1)
    blueQueue.xScale = QUEUE_SCALE_FIRST
    blueQueue.yScale = QUEUE_SCALE_FIRST
    blueQueue.x = (PADDING * 1)
    blueQueue.y = H - PADDING
    blueQueue.alpha = 0
    
    local blueQueue2 = display.newImage(queueSheet, 1)
    blueQueue2.xScale = QUEUE_SCALE
    blueQueue2.yScale = QUEUE_SCALE
    blueQueue2.x = (PADDING * 3)
    blueQueue2.y = H - PADDING
    blueQueue2.alpha = 0
    
    local redQueue = display.newImage(queueSheet, 2)
    redQueue.xScale = QUEUE_SCALE
    redQueue.yScale = QUEUE_SCALE
    redQueue.x = (PADDING * 2)
    redQueue.y = H - PADDING
    redQueue.alpha = 0
    
    local greenQueue = display.newImage(queueSheet, 3)
    greenQueue.xScale = QUEUE_SCALE
    greenQueue.yScale = QUEUE_SCALE
    greenQueue.x = (PADDING * 2)
    greenQueue.y = H - PADDING
    greenQueue.alpha = 0

    local timeText = display.newText(4, .95 * W ,.975 * H, fonts.getSystemFontBold(), 150)
    timeText:setFillColor(0,0,0)
    timeText.anchorX = 1
    timeText.anchorY = 1
    timeText.alpha = 0

    local hintTextOptions = 
    {
        text = hints[1],     
        x = W * .5,
        y = H * .15,
        width = .5 * W,
        font = font,   
        fontSize = fontSize,
        align = "center"
    }

    local hintText = display.newText(hintTextOptions)
    hintText.anchorX = .5
    hintText.alpha = .75
    hintText:setFillColor( 0, 0, 0 )
    
    local function emphasizeQueue()
        transitionStash[#transitionStash + 1] = transition.to( blueQueue, { time=250, xScale = .15, yScale = .15, delay = 750} )
        transitionStash[#transitionStash + 1] = transition.to( blueQueue, { time=250, xScale = .10, yScale = .10, delay = 1000} )
        transitionStash[#transitionStash + 1] = transition.to( redQueue, { time=250, xScale = .13, yScale = .13, delay = 1250} )
        transitionStash[#transitionStash + 1] = transition.to( redQueue, { time=250, xScale = .08, yScale = .08, delay = 1500} )
    end
    
    local step = 0
    function changeSlide(e)
        
        step = step + 1
        if step ~= 14 then -- Don't play the sound on the last step.
            musicAndSound.playSound("pop")
        end
    
        if step == 1 then
            player.x = W *.80
            player.y = H *.50
            blueEnemy.alpha = 1
            blueEnemy.x = W *.20
            blueEnemy.y = H *.175
            redEnemy.alpha = 1
            redEnemy.x = W *.70
            redEnemy.y = H *.85
            scoreSwatch.alpha = 0
            scoreText.alpha = 0
            seqSwatch.alpha = .50
            sequenceNumberText.alpha = SCORE_ALPHA
            blueQueue.alpha = 1
            redQueue.alpha = 1.25 - (2 * FADE_FACTOR)
        end
        if step == 2 then
            seqSwatch.alpha = .20
            sequenceNumberText.alpha = .20
            player.alpha = .20
            blueEnemy.alpha = .20
            redEnemy.alpha = .20
            emphasizeQueue()
        end
        if step == 3 then
            player.alpha = 1
            player.x = W *.35
            player.y = H *.75
            blueEnemy.alpha = 1
            blueEnemy.x = W *.025
            blueEnemy.y = H *.65
            redEnemy.alpha = 1
            redEnemy.x = W *.90
            redEnemy.y = H *.20
            blueEnemy2.alpha = 1
            streakSwatch.alpha = .50
            seqSwatch.alpha = 0
            streakText.alpha = SCORE_ALPHA
            blueQueue2.alpha = 1.25 - (3 * FADE_FACTOR)
            sequenceNumberText.alpha = 0
        end
        if step == 4 then
            streakSwatch.alpha = 0
            streakText.alpha = 0
            player.x = W *.20
            player.y = H *.40
            greenEnemy.alpha = 1
            blueEnemy.x = W *.075
            blueEnemy.y = H *.75
            blueEnemy2.x = W *.50
            blueEnemy2.y = H *.4
            redEnemy.x = W *.55
            redEnemy.y = H *.02
            greenQueue.alpha = 1.25 - (2 * FADE_FACTOR)
            redQueue.alpha = 1.25 - (3 * FADE_FACTOR)
            redQueue.x = (PADDING * 3)
            blueQueue2.x = (PADDING * 4)
            blueQueue2.alpha = 1.25 - (4 * FADE_FACTOR)
            seqSwatch2.alpha = .50
            sequenceNumberText2.alpha = .50
        end
        if step == 5 then
            player.alpha = 0
            blueQueue.alpha = 0
            blueQueue2.alpha = 0
            redQueue.alpha = 0
            greenQueue.alpha = 0
            blueEnemy.alpha = 0
            blueEnemy2.alpha = 0
            redEnemy.alpha = 0
            greenEnemy.alpha = 0
            streakSwatch.alpha = 0
            seqSwatch.alpha = 0
            streakText.alpha = 0
            sequenceNumberText.alpha = 0
            seqSwatch2.alpha = 0
            sequenceNumberText2.alpha = 0
            bluePU.alpha = 1
            redPU.alpha = 1
            multiPU.alpha = 1
            orangePU.alpha = 1
            yellowPU.alpha = 1
            purplePU.alpha = 1
        end
        if step == 6 then
            bluePU.alpha = 1
            redPU.alpha = .25
            multiPU.alpha = .25
            orangePU.alpha = .25
            yellowPU.alpha = .25
            purplePU.alpha = .25
        end
        if step == 7 then
            bluePU.alpha = .25
            redPU.alpha = 1
            multiPU.alpha = .25
            orangePU.alpha = .25
            yellowPU.alpha = .25
            purplePU.alpha = .25
        end
        if step == 8 then
            bluePU.alpha = .25
            redPU.alpha = .25
            multiPU.alpha = 1
            orangePU.alpha = .25
            yellowPU.alpha = .25
            purplePU.alpha = .25
        end
        if step == 9 then
            bluePU.alpha = .25
            redPU.alpha = .25
            multiPU.alpha = .25
            orangePU.alpha = 1
            yellowPU.alpha = .25
            purplePU.alpha = .25
        end
        if step == 10 then
            bluePU.alpha = .25
            redPU.alpha = .25
            multiPU.alpha = .25
            orangePU.alpha = .25
            yellowPU.alpha = 1
            purplePU.alpha = .25
        end
        if step == 11 then
            bluePU.alpha = .25
            redPU.alpha = .25
            multiPU.alpha = .25
            orangePU.alpha = .25
            yellowPU.alpha = .25
            purplePU.alpha = 1
        end
        if step == 12 then
            bluePU.alpha = 0
            redPU.alpha = 0
            multiPU.alpha = 0
            orangePU.alpha = 0
            yellowPU.alpha = 0
            purplePU.alpha = 0
        end
        if step == 13 then
            timeText.alpha = .25
            player.alpha = 1
        end
        if step == 14 then
            switchScene()
        end

        -- Update hint text
        hintText.text = hints[step + 1]
        
        return true
    end
         
    -- Create the dynamic background
    local dynamicBackroundLayer = dynamicBackground.newDynamicBackroundLayer()
    dynamicBackroundLayer.alpha = .625
    
    runtimeFunction = function( event )
        dynamicBackground.move(dynamicBackroundLayer) -- animate the background
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )
    nextBtn:addEventListener( "tap", changeSlide )
    
    sceneGroup:insert( blackGround )
    sceneGroup:insert( dynamicBackroundLayer )
    sceneGroup:insert( player )
    sceneGroup:insert( blueEnemy )
    sceneGroup:insert( blueEnemy2 )
    sceneGroup:insert( redEnemy )
    sceneGroup:insert( greenEnemy )
    sceneGroup:insert( bluePU )
    sceneGroup:insert( redPU )
    sceneGroup:insert( multiPU )
    sceneGroup:insert( orangePU )
    sceneGroup:insert( yellowPU )
    sceneGroup:insert( purplePU )
    sceneGroup:insert( scoreSwatch )
    sceneGroup:insert( seqSwatch )
    sceneGroup:insert( seqSwatch2 )
    sceneGroup:insert( streakSwatch )
    sceneGroup:insert( streakText )
    sceneGroup:insert( scoreText )
    sceneGroup:insert( sequenceNumberText )
    sceneGroup:insert( sequenceNumberText2 )
    sceneGroup:insert( blueQueue )
    sceneGroup:insert( blueQueue2 )
    sceneGroup:insert( redQueue )
    sceneGroup:insert( greenQueue )
    sceneGroup:insert( timeText )
    sceneGroup:insert( nextBtn )
    --hintText on top layer
    sceneGroup:insert( hintText )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
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
    nextBtn:removeEventListener( "tap", changeSlide )
    
    memoryManagement.cancelAllTransitions(transitionStash)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene