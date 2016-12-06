--[[
    A module to control the queue, a sequence of colors the player must pop in order to progress through the game.
    The module is reused everytime the level is restarted, so any initial conditions must be reset in init.
]]--


-- Module variable
local bubbleQueue = {}

-- Modules
local difficultyCntl = require "modules.difficultyCntl"
local powerUpType = require "modules.powerUpType"
local scoreCntl = require "modules.scoreCntl"
local queueTimer = require "modules.queueTimer"

-- Initialize the pseudo random number generator with os time
math.randomseed( os.time() )

-- Pop off some random numbers for good measure (Not sure if this does anything, but Lua Doc. says to so...)
math.random(); math.random(); math.random()

-- table to store complete library of bubble colors
local colorProgression = {1, 2, 3, 4, 5, 6}

-- imagesheet declaration
local imageSheet = require "modules.queueImageSheet"

-- the queue model
local queue = {}
-- Current sequence number
local sequenceNumber = 0
-- The number of sequences completed correctly without making a mistake
local streak = 0
local missedABubbleThisSequence = false
local lastColorIndex

-- Level 1 references
local timeText
local timerStash
local transitionStash

--[[
    Returns a randomly selected color from colorProgression[n]
    where n <= sequenceNumber.
]]--
function bubbleQueue.getRandomColor()
    local index = lastColorIndex

    -- For sequence 1...
    if(sequenceNumber == 1) then

        index = colorProgression[1] -- ...spawn bubbles of 1 color

    else
        -- Never spawn the same color in a row after the first round.
        while index == lastColorIndex do
            if (sequenceNumber >= 2) and (sequenceNumber <= 3) then
                index = colorProgression[math.random(2)]
            elseif (sequenceNumber >= 4) and (sequenceNumber <= 8) then
                index = colorProgression[math.random(3)]
            elseif (sequenceNumber >= 9) and (sequenceNumber <= 15) then
                index = colorProgression[math.random(4)]
            elseif (sequenceNumber >= 16) and (sequenceNumber <= 22) then
                index = colorProgression[math.random(5)]
            else
                index = colorProgression[math.random(6)]
            end
        end
    end
    
    -- Remember the last color
    lastColorIndex = index

    return index
end

--[[
    Generates a queue containing randomly selected colors.
]]--
local function generateQueue()

    -- increment the sequence number
    sequenceNumber = sequenceNumber + 1

    -- Update the difficulty(which is a function of the sequence number)
    difficultyCntl.updateDifficulty(sequenceNumber)

    -- populate the queue with random color indeces
    for i = 1, sequenceNumber do
        queue[i] = bubbleQueue.getRandomColor()
    end

    if sequenceNumber > 1 then
        -- Create and start timer
        queueTimer.newTimer(sequenceNumber, timeText)
    end

    return queue
end

--[[
    Polls the last value from the queue and returns it.
    If queue is empty, returns nill.
]]--
local function poll()
    -- check that the queue has been implemented and is not empty
    -- if either cases are met, return nil
    if(queue == nil or table.getn(queue) == 0) then
        return nil
    else
        return queue[1]
    end
end

--[[
    Evaluates the bubble collided with the player and updates the model and display based on whether it was
    the correct color or not.
    Returns boolean to indicate a successful color poped or not.
]]--
function bubbleQueue.pop(colorIndex, visualQueue, powerupType)
    local correctColor = false

    if colorIndex == poll() and powerupType ~= powerUpType.WILD_CARD_BUBBLE then
        correctColor = true

        -- Give the player a point for getting the corret color.
        scoreCntl.setLevelScore( scoreCntl.getLevelScore() + 1 )

        table.remove(queue, 1)

    elseif powerupType == powerUpType.WILD_CARD_BUBBLE then
        correctColor = true

        -- Give the player a point for getting the corret color.
        scoreCntl.setLevelScore( scoreCntl.getLevelScore() + 1 )

        table.remove(queue, 1)

    elseif colorIndex ~= poll() then
        correctColor = false
        streak = 0
        missedABubbleThisSequence = true 
    end

    -- if the queue is now empty, generate a new queue
    if(poll() == nil) then

        -- Update the level score with the sequence bonus.
        scoreCntl.setLevelScore( scoreCntl.getLevelScore() + 
            scoreCntl.calculateSequenceBonus(queueTimer.getTimeLeft(), streak) ) 

        generateQueue()
        if missedABubbleThisSequence == false then
           streak = streak + 1 
        else
            streak = 0
        end
        missedABubbleThisSequence = false  
    end

    return correctColor
end

--[[
    Creates an empty visual queue.
]]--
function bubbleQueue.newVisualQeue()
    -- The display of the sequence of colors to aim for
    local visualQueue = display.newGroup()

    return visualQueue
end

