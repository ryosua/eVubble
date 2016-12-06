-- Modules
local composer = require "composer"
local dynamicBackground = require "modules.dynamicBackground"
local evubbleGameNetwork = require "modules.evubbleGameNetwork"
local fonts = require "modules.fonts"
local hints = require "modules.hints"
local memoryManagement = require "modules.memoryManagement"
local musicAndSound = require "modules.musicAndSound"
local platform = require "modules.platform"
local ratingPrompt = require "modules.ratingPrompt"
local UI = require "modules.UI"

local font = fonts.getSystemFont()
local fontSize = 100

-- Memory management
local timers = {}
local transitions = {}
local transitionsFromLevel1
local pulseTransition

local highscoreimg
local LC_starSwatch
local LC_streakSwatch
local levelHighStreak
local newStarsThisLevel
local notification
local onPlusTap
local playAgainBtn
local plus1
local runtimeFunction
local scoreDisplay
local starCount

local function switchScene(e)
    composer.gotoScene( e.target.scene )

    return true
end

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    local bleedGroup = event.params.bleedGroup
    transitionsFromLevel1 = event.params.transitions
    
    composer.state.returnTo = nil

    -- Count the number of plays
    saves.numberOfPlays = saves.numberOfPlays + 1
    loadsave.saveData(saves)
    

    --Updates the high scores, and returns true if a notification should be played.
    notification = composer.state.highScoreNotification

    newStarsThisLevel = composer.state.newStarsThisLevel
    levelHighStreak = composer.state.levelHighStreak
    
    -- Highscore Swatch
    if notification == true then        
        highscoreimg = display.newImage("images/highscore.png", 0, 0 )
        highscoreimg.anchorX = 1
        highscoreimg.anchorY = .5
        
        highscoreimg.x = 0 - (highscoreimg.contentWidth)
        highscoreimg.y = (H *.25) 
        
        highscoreimg.xScale = .5
        highscoreimg.yScale = highscoreimg.xScale 
        highscoreimg.alpha = .90
    end

    -- Star Swatch
    if (newStarsThisLevel > 0) then
        LC_starSwatch = display.newImage("images/LC_starSwatch.png", 0, 0 )
        LC_starSwatch.anchorX = 1
        LC_starSwatch.anchorY = .5
        LC_starSwatch.x = 0 - (LC_starSwatch.contentWidth)
        LC_starSwatch.y = (H *.50) 
        LC_starSwatch.xScale = .5
        LC_starSwatch.yScale = LC_starSwatch.xScale 
        LC_starSwatch.alpha = .90
        
        starCount = display.newText( (composer.state.newStarsThisLevel), LC_starSwatch.x, LC_starSwatch.y, font, fontSize/1.25 )
        starCount:setFillColor(0, 0, 0)
        starCount.anchorX = 0.5
        starCount.anchorY = 0.5
        starCount.alpha = .75
        starCount.x = LC_starSwatch.x
        starCount.y = LC_starSwatch.y
        
        starBlack = display.newImage("images/starBlack.png", 0, 0 )
        starBlack.anchorX = .5
        starBlack.anchorY = .5
        starBlack.x = 0 - (LC_starSwatch.contentWidth)
        starBlack.y = (H *.50) 
        starBlack.xScale = .25
        starBlack.yScale = starBlack.xScale
        starBlack.alpha = starCount.alpha 
    end
    
    -- streakSwatch
    if levelHighStreak > saves.allTimeHighStreak then 
        saves.allTimeHighStreak = levelHighStreak
        -- Save data.
        loadsave.saveData(saves)
        
        LC_streakSwatch = display.newImage("images/LC_streakSwatch.png", 0, 0 )
        LC_streakSwatch.anchorX = 1
        LC_streakSwatch.anchorY = .5
        LC_streakSwatch.x = 0 - (LC_streakSwatch.contentWidth)
        LC_streakSwatch.y = (H *.75) 
        LC_streakSwatch.xScale = .5
        LC_streakSwatch.yScale = LC_streakSwatch.xScale 
        LC_streakSwatch.alpha = .90
        
        streakCount = display.newText( (levelHighStreak), LC_streakSwatch.x, LC_streakSwatch.y, font, fontSize/1.25 )
        streakCount:setFillColor(0, 0, 0)
        streakCount.anchorX = 0.5
        streakCount.anchorY = 0.5
        streakCount.alpha = .75
        streakCount.x = LC_streakSwatch.x
        streakCount.y = LC_streakSwatch.y
        
        streakBlack = display.newImage("images/streakBlack.png", 0, 0 )
        streakBlack.anchorX = .5
        streakBlack.anchorY = .5
        streakBlack.x = 0 - (LC_streakSwatch.contentWidth)
        streakBlack.y = LC_streakSwatch.y
        streakBlack.xScale = .25
        streakBlack.yScale = streakBlack.xScale
        streakBlack.alpha = streakCount.alpha 
    end
 
    local background = display.newImage("images/fade.png", 0, 0 )
    background.x = W * .50
    background.y = H * .50
    background.alpha = .50
    
    local homeBtn = UI.newHomeButton("light", true)
    
    local sheetOptions =
    {
        -- required parameters
        width = 350,
        height = 350,
        numFrames = 6,

        -- optional parameters; used for dynamic resolution support
        sheetContentWidth = 1050,  -- width of original 1x size of entire sheet
        sheetContentHeight = 700   -- height of original 1x size of entire sheets
    }
    local imageSheet = graphics.newImageSheet( "images/menuBtn6Sheet.png", sheetOptions )

    if saves.forcedThemToEvolve == false and saves.stars >= 3 then
        playAgainBtn = display.newImage(imageSheet, 6)
        playAgainBtn.scene = "scenes.evolve"
        homeBtn.alpha = 0
        saves.forcedThemToEvolve = true
        loadsave.saveData(saves)
    else
        playAgainBtn = display.newImage(imageSheet, 5)
        playAgainBtn.scene = "scenes.level1"
    end
        
    playAgainBtn.xScale = .25
    playAgainBtn.yScale = playAgainBtn.xScale
    playAgainBtn.x = W * .50 
    playAgainBtn.y = H * .70

    plus1 = ratingPrompt.newRatingPromptButton(timers)
    if plus1 ~= nil then
        pulseTransition = transition.blink( plus1, { time = 2000 } )
    end

    function onPlusTap()
        if plus1 ~= nil then
            memoryManagement.cancelTransition(pulseTransition)
            plus1.alpha = 0
            ratingPrompt.promptForRating()
        end

        return true
    end

    if plus1 ~= nil then
        plus1:addEventListener( "tap", onPlusTap )
    end

    local score = 0
        
    scoreDisplay = display.newText(score, (W *.50), H * .4, font, fontSize )
    scoreDisplay:setFillColor(1, 1, 1)
    scoreDisplay.anchorX = 0.5
    scoreDisplay.anchorY = 0.5
    scoreDisplay.x = playAgainBtn.x
    scoreDisplay.y = H * .3
    
    local highscore = saves.highscore
        
    local highscoreDisplay = display.newText( highscore, (W *.50), (H * .33), font, fontSize/5 )
    highscoreDisplay:setFillColor(1, 1, 1)
    highscoreDisplay.anchorX = 0.5
    highscoreDisplay.anchorY = .5
    highscoreDisplay.alpha = .50
    highscoreDisplay.x = playAgainBtn.x
    highscoreDisplay.y = (scoreDisplay.y + (scoreDisplay.contentHeight/2))

    local hintText

    if saves.showHints == true then
        local markerFont = fonts.getMarkerFeltBold()
        local markerFontSize = 16

        local options = 
        {
            text = hints.getRandomHint(),     
            x = W * .5,
            y =  H * .9,
            width = .6 * W,
            font = markerFont,   
            fontSize = markerFontSize,
            align = "center"
        }

        hintText = display.newText( options )
        hintText.alpha = .50
    end

    -- Create the dynamic background
    local dynamicBackroundLayer = dynamicBackground.newDynamicBackroundLayer()
    
    runtimeFunction = function( event )
        dynamicBackground.move(dynamicBackroundLayer) -- animate the background
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )

    playAgainBtn:addEventListener( "tap", switchScene ) 

    sceneGroup:insert( dynamicBackroundLayer )
    sceneGroup:insert( background )
    sceneGroup:insert( homeBtn )
    sceneGroup:insert( playAgainBtn )
    if plus1 ~= nil then
        sceneGroup:insert( plus1 )
    end
    if adButton ~= nil then
        sceneGroup:insert(adButton)
    end
    sceneGroup:insert( scoreDisplay )
    sceneGroup:insert( highscoreDisplay )
    if saves.showHints == true then
        sceneGroup:insert( hintText )
    end

    local hintButton = hints.newHintButton(sceneGroup)
    sceneGroup:insert( hintButton )

    -- Only insert if there is a notification.
    if highscoreimg ~= nil then 
        sceneGroup:insert(highscoreimg)
    end
    if (LC_starSwatch ~= nil) then
        sceneGroup:insert( LC_starSwatch )
        sceneGroup:insert( starCount )
        sceneGroup:insert( starBlack )
    end
    if LC_streakSwatch ~= nil then 
        sceneGroup:insert( LC_streakSwatch )
        sceneGroup:insert( streakCount )
        sceneGroup:insert( streakBlack )
    end
    sceneGroup:insert(bleedGroup)

    local adControllerI = composer.state.singletonsI.getAdControllerI()
    local platformI = composer.state.singletonsI.getPlatformI()

    local adButton
    if platformI.getPlatform() ~= platform.MAC_OS_X then 
        adButton = adControllerI.loadAdButton(sceneGroup, transitions)
    end
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Load and display highscore.
        scoreDisplay.text = composer.state.score
    elseif ( phase == "did" ) then
        local notification = composer.state.highScoreNotification

        if notification == true then
            -- Set the highscore flag back to false.
            composer.state.highScoreNotification = false
        end

        -- Update highscore and leaderboards if logged in.
        if evubbleGameNetwork.loggedIntoGameNetwork == true then
            evubbleGameNetwork.updateLeaderboards(saves.highscore, saves.allTimeHighStreak)
            evubbleGameNetwork.updateLocalStreakAcievement()
            evubbleGameNetwork.submitUnlockAchievements()
        end

        -- Level1 creates a lot of garbage, and what better place to clean it than here?
        collectgarbage()

        -- Start all animations.
        if notification == true then
            transitions[#transitions + 1] = transition.to( highscoreimg, 
            { x = (highscoreimg.contentWidth), time = 500, onComplete = finishAnimation} )
             
            transitions[#transitions + 1] = transition.to( highscoreimg,
            { time = 500, x = 0 - (highscoreimg.contentWidth) , delay = 3000 } ) 
        end

        if (newStarsThisLevel > 0) then
            -- starSwatch
            transitions[#transitions + 1] = transition.to( LC_starSwatch, 
            { x = (LC_starSwatch.contentWidth) - (LC_starSwatch.contentWidth * .20) , time = 500, onComplete = finishAnimation} )
            transitions.moveAcrossScreen4 = transition.to( LC_starSwatch,
            { time = 500, x = 0 - (LC_starSwatch.contentWidth) , delay = 3250 } )
            
            -- starCount text
            transitions[#transitions + 1] = transition.to( starCount, 
            { x =( 0 + starCount.contentWidth + starBlack.contentWidth), time = 500, onComplete = finishAnimation} )
            transitions.moveAcrossScreen6 = transition.to( starCount,
            { time = 500, x = 0 - (LC_starSwatch.contentWidth)  , delay = 3250 } )
            
            -- starIcon
            transitions[#transitions + 1] = transition.to( starBlack, 
            { x =(starBlack.contentWidth *.75), time = 500, onComplete = finishAnimation} )
            transitions[#transitions + 1] = transition.to( starBlack,
            { time = 500, x = 0 - (LC_starSwatch.contentWidth)  , delay = 3250 } )
        end

        if levelHighStreak > saves.allTimeHighStreak then
            -- streakSwatch
            transitions[#transitions + 1] = transition.to( LC_streakSwatch, 
            { x = (LC_streakSwatch.contentWidth) - (LC_starSwatch.contentWidth * .40) , time = 500, onComplete = finishAnimation} )
            transitions[#transitions + 1] = transition.to( LC_streakSwatch,
            { time = 500, x = 0 - (LC_streakSwatch.contentWidth) , delay = 3500 } )
            
            -- streakCount text
            transitions[#transitions + 1] = transition.to( streakCount, 
            { x =( 0 + streakCount.contentWidth + streakBlack.contentWidth), time = 500, onComplete = finishAnimation} )
            transitions[#transitions + 1] = transition.to( streakCount,
            { time = 500, x = 0 - (LC_streakSwatch.contentWidth)  , delay = 3500 } )
            
            -- streakIcon
            transitions[#transitions + 1]= transition.to( streakBlack, 
            { x =(streakBlack.contentWidth * .75), time = 500, onComplete = finishAnimation} )
            transitions[#transitions + 1] = transition.to( streakBlack,
            { time = 500, x = 0 - (LC_starSwatch.contentWidth)  , delay = 3500 } )
        end

        -- Play all sounds.
        if notification == true then 
            musicAndSound.playSound("highscoreSound")
        else
            musicAndSound.playSound("loseSound")
        end

        if (newStarsThisLevel > 0) then
            local function playStarSound()
                musicAndSound.playSound("starSound")
            end
            timers[#timers + 1] = timer.performWithDelay( 1500, playStarSound)
        end
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        memoryManagement.cancelAllTimers(timers)     
        memoryManagement.cancelAllTransitions(transitions)
        memoryManagement.cancelAllTransitions(transitionsFromLevel1)

    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    Runtime:removeEventListener("enterFrame", runtimeFunction)
    runtimeFunction = nil

    -- Remove event listeners.
    if plus1 ~= nil then
        plus1:removeEventListener( "tap", onPlusTap )
    end
    playAgainBtn:removeEventListener( "tap", switchScene )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene