local dynamicMenuBtns = {}

-- Modules
local evubbleGameNetwork = require "modules.evubbleGameNetwork"
local musicAndSound = require "modules.musicAndSound"

-- The leaderboards button has a different look depending on the platform.
local imageSheet = nil

local sheetOptions =
{
    -- required parameters
    width = 350,
    height = 350,
    numFrames = 6,

    -- optional parameters; used for dynamic resolution support
    sheetContentWidth = 1050,  -- width of original 1x size of entire sheet
    sheetContentHeight = 700   -- height of original 1x size of entire sheet
}

-- For iOS or the simulators use iOS button.
local frames = {}

if (system.getInfo( "platformName" ) == "iPhone OS") 
    or (system.getInfo( "platformName" ) == "Mac OS X") 
    or (system.getInfo( "platformName" ) == "Win") then
    frames.loggedIn = 4
    frames.loggedOut = 3
elseif (system.getInfo( "platformName" ) == "Android") then
    frames.loggedIn = 1
    frames.loggedOut = 2
end

imageSheet = graphics.newImageSheet( "images/menuBtn6Sheet.png", sheetOptions )

local minVelocity = -2 	-- specifies the minimum possible velocity
local maxVelocity = 2	-- specifies the maximum possible velocity

local FRAME_ALPHA = .95

local yOffset = (H*.01)

local dynamicMenuBtnsLayer
local leaderBtn

local LEADERBOARD_STARTING_X = W * .225
local LEADERBOARD_STARTING_Y = H *.75

local leaderBtnSavedX = LEADERBOARD_STARTING_X
local leaderBtnSavedY = LEADERBOARD_STARTING_Y

local function defineMoveableArea(dynamicMenuBtnsLayer, i, left, right, top, bottom)
    if ( dynamicMenuBtnsLayer[ i ].x <= (W * left) or dynamicMenuBtnsLayer[ i ].x >= (W * right) ) then
            dynamicMenuBtnsLayer[ i ].xMag = dynamicMenuBtnsLayer[ i ].xMag * ( -1 )
    end
    if ( dynamicMenuBtnsLayer[ i ].y <= (H * top - yOffset) or dynamicMenuBtnsLayer[ i ].y >= (H * bottom - yOffset) ) then
        dynamicMenuBtnsLayer[ i ].yMag = dynamicMenuBtnsLayer[ i ].yMag * ( -1 )
    end
end

--[[
    Assesses the position of each frame in the group
    and redirects dynamicMenuBtnsLayer which are beyond the bounds of the defined letter boundary based on i
]]--
local function shepherd(dynamicMenuBtnsLayer)
    if ( dynamicMenuBtnsLayer ~= nil ) then     -- if the dynamicMenuBtnsLayer group has been initialized
        for i = 1 , dynamicMenuBtnsLayer.numChildren  do     -- for each frame
            if (i == 3) then -- refer to index below, create a box for each letter in which it is allowed to move
                defineMoveableArea(dynamicMenuBtnsLayer, i, 0.2, 0.25, 0.725, 0.775)
            elseif (i == 2) then
                defineMoveableArea(dynamicMenuBtnsLayer, i, 0.475 , 0.525, 0.725, 0.775)
            else
                defineMoveableArea(dynamicMenuBtnsLayer, i, 0.7 , 0.75, 0.725, 0.775)
            end
        end
    end
end

--[[
	renders/ re-renders all elements in the dynamicMenuBtnsLayer group
]]--
function dynamicMenuBtns.move(dynamicMenuBtnsLayer)

    if ( dynamicMenuBtnsLayer ~= nil ) then 	-- if the dynamicMenuBtnsLayer group has been initialized

        for i = 1 , dynamicMenuBtnsLayer.numChildren do 	-- for each frame
            -- Move the image.
			dynamicMenuBtnsLayer[ i ]:translate( dynamicMenuBtnsLayer[ i ].xMag , dynamicMenuBtnsLayer[ i ].yMag )
		end

        leaderBtnSavedX = leaderBtn.x
        leaderBtnSavedY = leaderBtn.y

        shepherd(dynamicMenuBtnsLayer) 	--redirect any frames which have been placed outside of the bounds of the screen
	end
