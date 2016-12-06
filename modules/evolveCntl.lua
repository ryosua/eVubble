--[[
    The controller for the evolve scene.
]]--

local evolveCntl = {}

-- Modules
local composer = require "composer"
local evubbleGameNetwork = require "modules.evubbleGameNetwork"
local upgradeCosts = require "modules.upgradeCosts"
local upgradeDescriptions = require "modules.upgradeDescriptions"

-- Map the upgrade combos to a file for the player
local playerMap = {}

--need to update with actual file names, concatenation on google doc: Animation List
playerMap["111"] = {"playerGrid_1", 1}
playerMap["121"] = {"playerGrid_1", 4}
playerMap["131"] = {"playerGrid_1", 10}
playerMap["141"] = {"playerGrid_1", 16}
playerMap["112"] = {"playerGrid_1", 3}
playerMap["122"] = {"playerGrid_2", 1}
playerMap["132"] = {"playerGrid_1", 26}
playerMap["142"] = {"playerGrid_1", 27}
playerMap["113"] = {"playerGrid_1", 9}
playerMap["123"] = {"playerGrid_1", 28}
playerMap["133"] = {"playerGrid_2", 3}
playerMap["143"] = {"playerGrid_1", 29}
playerMap["114"] = {"playerGrid_1", 15}
playerMap["124"] = {"playerGrid_1", 30}
playerMap["134"] = {"playerGrid_2", 9}
playerMap["144"] = {"playerGrid_2", 5}
playerMap["211"] = {"playerGrid_1", 2}
playerMap["221"] = {"playerGrid_1", 5}
playerMap["231"] = {"playerGrid_1", 19}
playerMap["241"] = {"playerGrid_1", 13}
playerMap["212"] = {"playerGrid_1", 6}
playerMap["222"] = {"playerGrid_2", 2}
playerMap["232"] = {"playerGrid_2", 10}
playerMap["242"] = {"playerGrid_1", 33}
playerMap["213"] = {"playerGrid_1", 23}
playerMap["223"] = {"playerGrid_1", 31}
playerMap["233"] = {"playerGrid_1", 36}
playerMap["243"] = {"playerGrid_2", 11}
playerMap["214"] = {"playerGrid_1", 24}
playerMap["224"] = {"playerGrid_1", 34}
playerMap["234"] = {"playerGrid_2", 12}
playerMap["244"] = {"playerGrid_2", 13}
playerMap["311"] = {"playerGrid_1", 8}
playerMap["321"] = {"playerGrid_1", 7}
playerMap["331"] = {"playerGrid_1", 11}
playerMap["341"] = {"playerGrid_1", 20}
playerMap["312"] = {"playerGrid_2", 7}
playerMap["322"] = {"playerGrid_1", 32}
playerMap["332"] = {"playerGrid_2", 28}
playerMap["342"] = {"playerGrid_2", 22}
playerMap["313"] = {"playerGrid_1", 12}
playerMap["323"] = {"playerGrid_2", 27}
playerMap["333"] = {"playerGrid_2", 4}
playerMap["343"] = {"playerGrid_2", 26}
playerMap["314"] = {"playerGrid_2", 8}
playerMap["324"] = {"playerGrid_2", 21}
playerMap["334"] = {"playerGrid_2", 20}
playerMap["344"] = {"playerGrid_2", 17}
playerMap["411"] = {"playerGrid_1", 14}
playerMap["421"] = {"playerGrid_1", 21}
playerMap["431"] = {"playerGrid_1", 22}
playerMap["441"] = {"playerGrid_1", 17}
playerMap["412"] = {"playerGrid_2", 25}
playerMap["422"] = {"playerGrid_1", 35}
playerMap["432"] = {"playerGrid_2", 24}
playerMap["442"] = {"playerGrid_2", 14}
playerMap["413"] = {"playerGrid_1", 25}
playerMap["423"] = {"playerGrid_2", 23}
playerMap["433"] = {"playerGrid_2", 19}
playerMap["443"] = {"playerGrid_2", 18}
playerMap["414"] = {"playerGrid_1", 18}
playerMap["424"] = {"playerGrid_2", 15}
playerMap["434"] = {"playerGrid_2", 16}
playerMap["444"] = {"playerGrid_2", 6}

local growthBranch = {20, 18, 15, 10} -- increaseSize(bubbleCntl.lua)
local timerBranch = {2, 3, 4, 6}      -- timerPerBubble(queueTimer.lua)
local luckBranch = {10, 13, 20, 30}   -- percentUprade(bubbleCntl.lua)

