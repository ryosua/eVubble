local dynamicMenu = {}

local sheetOptions =
{
    -- required parameters
    width = 250,
    height = 250,
    numFrames = 7,

    -- optional parameters; used for dynamic resolution support
    sheetContentWidth = 750,  -- width of original 1x size of entire sheet
    sheetContentHeight = 750   -- height of original 1x size of entire sheet
}

local imageSheet = graphics.newImageSheet( "images/menuLetters.png", sheetOptions )

local minVelocity = -1 	-- specifies the minimum possible velocity
local maxVelocity = 1	-- specifies the maximum possible velocity

local FRAME_ALPHA = .90

local yOffset = (H*.150)

local function defineMoveableArea(dynamicMenuLayer, i, left, right, top, bottom)
    if ( dynamicMenuLayer[ i ].x <= (W * left) or dynamicMenuLayer[ i ].x >= (W * right) ) then
            dynamicMenuLayer[ i ].xMag = dynamicMenuLayer[ i ].xMag * ( -1 )
    end
    if ( dynamicMenuLayer[ i ].y <= (H * top - yOffset) or dynamicMenuLayer[ i ].y >= (H * bottom - yOffset) ) then
        dynamicMenuLayer[ i ].yMag = dynamicMenuLayer[ i ].yMag * ( -1 )
    end
end

--[[
    Assesses the position of each frame in the group
    and redirects dynamicMenuLayer which are beyond the bounds of the defined letter boundary based on i
]]--
local function shepherd(dynamicMenuLayer)
    if ( dynamicMenuLayer ~= nil ) then     -- if the dynamicMenuLayer group has been initialized
        for i = 1 , dynamicMenuLayer.numChildren  do     -- for each frame
            if (i == 7) then -- refer to index below, create a box for each letter in which it is allowed to move
                defineMoveableArea(dynamicMenuLayer, i, 0.15, 0.2, 0.600, 0.650)
            elseif (i == 6) then
                defineMoveableArea(dynamicMenuLayer, i, 0.25, 0.3, 0.538, 0.588)
            elseif (i == 5) then
                defineMoveableArea(dynamicMenuLayer, i, 0.35, 0.40, 0.350, 0.400)
            elseif (i == 4) then
                defineMoveableArea(dynamicMenuLayer, i, 0.825 , 0.875, 0.538, 0.588)
            elseif (i == 3) then
                defineMoveableArea(dynamicMenuLayer, i, 0.725 , 0.775, 0.60, 0.650)
            elseif (i == 2) then
                defineMoveableArea(dynamicMenuLayer, i, 0.60 , 0.65, 0.475, 0.525)
            else
                defineMoveableArea(dynamicMenuLayer, i, 0.45 , 0.50, 0.538, 0.588)
            end
        end
    end
end

--[[
	renders/ re-renders all elements in the dynamicMenuLayer group
]]--
function dynamicMenu.move(dynamicMenuLayer)

    if ( dynamicMenuLayer ~= nil ) then 	-- if the dynamicMenuLayer group has been initialized

        for i = 1 , dynamicMenuLayer.numChildren do 	-- for each frame
            -- Move the image.
			dynamicMenuLayer[ i ]:translate( dynamicMenuLayer[ i ].xMag , dynamicMenuLayer[ i ].yMag )
		end

        shepherd(dynamicMenuLayer) 	--redirect any frames which have been placed outside of the bounds of the screen
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

    local size = 250	--size of frames

    local sizeRatio = size / 500
    frame:scale( sizeRatio , sizeRatio )

    return frame
end

function dynamicMenu.newDynamicMenuLayer()

    local dynamicMenuLayer = display.newGroup() -- the display group containing all of the frame dynamicMenuLayer

    --Height coordinates are based off a title centered in the middle of the screen. Offset in newCirlce function moves them
    -- Create frames.
    local e1 = newFrame(1, W*0.175, H*0.6250)
    local v1 = newFrame(2, W*0.275, H*0.5625)
    local u1 = newFrame(3, W*0.375, H*0.3750)
    local b1 = newFrame(4, W*0.475, H*0.5625)
    local b2 = newFrame(4, W*0.625, H*0.5000)
    local l1 = newFrame(5, W*0.750, H*0.6250)
    local e2 = newFrame(1, W*0.850, H*0.5625)

    --bottom layer
    dynamicMenuLayer:insert( b1 ) --i=1
    dynamicMenuLayer:insert( b2 ) --i=2
    dynamicMenuLayer:insert( l1 ) --i=3
    dynamicMenuLayer:insert( e2 ) --i=4
    dynamicMenuLayer:insert( u1 ) --i=5
    dynamicMenuLayer:insert( v1 ) --i=6
    dynamicMenuLayer:insert( e1 ) --i=7
    -- top layer

    return dynamicMenuLayer
end

return dynamicMenu