end

--[[
	Returns a frame frame, represented by a displayobject.

	frame fields:
	*x: the x position of the frame
	*y: the y position of the frame
	*xMag: the magnitude of the velocity in the x direction
	*yMag: the magnitude of the velocity in the y direction
	*size: the frames diameter
	*alpha: the frames alpha
	*image: the visualization of the frame (display.newImage)
]]--
local function newFrame(imageSheetFrame, xcord, ycord)

    local frame = display.newImage(imageSheet, imageSheetFrame)	--init the frames image

    frame.x = xcord
    frame.y = ycord - yOffset

    frame.alpha = FRAME_ALPHA

    --[[WITH THE POSSIBLE RANDOM CHOICES AS [-1, 0, 1] OCCASIONALLY I'D GET A FROZEN BUBBLE FOR EXAMPLE WHEN XMAG AND YMAG WERE
        BOTH 0. TO SOVLE, I'M ADDING A FRACTION, SO THAT DESPITE THE RANDOM CHOICE, IT WILL NEVER BE 0]]
    frame.xMag = (math.random( minVelocity , maxVelocity ) + ((math.random(25,75)/100)) ) *.04	-- init xMag to a random value (pixels per second)
    frame.yMag = (math.random( minVelocity , maxVelocity ) - ((math.random(25,75)/100)) ) *.04   -- init yMag to a random value (pixels per second)

    local size = 350	--size of frames

    local sizeRatio = size / 1100
    frame:scale( sizeRatio , sizeRatio )

    return frame
end

function dynamicMenuBtns.refreshGameNetworkButton()
    local leaderBoardBtnFrame

    if evubbleGameNetwork.loggedIntoGameNetwork == true then
        leaderBoardBtnFrame = frames.loggedIn
    else
        leaderBoardBtnFrame = frames.loggedOut
    end

    display.remove( leaderBtn )

    leaderBtn = newFrame(leaderBoardBtnFrame, leaderBtnSavedX, leaderBtnSavedY)

    local function loggedOutListener()
        musicAndSound.playSound("pop")
        native.showAlert( "Oops!", "Log in to access the leaderboard.", {"Ok"})
        return true
    end

    local function showLeaderboard()
        musicAndSound.playSound("pop")
        evubbleGameNetwork.showLeaderboard()
        return true
    end

    if evubbleGameNetwork.loggedIntoGameNetwork == true then
        leaderBtn:addEventListener( "tap", showLeaderboard )
    else
        leaderBtn:addEventListener( "tap", loggedOutListener )
    end

    leaderBtn.x = leaderBtnSavedX
    leaderBtn.y = leaderBtnSavedY

    dynamicMenuBtnsLayer:insert( leaderBtn ) --i=1
end

--[[
    Returns the group containing the dynamic menu buttons.

    switchSceneListener - a function to be added as a tap event listener to the play and evolve buttons that switches
    scenes.
]]--
function dynamicMenuBtns.newDynamicMenuBtnsLayer(switchSceneListener)
    --Height coordinates are based off a title centered in the middle of the screen. Offset in newCirlce function moves them
    -- Create frames.

    dynamicMenuBtnsLayer = display.newGroup() -- the display group containing all of the frame dynamicMenuBtnsLayer
    local playBtn = newFrame(5, W * .500, H *.75)
    playBtn.scene = "scenes.level1"
    local starBtn = newFrame(6, W * .775, H *.75)
    starBtn.scene = "scenes.evolve"

    dynamicMenuBtns.refreshGameNetworkButton()

    --bottom layer
    dynamicMenuBtnsLayer:insert( starBtn ) --i=2
    dynamicMenuBtnsLayer:insert( playBtn ) --i=3
    -- top layer

    playBtn:addEventListener ( "tap", switchSceneListener )
    starBtn:addEventListener ( "tap", switchSceneListener )

    return dynamicMenuBtnsLayer
end

return dynamicMenuBtns
