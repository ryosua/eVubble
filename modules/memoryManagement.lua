--[[
    Contains functions to cancel timers and transitions, which needs to be done manually, and other related functions.
]]--

-- Modules
local achievementCode = require "modules.achievementCode"
local composer = require "composer"
local evolveCntl = require "modules.evolveCntl"

local memoryManagement = {}

local loggerI = composer.state.singletonsI.getLoggerI()
local log = loggerI.log

--[[
    Sets the initial values for all game saves, or can be used to reset all game data for a fresh start.
]]--
function memoryManagement.eraseAllData()
    -- Initialize global saves variable.
    saves = {}
    
    -- Variables
    saves.adsWatchedTowardsFreeStar = 0
    saves.allTimeHighStreak = 0
    saves.forcedThemToEvolve = false
    saves.highestSequenceCompleted = 0
    saves.highscore = 0
    saves.muteToggle = "neither"
    saves.numberOfPlays = 0
    saves.numberOfStarsWonByWatchingAds = 0
    saves.playerData = evolveCntl.getDefault()
    saves.sensitivity = 33
    saves.ratingPromptCounter = 0
    saves.ratingSetting = "Yes!" -- Code duplication w/ ratingPrompt.lua
    saves.showHints = true
    saves.stars = 0
    saves.starsSpent = 0
    saves.tutorial = true
    saves.upgradeSelections = {1, 1, 1} -- {growth, timer, luck}

    -- Achievements (Each has a corresponding ID in evubbleGameNetwork.lua)
    saves.achievements = 
    {
        [achievementCode.GROWTH_1] = false,
        [achievementCode.GROWTH_2] = false,
        [achievementCode.GROWTH_3] = false,
        [achievementCode.TIMER_1] = false,
        [achievementCode.TIMER_2] = false,
        [achievementCode.TIMER_3] = false,
        [achievementCode.LUCK_1] = false,
        [achievementCode.LUCK_2] = false,
        [achievementCode.LUCK_3] = false,
        [achievementCode.STREAK] = false,
    }
    
    -- Save the table as a json file.
    loadsave.saveData(saves)
end

function memoryManagement.cancelTimer(timerToCancel)
    if timerToCancel ~= nil then
        timer.cancel( timerToCancel )
        timerToCancel = nil
    end
end

--[[
    Cancels all timers in given table.
]]--
function memoryManagement.cancelAllTimers(timers)
    for i = 1, #timers do
        memoryManagement.cancelTimer(timers[i])
        timers[i] = nil
    end
end

function memoryManagement.cancelTransition(transitionToCancel)
    if transitionToCancel ~= nil then
        transition.cancel( transitionToCancel )
        transitionToCancel = nil
    end
end

--[[
    Cancels all transitions in given table. That is indexed numerically. DO NOT pass in a table with holes.
]]--
function memoryManagement.cancelAllTransitions(transitions)
    for i = 1, #transitions do
        memoryManagement.cancelTransition(transitions[i])
        transitions[i] = nil
    end
end

--[[
    Cancels all transitions in given table using pairs. Slower than the above function, but can handle named transitions
    and holes.
]]--
function memoryManagement.cancelAllTransitionsUsingPairs(transitions)
    for k,v in pairs(transitions) do
        transition.cancel( v )
        v = nil; k = nil
    end
end

--[[
    Used to cancel the particle transitions that are finished. If we let all the particle transitons stay in their
    table until the end of the level, there is a massive delay and/or crash. This is an essential optimization.
    This should be called on the transition table using a timer periodically. It should be wrapped in a coroutine as well.
]]--
function memoryManagement.cancelAllCompletedParticleTransitionsUsingPairs(transitions)
    local TRANSITIONS_TO_CANCEL_AT_A_TIME = 200
    local transitionsCanceled = 0

    for k,v in pairs(transitions) do
        if v.isCompleted() == true then
            if transitionsCanceled <= TRANSITIONS_TO_CANCEL_AT_A_TIME then
                transition.cancel(v)
                v = nil; k = nil
                transitionsCanceled = transitionsCanceled + 1
            else
                -- Reset the transitons canceled count and yield unitl the next call.
                transitionsCanceled = 0
                coroutine.yield()
            end
        end
    end
end

function memoryManagement.pauseTimer(timerToPause)
    if timerToPause ~= nil then
        timer.pause( timerToPause )
        timerToPause = nil
    end
end

--[[
    Pauses all timers in given table.
]]--
function memoryManagement.pauseAllTimers(timers)
    for i = 1, #timers do
        memoryManagement.pauseTimer(timers[i])
    end
end

--[[
    Pauses all transitions in given table.
]]--
function memoryManagement.pauseAllTransitions(transitions)
    for i = 1, #transitions do
        transition.pause( transitions[i] )
    end
end

function memoryManagement.resumeTimer(timerToResume)
    if timerToResume ~= nil then
        timer.resume( timerToResume )
    end
end

--[[
    Resumes all timers in given table.
]]--
function memoryManagement.resumeAllTimers(timers)
    for i = 1, #timers do
        memoryManagement.resumeTimer(timers[i])
    end
end

--[[
    Resumes all transitions in given table.
]]--
function memoryManagement.resumeAllTransitions(transitions)
    for i = 1, #transitions do
        transition.resume( transitions[i] )
    end
end

function memoryManagement.printMemUsage()          
    local memUsed = gcinfo()/ 1000
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1000000
    local memUsedFormatted = string.format("%.03f", memUsed)
    local textUsedFormatted = string.format("%.03f", texUsed)
end

return memoryManagement