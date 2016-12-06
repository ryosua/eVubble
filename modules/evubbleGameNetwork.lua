--[[
    This module contains all the code needed for game network interactions. 
    It has the evubble in the name to prevent conflict with Corona's module of the same name.
]]--

local evubbleGameNetwork = {}

-- require Corona modules
local achievementCode = require "modules.achievementCode"
local composer = require "composer"
local gameNetwork = require "gameNetwork"

local appStoreIDs = 
{
    leaderboards = 
    {
        score = "", -- removed
        highestStreak = "", -- removed
    },

    achievements = 
    {
        [achievementCode.GROWTH_1] = "", -- removed
        [achievementCode.GROWTH_2] = "", -- removed
        [achievementCode.GROWTH_3] = "", -- removed
        [achievementCode.TIMER_1] = "", -- removed
        [achievementCode.TIMER_2] = "", -- removed
        [achievementCode.TIMER_3] = "", -- removed
        [achievementCode.LUCK_1] = "", -- removed
        [achievementCode.LUCK_2] = "", -- removed
        [achievementCode.LUCK_3] = "", -- removed
        [achievementCode.STREAK] = "", -- removed
    } 
}

local googlePlayIDs = 
{
    leaderboards = 
    {
        score = "", -- removed
        highestStreak = "", -- removed
    },
    achievements = 
    {
        [achievementCode.GROWTH_1] = "", -- removed
        [achievementCode.GROWTH_2] = "", -- removed
        [achievementCode.GROWTH_3] = "", -- removed
        [achievementCode.TIMER_1] = "", -- removed
        [achievementCode.TIMER_2] = "", -- removed
        [achievementCode.TIMER_3] = "", -- removed
        [achievementCode.LUCK_1] = "", -- removed
        [achievementCode.LUCK_2] = "", -- removed
        [achievementCode.LUCK_3] = "", -- removed
        [achievementCode.STREAK] = "", -- removed
    }
}

local IDs 

-- init module variables
evubbleGameNetwork.loggedIntoGameNetwork = false

--[[
    The function to be called when the module is requested by another file. 
    (Any code that should be executed just once on module load should go here)
]]--
local function onModuleLoad()
    -- Choose the IDs to use.
    if ( system.getInfo( "platformName" ) == "Android" ) then
        IDs = googlePlayIDs
    else
        IDs = appStoreIDs
    end
end

-- Call load function
onModuleLoad()

--[[
    Called after the setHighScore request is completed.
    Assumes evubbleGameNetwork.loggedIntoGameNetwork == true.
]]--
local function updateLeaderBoardCallback(e)
    -- Can eliminate this function as it does nothing, but first check that updateHighscore request does 
    -- not require a callback.
end

local function unlockRequestCallback(e)
    --native.showAlert( "", e.data, {ok})
end

--[[
    Called after the loadLocalPlayer function is completed. Sets the loggedIntoGameNetwork variable.
]]--
local function loadLocalPlayerCallback(e)
    loadsave.printTable(e)

    if (system.getInfo( "platformName" ) == "iPhone OS") then 
        if e.data.isAuthenticated == true then
            evubbleGameNetwork.loggedIntoGameNetwork = true
        else 
            evubbleGameNetwork.loggedIntoGameNetwork = false
        end
    elseif (system.getInfo( "platformName" ) == "Android") then
        if e.data then
            evubbleGameNetwork.loggedIntoGameNetwork = true
            playerName = e.data.alias
        else
            evubbleGameNetwork.loggedIntoGameNetwork = false
        end
    else
        evubbleGameNetwork.loggedIntoGameNetwork = false
    end    

    if composer.getSceneName("current") == "scenes.menu" then                 
        composer.getScene(composer.getSceneName("current")):loadGameNetworkButton()
    end
end

--[[
    Called after the "init" request has completed, directly for gamecenter, indirectly for google.
]]--
local function gameNetworkLoginCallback(e)
    gameNetwork.request( "loadLocalPlayer", { listener=loadLocalPlayerCallback } )
    return true
end

--[[
    Called after the "init" request has completed if "google" is chosen, then calls the gameNetworkLoginCallback.
    This process seems sloppy, google has a seperate login request that needs to be called.
]]--
local function gpgsInitCallback(e)
    gameNetwork.request( "login", { userInitiated=true, listener=gameNetworkLoginCallback } )
end

local function updateLeaderBoard(ID, value)
    -- Sets the score if it is higher than the one on Apple's server
    gameNetwork.request( "setHighScore",
    {
        localPlayerScore = { category = ID, value = value },
        listener = updateLeaderBoardCallback
    })
end

