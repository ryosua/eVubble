-- Modules
local bouncyWalls = require "modules.bouncyWalls"
local bubbleCntl = require "modules.bubbleCntl"
local bubbleQueue = require "modules.bubbleQueue"
local composer = require "composer"
local controls = require "modules.controls"
local difficultyCntl = require "modules.difficultyCntl"
local dynamicBackground = require "modules.dynamicBackground"
local memoryManagement = require "modules.memoryManagement"
local musicAndSound = require "modules.musicAndSound"
local physics = require "physics"
local powerUpType = require "modules.powerUpType"
local scoreCntl = require "modules.scoreCntl"
local queueTimer = require "modules.queueTimer"
local UI = require "modules.UI"

local font = native.systemFont
local fontSize = 20
local swatchOverlayShowing = false
local SWATCH_ANIMATION_LENGTH = 500

-- Forward references
local background
local blockTouch
local bubbleCntlI
local homeBtn
local goHome
local noBtn
local onBackgroundTouch
local pauseMenu
local playBtn
local player
local promptDialog
local resume
local runtimeFunction
local warningDialogGroup
local yesBtn

composer.state.newStarsThisLevel = 0
composer.state.levelHighStreak = 0

-- Timer Memory Management
local timerStash = {}
local queueTimerContainer = {}
local swatchTimer
local spawnTimerContainer = {}

