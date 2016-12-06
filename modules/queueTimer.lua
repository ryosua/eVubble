--[[
    A module that encapsulates a queue timer.
]]--

-- Modules
local composer = require( "composer" )
local fonts = require "modules.fonts"
local memoryManagement = require "modules.memoryManagement"

local queueTimer = {}

local timeLeft = 0
local timeText = {}
local timerPerBubble
local loseCallbackRef
local getInTheProcessOfLosingRef
local setInTheProcessOfLosingRef
local queueTimerContainerRef

function queueTimer.init(loseCallback, getInTheProcessOfLosing, setInTheProcessOfLosing, queueTimerContainer)
    timerPerBubble = saves.playerData.timer
    timeLeft = 0
    loseCallbackRef = loseCallback
    getInTheProcessOfLosingRef = getInTheProcessOfLosing
    setInTheProcessOfLosingRef = setInTheProcessOfLosing
    queueTimerContainerRef = queueTimerContainer
end

function queueTimer.cleanup()
    memoryManagement.cancelAllTimers(queueTimerContainerRef)
end

--[[
    Calculates an alpha value for the timer based on the timeleft.
    The timer fades to black(alpha of 1) as it there is less time.
]]--
local function calculateTimerAlpha(timeLeft)
    return 1 / ((timeLeft/5)+1)
end

--[[
    Updates time.
]]--
local function updateTime()
    if timeLeft > 0 then
        timeLeft = timeLeft - 1
        timeText.text = timeLeft
		timeText.alpha = calculateTimerAlpha(timeLeft)
    else
        -- When timer runs out the player loses.
        if getInTheProcessOfLosingRef() == false then
            setInTheProcessOfLosingRef(true)
            loseCallbackRef()
        end
    end
end

--[[
    Calculates how much time is left at the beginning of each round.
]]--
local function calculateInitialTimeLeft(sequenceNumber)
    local timeLeft = 0
    local numberOfBubbles = sequenceNumber
    local paddingTime = math.floor(math.log(numberOfBubbles + .5)/math.log(1.1))

    timeLeft = (numberOfBubbles * timerPerBubble) + paddingTime

    return timeLeft
end

--[[
    Creates and starts a new timer. Passes references of a timer stash and timer text so that level 1 handles disposal
    of those objects.
]]--
function queueTimer.newTimer(sequenceNumber, timeTextRef)
    timeText = timeTextRef

    -- Calcuate time left
    timeLeft = calculateInitialTimeLeft(sequenceNumber)

    timeText.text = timeLeft
    timeText.alpha = calculateTimerAlpha(timeLeft)

    -- Ensure that there is only ever one queue timer
    memoryManagement.cancelAllTimers(queueTimerContainerRef)

    -- Start the timer - Call updatedTime function once per second, continuously
    queueTimerContainerRef[1] = timer.performWithDelay(1000, updateTime, 0)
end

--[[
    Creates and returns text to display the time left to the user.
]]--
function queueTimer.newTimerText()
    local font = fonts.getSystemFontBold()
    local fontSize = 150

    local timeText = display.newText(timeLeft, .95 * W ,.975 * H, font, fontSize)
    timeText:setFillColor(0,0,0)
    timeText.anchorX = 1
    timeText.anchorY = 1
    timeText.alpha = .25

    return timeText
end

--[[
    Applys a bonus to the time left.
]]--
function queueTimer.applyTimerExtensionPowerUp(sequenceNumber)
    timeLeft = math.floor( timeLeft + (calculateInitialTimeLeft(sequenceNumber) * .25) )
    timeText.text = timeLeft
end

-- Getters
function queueTimer.getTimeLeft()
    return timeLeft
end

return queueTimer