--[[
    Update the gamecenter learderboard for gamescore.
    Assumes evubbleGameNetwork.loggedIntoGameNetwork == true.
]]--
function evubbleGameNetwork.updateLeaderboards(score, highestStreak)
    updateLeaderBoard(IDs.leaderboards.score, score)
    updateLeaderBoard(IDs.leaderboards.highestStreak, highestStreak)
end

--[[
    Send the request to gamenetwork to unlock the achievement with given ID, and percent complete.
    Assumes evubbleGameNetwork.loggedIntoGameNetwork == true.
]]--
local function unlockRequest(achievementID)
    gameNetwork.request( "unlockAchievement",
    {
        achievement =
        {
            identifier = achievementID,
            percentComplete = 100,       -- Corona does not support incremental unlocks for Google yet.
            showsCompletionBanner = true       
        },
        listener = unlockRequestCallback
    })
end

--[[
    Send the request to gamenetwork to unlock all achievements that have been unlocked locally.
    Assumes evubbleGameNetwork.loggedIntoGameNetwork == true.
]]--
function evubbleGameNetwork.submitUnlockAchievements()
    for i = 1, table.getn(saves.achievements) do
        if saves.achievements[i] == true then
            unlockRequest(IDs.achievements[i])
        end
    end
end

-- Functions that unlock the acheivements locally.
local function unlockLocalGrowth1Acievement()
    saves.achievements[achievementCode.GROWTH_1] = true
end

local function unlockLocalGrowth2Acievement()
    saves.achievements[achievementCode.GROWTH_2] = true
end

local function unlockLocalGrowth3Acievement()
    saves.achievements[achievementCode.GROWTH_3] = true
end

local function unlockLocalTimer1Acievement()
    saves.achievements[achievementCode.TIMER_1] = true
end

local function unlockLocalTimer2Acievement()
    saves.achievements[achievementCode.TIMER_2] = true
end

local function unlockLocalTimer3Acievement()
    saves.achievements[achievementCode.TIMER_3] = true
end

local function unlockLocalLuck1Acievement()
    saves.achievements[achievementCode.LUCK_1] = true
end

local function unlockLocalLuck2Acievement()
    saves.achievements[achievementCode.LUCK_2] = true
end

local function unlockLocalLuck3Acievement()
    saves.achievements[achievementCode.LUCK_3] = true
end

function evubbleGameNetwork.unlockAchievementsLocally()
    local upgrades = saves.upgradeSelections

    local growth = upgrades[1]
    local timer = upgrades[2]
    local luck = upgrades[3]

    if growth >= 2 then
        unlockLocalGrowth1Acievement()
    end
    if growth >= 3 then
        unlockLocalGrowth2Acievement()
    end
    if growth >= 4 then
        unlockLocalGrowth3Acievement()
    end

    if timer >= 2 then
        unlockLocalTimer1Acievement()
    end
    if timer >= 3 then
        unlockLocalTimer2Acievement()
    end
    if timer >= 4 then
        unlockLocalTimer3Acievement()
    end

    if luck >= 2 then
        unlockLocalLuck1Acievement()
    end
    if luck >= 3 then
        unlockLocalLuck2Acievement()
    end
    if luck >= 4 then
        unlockLocalLuck3Acievement()
    end

    loadsave.saveData(saves)
end

function evubbleGameNetwork.updateLocalStreakAcievement()
    local STREAK_ACHIEVEMEMNT_VALUE = 15
    if saves.allTimeHighStreak >= STREAK_ACHIEVEMEMNT_VALUE then
        saves.achievements[achievementCode.STREAK] = true
        loadsave.saveData(saves)
    end
end

--[[
    System event callback - when appliction is started, init the platform(iOS or Android), or print a unsupported message.
]]--
function evubbleGameNetwork.systemEvents(e) 
    if e.type == "applicationStart" then
        if (system.getInfo( "platformName" ) == "iPhone OS") then 
            gameNetwork.init( "gamecenter", gameNetworkLoginCallback )

        elseif (system.getInfo( "platformName" ) == "Android") then
            gameNetwork.init( "google", gpgsInitCallback )

        else
            -- DEBUG
            print "Game network not supported on this device, test code on device, or XCODE simulator."
        end 

        return true
    end
end

--[[
    Links to Gamcenter or Google Play leaderboards page for eVubble within the game.
]]--
function evubbleGameNetwork.showLeaderboard()
    gameNetwork.show("leaderboards")
end

--[[
    Links to Google Play achievements page for eVubble within the game.
]]--
function evubbleGameNetwork.showAchievements()
    gameNetwork.show("achievements")
end

-- Return module variable
return evubbleGameNetwork