-- Transition Memory Management
local transitionStash = {}
local dieTransitions = {} -- The transitions that are used in death animation that get passed to level complete.
local particleTransitions = {}

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    -- Create a group that will be cleaned up in the next scene.
    local bleedGroup = display.newGroup()
    composer.state.returnTo = nil

    physics.start()
    physics.setGravity(0, 0)

    -- Uncomment to see physics bodies
    --physics.setDrawMode( "hybrid" )
    
    local wallGroup = bouncyWalls.new()

    --[[
        Init or reset modules:
        Modules are not objects, and the module state must be reset for each new level. The init/reset functions
        are similar to a constructor.
    ]]--
    bubbleCntlI = bubbleCntl.new(bubbleCntl.thePlayerShouldHaveATail(saves.upgradeSelections), sceneGroup, particleTransitions)
    controls.resetControls()
    difficultyCntl.init()
    scoreCntl.init()

    local function runinCoroutine()
        memoryManagement.cancelAllCompletedParticleTransitionsUsingPairs(particleTransitions)
    end

    assert( coroutine ~= nil )

    local cleanRoutine = coroutine.create(runinCoroutine)

    local function cleanParticleTransitions()
        if coroutine.status(cleanRoutine) == "suspended" then
            coroutine.resume(cleanRoutine)
        elseif coroutine.status(cleanRoutine) == "dead" then
            cleanRoutine = coroutine.create(runinCoroutine)
            coroutine.resume(cleanRoutine)
        end
    end

    timerStash[#timerStash + 1] = timer.performWithDelay( 1000, cleanParticleTransitions, 0 )
    

    local inTheProcessOfLosing = false

    local function getInTheProcessOfLosing()
        return inTheProcessOfLosing
    end

    local function setInTheProcessOfLosing(value)
        inTheProcessOfLosing = value
    end

    local function lose()
        local function callback()
            local options =
            {
                params = {
                    bleedGroup = bleedGroup,
                    transitions = dieTransitions,
                },   
            }

            composer.gotoScene("scenes.levelComplete", options)
        end

        -- Hide the player because if you delete him/her bad things happen in the runtime function.
        player.alpha = 0
        bubbleCntlI.deathPop(player, dieTransitions, bleedGroup)
        timerStash[table.getn(timerStash) + 1] = timer.performWithDelay(500, callback)
    end

    queueTimer.init(lose, getInTheProcessOfLosing, setInTheProcessOfLosing, queueTimerContainer)
        
    background = display.newImage( "images/background.png" )

    ---Scaling/Different Devices---
    --[[
        The background is big enough that there won't be any black bars on any of the current
        devices, the coordinates will also scale appropriately. The only thing we have to
        change for different devices is the the game area, and coordinates for spawning, 
        despawning, ect. Also we need to make two different resolutions for every graphic
        corona will automatically use the right one if we set it up correctly. It's ok to 
        to use numbers for coordinates, just know where you are referring to. For ex
        0 refers to distance form top left corner, and W and H refer to distance
        from the bottom right corner. There is also a shortcut for the center: display.contentCenter(X or Y)
        ]]--
    background.x = W / 2
    background.y = H / 2
               
    warningDialogGroup, yesBtn, noBtn = UI.newWarningDialog("Lose all progress?")

    --[[
        This function does only one thing - return true.
        This means that when the player clicks on the background, the dialog box will close unless they
        click the dialogBox itself because it the event will be handled (that's what returning true does)
    ]]
    function blockTouch(e) 
        return true
    end

    warningDialogGroup:addEventListener ( "touch", blockTouch )
    
    function promptDialog(e)
        if e.phase == "ended" then
            musicAndSound.playSound("pop")
                
            if warningDialogGroup.alpha == 0 then
                warningDialogGroup.alpha = 1
            else
                warningDialogGroup.alpha = 0
            end
        end

        return true
    end
        
    pauseMenu, playBtn, homeBtn = UI.newPauseDialog(W * .1, H * .1)
    
    local isPaused = false
    
    function resume(e)
        if e.phase == "began" and warningDialogGroup.alpha ~= 1 then
            if isPaused == true then
                musicAndSound.playSound("pop")
                controls.setTouchingBackground(false)
                isPaused = false
                pauseMenu.alpha = 0
                physics.start()
                audio.resume()

                memoryManagement.resumeTimer(swatchTimer)
                memoryManagement.resumeTimer(spawnTimerContainer[1])

                memoryManagement.resumeAllTimers(timerStash)
                memoryManagement.resumeAllTimers(queueTimerContainer)

                memoryManagement.resumeAllTransitions(transitionStash)
            end
        end
        return true
    end
    playBtn:addEventListener ( "touch", resume )
    
    function goHome(e)
        if isPaused == true then
            --If the player quits, it counts as a lost, and behaves the same way.
            isPaused = false
            pauseMenu.alpha = 0
            composer.gotoScene( "scenes.menu")
        end
        return true
    end

    homeBtn:addEventListener( "touch", promptDialog )
    yesBtn:addEventListener( "tap", goHome )

    local swatchGroup = UI.newSwatchGroup()

    local function hideSwatchGroup()
        transitionStash[table.getn(transitionStash) + 1] =  transition.to( swatchGroup, { time = SWATCH_ANIMATION_LENGTH, alpha = 0, x = swatchGroup.contentWidth } )
        swatchOverlayShowing = false
    end

    local function showSwatchGroup(showScore, showSequence, showStreak, newHighStreak, earnedAStar)       
        -- Update the swatch group.
        swatchGroup.update(scoreCntl.getLevelScore(), bubbleQueue.getSequenceNumber(), bubbleQueue.getStreak(), showScore, showSequence, showStreak, newHighStreak, earnedAStar)

        -- Transition the swatches in.
        transitionStash[table.getn(transitionStash) + 1] =  transition.to( swatchGroup, { time = SWATCH_ANIMATION_LENGTH, alpha = 1, x = 0 } )

        -- Replace timer
        memoryManagement.cancelTimer(swatchTimer)
        swatchTimer = timer.performWithDelay(2000, hideSwatchGroup)

        swatchOverlayShowing = true
    end

    local function pause()
        if isPaused == false then
            --can't play a pop here because the audio is paused.
            isPaused = true
            pauseMenu.alpha = 1
            physics.pause()
            audio.pause()

            memoryManagement.pauseTimer(swatchTimer)
            memoryManagement.pauseTimer(spawnTimerContainer[1])

            memoryManagement.pauseAllTimers(timerStash)
            memoryManagement.pauseAllTimers(queueTimerContainer)
            
            memoryManagement.pauseAllTransitions(transitionStash)
            controls.setTouchingBackground(false)
        end

        return true
    end

    local function onShake(e)
        if e.isShake then
            pause()
        end

        return true
    end

    Runtime:addEventListener( "accelerometer", onShake )
    
    local timerText = queueTimer.newTimerText()
    timerText.alpha = 0

    bubbleQueue.init(timerText, timerStash, transitionStash)
     
    -- Create the dynamic background
    local dynamicBackroundLayer = dynamicBackground.newDynamicBackroundLayer()

    player = bubbleCntlI.newPlayer(bubbleCntlI.getInitialPlayerSize(), W/2, H/2, 0, 0)

    -- Start the enemy spawner
    spawnTimerContainer[1] = bubbleCntlI.spawnContinuous()

    -- A table to hold enemies to be deleted
    local deleteTable = {}
 
    runtimeFunction = function( event )
        dynamicBackground.move(dynamicBackroundLayer) -- animate the background

        controls.movePlayer(player, saves.sensitivity)
                                                   
        for i = 1, (table.getn(bubbleCntlI.getSpawnTable())) do
            -- Tag objects that go off screen.
            if bubbleCntlI.getSpawnTable()[i] ~= nil then 
                bubbleCntlI.tag(bubbleCntlI.getSpawnTable()[i])
            end

            -- The first check is in case you collide with an enemy, while the loop is in the middle of a loop.
            -- The second check looks for a tag that is applied to an enemy when they should be deleted.
            if bubbleCntlI.getSpawnTable()[i] ~= nil and bubbleCntlI.getSpawnTable()[i].tag == true  then

                -- Remove powerup trails
                if bubbleCntlI.getSpawnTable()[i].trailTimer ~= nil then
                    timer.cancel(bubbleCntlI.getSpawnTable()[i].trailTimer)
                    bubbleCntlI.getSpawnTable()[i].onComplete()
                    bubbleCntlI.getSpawnTable()[i].trailTimer = nil
                end
        
                table.insert(deleteTable,bubbleCntlI.getSpawnTable()[i]) -- enemy is inserted into a table to be deleted in the next loop
                table.remove(bubbleCntlI.getSpawnTable(),i) -- enemy is removed from the loop, instead of set to nil which causes problems
                --There is no gap. Everything is shifted down.
            end
        end
        
        -- Remove all objects in the delete table
        if (table.getn(deleteTable)) > 0 then
            for i = 1, (table.getn(deleteTable)) do
                if deleteTable[i] ~= nil then --This could be a memory leak
                    deleteTable[i] = bubbleCntlI.deleteObject(deleteTable[i])
                end
            end
        end
    end

    Runtime:addEventListener( "enterFrame", runtimeFunction )

    --[[
        If an touch event is detected by the background, then it will stop the controls.
    ]]--
    function onBackgroundTouch(e) 
        if e.phase == "began" then
            if warningDialogGroup.alpha == 1 then
                -- Close the warning dialog group
                warningDialogGroup.alpha = 0
            else
                if isPaused == false then
                    -- Set the touch location so a force can be applied in that direction.
                    controls.setTouchX(e.x)
                    controls.setTouchY(e.y)

                    -- Player is now touching the background.
                    controls.setTouchingBackground(true)
                end
            end

        elseif e.phase == "ended" then
            -- Player stopped touching the background.
            controls.setTouchingBackground(false)
        end

        return true
    end

    background:addEventListener( "touch", onBackgroundTouch )
    noBtn:addEventListener( "touch", onBackgroundTouch )
        
    local visualQueue = bubbleQueue.newVisualQeue()
    bubbleQueue.updateVisualQueue(visualQueue)  -- udpate visual queue
    local bubbleColorIndex = 0


    local reListen
    local reducePlayerSizePowerUp
    local sequenceNumber = 1

    local function onLocalCollision(self, event)
        -- For every collision determine which swatches to display and set the flags
        local showScore = false
        local showSequence = false
        local showStreak = false

        local streakBefore = bubbleQueue.getStreak()
        local streakAfter
        local earnedAStar = false

        local function updateStuffIfNewSequence()
            -- If it is a new sequence...
            if bubbleQueue.getSequenceNumber() ~= sequenceNumber then
                sequenceNumber = bubbleQueue.getSequenceNumber()
                showSequence = true

                -- Check to see if a star was earned for this sequence.
                if ((bubbleQueue.getSequenceNumber() - 1) - saves.highestSequenceCompleted) > 0 then
                    --increment new stars this level variable
                    composer.state.newStarsThisLevel = (composer.state.newStarsThisLevel + 1)
                    earnedAStar = true
                else
                    earnedAStar = false
                end
               
                -- Restart the enemy spawner, with new spawn rate.
                memoryManagement.cancelTimer(spawnTimerContainer[1])
                spawnTimerContainer[1] = nil
                spawnTimerContainer[1] = bubbleCntlI.spawnContinuous()
            end
        end

        if ( event.phase == "began" and event.other.wall == true) then
            musicAndSound.playSound("bounce")
        end

        if ( event.phase == "began" and event.other.tag == false) then
            bubbleColorIndex = event.other.colorIndex

            -- If object is not a powerup...
            if event.other.powerUp == nil then
                musicAndSound.playSound("pop")

            -- If object is a powerup...
            else 
                musicAndSound.playSound("powerUpSound")

                -- Get powerUp type.
                local powerUp = event.other.powerUp

                -- Appy powerUp effects.
                if powerUp == powerUpType.TIMER_EXTENSION then
                    queueTimer.applyTimerExtensionPowerUp(bubbleQueue.getSequenceNumber())

                elseif (powerUp == powerUpType.REDUCE_PLAYER_SIZE) and (player.size > bubbleCntlI.getInitialPlayerSize()) then
                    timerStash[table.getn(timerStash) + 1] = timer.performWithDelay(1, reducePlayerSizePowerUp)

                elseif powerUp == powerUpType.WILD_CARD_BUBBLE then
                   -- Dealt with in pop.
                   
                elseif powerUp == powerUpType.SCORE_POWERUP then
                    scoreCntl.applyScorePowerUp() 
                    showScore = true

                elseif powerUp == powerUpType.SLOW_ENEMIES  then
                    bubbleCntlI.slowEnemies(spawnTimerContainer)

                elseif powerUp == powerUpType.CLEAR_QUEUE then
                    -- Apply the effect AFTER dealing with the powerup bubble - you have to check if that one is right.
                end

                -- Remove powerup trails
                if event.other.trailTimer ~= nil then
                    timer.cancel(event.other.trailTimer)
                    event.other.trailTimer = nil
                    if event.other.onComplete ~= nil then
                        event.other.onComplete()
                    else
                        -- Debugging an issue where the game freezes. Not sure what is going on here...
                        loadsave.printTable(event.other)
                    end
                end
            end

            -- Check to see if the correct color bubble was popped, and act on that result.
            if bubbleQueue.pop(event.other.colorIndex, visualQueue, event.other.powerUp) == true then
                showScore = true
                bubbleQueue.updateVisualQueue(visualQueue)  
                updateStuffIfNewSequence()

            -- The wrong bubble was popped.
            else            
                
                if event.other.powerUp ~= nil and event.other.powerUp == powerUpType.REDUCE_PLAYER_SIZE then
                    -- Do nothing, reduce size powerup.
                else
                    -- If the player eats the wrong color, he/she gets bigger.
                    local LOSE_SIZE = 120 -- when the player goes over this size they lose the level
                    if (player.size > LOSE_SIZE and getInTheProcessOfLosing() == false) then 
                        timerStash[table.getn(timerStash) + 1] = timer.performWithDelay(1, lose)
                        setInTheProcessOfLosing(true)
                    else
                        timerStash[table.getn(timerStash) + 1] = timer.performWithDelay(1, reListen )
                    end
                end
            end

            if event.other.powerUp == powerUpType.CLEAR_QUEUE then
                bubbleQueue.applyClearQueuePowerUp(event.other.colorIndex, visualQueue)
            
                updateStuffIfNewSequence()
            end

            -- Explosion animation.
            if event.other.powerUp == powerUpType.WILD_CARD_BUBBLE then
                event.other.colorIndex = 7
            end
            
            if event.other.powerUp ~= nil then
                bubbleCntlI.enemyPop(event.other, 50, 3000)
            else 
                   --pop for normal bubbles
                bubbleCntlI.enemyPop(event.other, 15, 2000)
            end
            
            -- Tag object for deletion.
            event.other.tag = true

            streakAfter = bubbleQueue.getStreak()

            local newHighStreak = false

            -- Show streak if it changes value.
            if streakBefore ~= streakAfter then
                showStreak = true
                if streakAfter ~= 0 then
                    if streakAfter > saves.allTimeHighStreak then
                        saves.allTimeHighStreak = streakAfter
                        newHighStreak = true
                    else
                        newHighStreak = false
                    end
                    composer.state.levelHighStreak = streakAfter
                else
                    newHighStreak = false
                end
            end

            
            showSwatchGroup(showScore, showSequence, showStreak, newHighStreak, earnedAStar)
        end        
    end

    player.collision = onLocalCollision
    player:addEventListener( "collision", player )
    wallGroup.update(player)

    reListen = function()
        if inTheProcessOfLosing == false then
            if player.trailTimer ~= nil then
                timer.cancel(player.trailTimer)
            end
            player = bubbleCntlI.eat(player)
            player.collision = onLocalCollision
            player:addEventListener( "collision", player )
            wallGroup.update(player)
        end
    end

    reducePlayerSizePowerUp = function() 
        if inTheProcessOfLosing == false then
            if player.trailTimer ~= nil then
                timer.cancel(player.trailTimer)
            end            
            player = bubbleCntlI.applyReducePlayerSizePowerUp(player)
            player.collision = onLocalCollision
            player:addEventListener( "collision", player )
            wallGroup.update(player)
        end
    end

    sceneGroup:insert( background )
    sceneGroup:insert( dynamicBackroundLayer )
    sceneGroup:insert( player )
    sceneGroup:insert( pauseMenu )
    sceneGroup:insert( visualQueue )
    sceneGroup:insert( timerText )
    sceneGroup:insert( swatchGroup )
    sceneGroup:insert( warningDialogGroup )
    sceneGroup:insert( wallGroup )
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        musicAndSound.stopMusic()
        musicAndSound.setMenuMusicPlaying(false)

        -- Play pop sound on scene load
        musicAndSound.playSound("pop")

        musicAndSound.startLevelMusic()
        
    elseif ( phase == "did" ) then

    end
end

function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Add the number of stars the player has earned this level.
        if (bubbleQueue.getSequenceNumber() - 1) > saves.highestSequenceCompleted then
            -- Update stars.
            saves.stars = saves.stars + ((bubbleQueue.getSequenceNumber() - 1) - saves.highestSequenceCompleted)

            -- Update highest sequence.
            saves.highestSequenceCompleted = bubbleQueue.getSequenceNumber() - 1
        end
        
        -- If the score is a highscore
        if scoreCntl.getLevelScore() > saves.highscore then
            -- Save highscore.
            saves.highscore = scoreCntl.getLevelScore() 
            
            -- Set a highscore notification flag for the level complete scene.
            composer.state.highScoreNotification = true
        else
            composer.state.highScoreNotification = false
        end
        
        -- Save the level score for level complete.
        composer.state.score = scoreCntl.getLevelScore()
        
        -- Save data.
        loadsave.saveData(saves)

        musicAndSound.stopMusic()
        
    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.

    local sceneGroup = self.view
    
    -- Remove runtime listeners.
    Runtime:removeEventListener("enterFrame", runtimeFunction)
    runtimeFunction = nil
    Runtime:removeEventListener( "accelerometer", onShake )
    onShake = nil

    -- Remove event listeners.
    warningDialogGroup:removeEventListener( "touch", blockTouch )
    playBtn:removeEventListener( "touch", resume )
    homeBtn:removeEventListener( "touch", promptDialog )
    yesBtn:removeEventListener( "tap", goHome )
    background:removeEventListener( "touch", onBackgroundTouch )
    noBtn:removeEventListener( "touch", onBackgroundTouch )
    player:removeEventListener( "collision", player )

    memoryManagement.cancelTimer(player.trailTimer)
    memoryManagement.cancelTimer(swatchTimer)
    memoryManagement.cancelTimer(spawnTimerContainer[1])

    queueTimer.cleanup()

    player = bubbleCntlI.deleteObject(player)

    for i = 1, (table.getn(bubbleCntlI.getSpawnTable())) do
        if bubbleCntlI.getSpawnTable()[i] then
            -- Remove powerup trails
            if bubbleCntlI.getSpawnTable()[i].trailTimer ~= nil then
                timer.cancel(bubbleCntlI.getSpawnTable()[i].trailTimer)
                bubbleCntlI.getSpawnTable()[i].trailTimer = nil
            end

            bubbleCntlI.getSpawnTable()[i] = bubbleCntlI.deleteObject(bubbleCntlI.getSpawnTable()[i])
        end
    end

    memoryManagement.cancelAllTimers(timerStash)
    memoryManagement.cancelAllTransitions(transitionStash)
    memoryManagement.cancelAllTransitionsUsingPairs(particleTransitions)

    bubbleCntlI.clean()
    bubbleCntlI = nil
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene