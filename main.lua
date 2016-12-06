display.setStatusBar( display.HiddenStatusBar )

-- Modules
local composer = require "composer"
local evubbleGameNetwork = require "modules.evubbleGameNetwork"
local keyListener = require "modules.keyListener"
local musicAndSound = require "modules.musicAndSound"
local singletons = require "modules.singletons"

-- Define composer state variables (to be used extremely sparingingly)
composer.state = {}
composer.state.highScoreNotification = false -- Whether or not to display a highscore notification.
composer.state.returnTo = nil
composer.state.singletonsI = singletons.new()

-- Modules that use state data
local memoryManagement = require "modules.memoryManagement"

-- Global constants
W = display.contentWidth  -- the width of the screen
H = display.contentHeight -- the height of the screen

-- loadsave - Library for saving and loading
loadsave = require "modules.loadsave"

-- Load saved data into a global saves table.
saves = loadsave.loadData()

-- Check to see if this is the first time that the game was played.
-- If it is the first time then call the erase data function wich will set all intital values of the game saves.
if (saves == nil) then
    memoryManagement.eraseAllData()
end

-- Image sheets - Custom module for imageSheets
imageSheet = require "modules.imageSheet"
    uniformSheet = imageSheet.uniformSheet
    nonUniformSheet = imageSheet.nonUniformSheet
    
local function main()

    musicAndSound.enableIpodMusic()

    -- Set composer to recycle on scene change, 
    -- or create a new scene everytime that scene is launched vs simpily hiding the display group.
    composer.recycleOnSceneChange = true

    Runtime:addEventListener( "system", evubbleGameNetwork.systemEvents )
    
    -- Add the key callback.
    Runtime:addEventListener( "key", keyListener.onKeyEvent )

    composer.gotoScene("scenes.splash")

    return
end

main()