-- Constants
local GRID_SCALE = .25
local EMPTY_TABLE = {}
EMPTY_TABLE.unlocked = true
local ANIMATION_LENGTH = 250
	
-- Upgrade display objects
local growth1
local growth2
local growth3

local timer1
local timer2
local timer3

local luck1
local luck2
local luck3

local transitionStash = {}

--[[
    Returns the upgrade values in a table - frame, growth, and luck for a given selection.
]]--
local function applyUpgrade(growthBranchIndex, timerBranchIndex, luckBranchIndex)
    local upgrade = {}

    upgrade.frame = playerMap[tostring(growthBranchIndex) .. tostring(timerBranchIndex) .. tostring(luckBranchIndex)]

    upgrade.growth = growthBranch[growthBranchIndex]
    upgrade.timer = timerBranch[timerBranchIndex]
    upgrade.luck = luckBranch[luckBranchIndex]

    return upgrade
end

--[[
    Gets the default upgrade for the first time the player plays the game.
]]--
function evolveCntl.getDefault()
    return applyUpgrade(1, 1, 1)
end

--[[
    Purchases the upgrade if player has enough stars.

    returns true if purchase was successful or false if failed
]]--
local function attemptPurchase(cost, startCountText, growthSelection, timerSelection, luckSelection)
    local success = false
    if cost <= saves.stars then
        saves.stars = saves.stars - cost
        saves.starsSpent = saves.starsSpent + cost

        -- Save player data
        local playerData = applyUpgrade(growthSelection, timerSelection, luckSelection)
        local upgradeSelections = {growthSelection, timerSelection, luckSelection}
        saves.playerData = playerData
        saves.upgradeSelections = upgradeSelections
        loadsave.saveData(saves)

        -- Update star count
        startCountText.text = saves.stars

        success = true
    end

    return success
end

--[[
    The listener for the upgrade button on evolve.lua
]]--
function evolveCntl.onUpgradeTap(e)

    local button = e.target

    -- DEBUG
    --[[
    assert( button.cost ~= nil, "e.cost can not be nil." )
    assert( button.starCountText ~= nil, "button.starCountText can not be nil." )
    assert( button.growthSelection ~= nil, "e.growthSelection can not be nil." )
    assert( button.timerSelection ~= nil, "e.timerSelection can not be nil." )
    assert( button.luckSelection ~= nil, "e.luckSelection can not be nil." )
    ]]--

    local purchaseSuccessful = attemptPurchase(button.cost, button.starCountText, button.growthSelection, button.timerSelection, button.luckSelection)

    if purchaseSuccessful == true then
         -- Submits all unlocked achievements to Gamenetwork.
        if evubbleGameNetwork.loggedIntoGameNetwork == true then
            evubbleGameNetwork.unlockAchievementsLocally()
            evubbleGameNetwork.submitUnlockAchievements()
        end
    end
end

function evolveCntl.hideOverlay(e)
    composer.hideOverlay( "slideDown",  ANIMATION_LENGTH)
    return true
end

function evolveCntl.showEvolveOverlay(e)
    local canAfford = saves.stars >= e.target.cost

    if canAfford == true then
        local message = "Unlock for " .. e.target.cost .. " stars?"

        local options =
        {
            isModal = false,
            effect = "slideUp",
            time = ANIMATION_LENGTH,
            params = {
                message = message,
                cntl = evolveCntl,
                event = e,
                onPurchaseTap = e.target.onPurchaseTap,
                upgradeType = e.target.upgradeType,
            },   
        }

        composer.showOverlay( "scenes.evolveOverlay", options )
    end

    return true
end

function evolveCntl.getTransitionStash()
    return transitionStash
end

function evolveCntl.playStarAnimation(bubble, transitions, sceneGroup)
    for i=1, 150 do
        local spawns = {}
        spawns[i] = display.newImage( "images/starWhite.png", bubble.x, bubble.y )
        spawns[i].xScale = .25
        spawns[i].yScale = spawns[i].xScale
        sceneGroup:insert(spawns[i])
        
        local scale = math.random(1,25)/1000
        local spread = 2000
        local rotation = 360
        local time = 3500
        
        transitions[#transitions + 1] = transition.to( spawns[i], { transition = easing.outCubic, time=time, x=(spawns[i].x + math.random(-spread,spread)), y=(spawns[i].y + math.random(-spread,spread)),
                                        rotation = math.random(-rotation,rotation), xScale= scale, yScale = scale } )
        transitions[#transitions + 1]  = transition.to( spawns[i], { time=math.random(time/2,time), alpha=0} )
    end
end

return evolveCntl