--[[
    The bubble queue is displayed differently on different devices. This funciton get the paramerters for
    each device.
]]--
local function getVisualQueueSettings()
    local settings = 
    {
        bubbleScale = .08,
        padding = nil,
        fadeFactor = .26,
        edgeOffSet = W * .1
    }

    if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) then
        -- iPad
        settings.padding = 45
    elseif string.sub(system.getInfo("model"),1,2) == "iP" then
        -- iPhone
        settings.padding = 50
    else
        -- all other devices
        settings.padding = 50
    end

    return settings
end

local function emptyVisualQueue(visualQueue)
    -- Remove the old visual queue contents
    -- Can't just display.remove() the visualQueue because a reference is needed for the display group on level1
    -- Use a while loop becuase numChildren will be 1 smaller after each element removed
    while visualQueue.numChildren > 0 do
        display.remove( visualQueue[1] )
    end
end

local function animateVisualQueue(visualQueue, animationTime, powerupType)
    local params =
    {
        time = animationTime,
    }

    if powerupType == powerUpType.WILD_CARD_BUBBLE then
        params.y = H + visualQueue[1].contentHeight
        -- Drop 4 bubbles(every bubble in the queue, and maybe some in the next depending on the length)
        for i = 1, visualQueue.numChildren do
            transitionStash[table.getn(transitionStash) + 1] = transition.moveTo( visualQueue[i], params )
        end

    else 
        if visualQueue[1] ~= nil then
            params.y = H + visualQueue[1].contentHeight
            -- Drop the first bubble.
            transitionStash[table.getn(transitionStash) + 1] = transition.moveTo( visualQueue[1], params )

            -- Slide the rest of the bubbles over to the left.
            for i = 2, visualQueue.numChildren do
                params.y = nil
                params.x = visualQueue[i-1].x
                transitionStash[table.getn(transitionStash) + 1] = transition.moveTo( visualQueue[i], params )
            end
        end
    end
end

--[[
    Populates visualQueue with images.
]]--
local function fillVisualQueue(queue, visualQueue)
     -- Get display settings.
    local settings = getVisualQueueSettings()
    local bubbleScale = settings.bubbleScale
    local padding = settings.padding
    local fadeFactor = settings.fadeFactor

    local FIRST_BUBBLE_SIZE_MULTIPLIER = 1.25

    if (queue ~= nil) then
        -- limit the size of the queue to 8 bubbles
        local maxBubbles = table.getn(queue)
        if(table.getn(queue) > 4) then
            maxBubbles = 4
        end

        for i = 1, maxBubbles do
            local bubble = display.newImage(imageSheet, queue[i])
            if i == 1 then 
                bubble.xScale = bubbleScale * FIRST_BUBBLE_SIZE_MULTIPLIER
                bubble.yScale = bubble.xScale
            elseif i > 1 then 
                bubble.xScale = bubbleScale
                bubble.yScale = bubbleScale
            end
            
            bubble.x = (padding * i)
            bubble.y = H - padding
            bubble.alpha = 1.25 - (i * fadeFactor)
            bubble.name = tostring(i)

            visualQueue:insert ( bubble )
        end
    end
end

--[[
    Empty's the old queue, and adds the new images while animating the transition..
]]--
function bubbleQueue.updateVisualQueue(visualQueue, powerupType)
    local ANIMATION_TIME = 350

    animateVisualQueue(visualQueue, ANIMATION_TIME, powerupType)

    timerStash[table.getn(timerStash) + 1] = timer.performWithDelay( ANIMATION_TIME, 
        function()
            emptyVisualQueue(visualQueue)
            fillVisualQueue(queue, visualQueue)
        end
    )
end

--[[
    Pops all the bubbles in the queue.
]]--
function bubbleQueue.applyClearQueuePowerUp(colorIndex, visualQueue)
    local bubblesToPop = 4

    for i = 1, bubblesToPop do
        bubbleQueue.pop(3, visualQueue, powerUpType.WILD_CARD_BUBBLE)
    end

    bubbleQueue.updateVisualQueue(visualQueue, powerUpType.WILD_CARD_BUBBLE) 
end

--[[
    Reshuffles the color progression, resets the sequence number, the queue, and the visualqueue.
]]--
function bubbleQueue.init(timeTextRef, timerStashRef, transitionStashRef)
    timeText = timeTextRef
    timerStash = timerStashRef
    transitionStash = transitionStashRef

    -- Set the initial conditions for the variables
    sequenceNumber = 0
    streak = 0
    missedABubbleThisSequence = false
    lastColorIndex = 1
    
    -- Clear the queue.
    while ( table.getn( queue ) ~= 0 ) do
        table.remove( queue )
    end

    -- Generate the queue model.
    generateQueue()
end

-- Getters
function bubbleQueue.getSequenceNumber()
    return sequenceNumber
end

function bubbleQueue.getStreak()
    return streak
end

function bubbleQueue.getColorProgression()
    return colorProgression
end

return bubbleQueue
