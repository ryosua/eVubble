local dynamicOptions = {}

local sheetOptions =
{
    -- required parameters
    width = 250,
    height = 250,
    numFrames = 6,

    -- optional parameters; used for dynamic resolution support
    sheetContentWidth = 750,  -- width of original 1x size of entire sheet
    sheetContentHeight = 500   -- height of original 1x size of entire sheet
}

local imageSheet = graphics.newImageSheet( "images/optionsSheet.png", sheetOptions )

local minVelocity = -1 	-- specifies the minimum possible velocity
local maxVelocity = 1	-- specifies the maximum possible velocity

local FRAME_ALPHA = .90

local yOffset = (H*.225)

local function defineMoveableArea(dynamicOptionsLayer, i, left, right, top, bottom)
    if ( dynamicOptionsLayer[ i ].x <= (W * left) or dynamicOptionsLayer[ i ].x >= (W * right) ) then
            dynamicOptionsLayer[ i ].xMag = dynamicOptionsLayer[ i ].xMag * ( -1 )
    end
    if ( dynamicOptionsLayer[ i ].y <= (H * top - yOffset) or dynamicOptionsLayer[ i ].y >= (H * bottom - yOffset) ) then
        dynamicOptionsLayer[ i ].yMag = dynamicOptionsLayer[ i ].yMag * ( -1 )
    end
end

--[[
    Assesses the position of each frame in the group
    and redirects dynamicOptionsLayer which are beyond the bounds of the defined letter boundary based on i
]]--
local function shepherd(dynamicOptionsLayer)
    if ( dynamicOptionsLayer ~= nil ) then     -- if the dynamicOptionsLayer group has been initialized
        for i = 1 , dynamicOptionsLayer.numChildren  do     -- for each frame
            if (i == 7) then -- refer to index below, create a box for each letter in which it is allowed to move
                defineMoveableArea(dynamicOptionsLayer, i, 0.15, 0.2, 0.600, 0.650)
            elseif (i == 6) then
                defineMoveableArea(dynamicOptionsLayer, i, 0.25, 0.3, 0.538, 0.588)
            elseif (i == 5) then
                defineMoveableArea(dynamicOptionsLayer, i, 0.35, 0.40, 0.350, 0.400)
            elseif (i == 4) then
                defineMoveableArea(dynamicOptionsLayer, i, 0.825 , 0.875, 0.538, 0.588)
            elseif (i == 3) then
                defineMoveableArea(dynamicOptionsLayer, i, 0.725 , 0.775, 0.60, 0.650)
            elseif (i == 2) then
                defineMoveableArea(dynamicOptionsLayer, i, 0.60 , 0.65, 0.475, 0.525)
            else
                defineMoveableArea(dynamicOptionsLayer, i, 0.45 , 0.50, 0.538, 0.588)
            end
        end
    end
end

--[[
	renders/ re-renders all elements in the dynamicOptionsLayer group
]]--
function dynamicOptions.move(dynamicOptionsLayer)

    if ( dynamicOptionsLayer ~= nil ) then 	-- if the dynamicOptionsLayer group has been initialized

        for i = 1 , dynamicOptionsLayer.numChildren do 	-- for each frame
            -- Move the image.
			dynamicOptionsLayer[ i ]:translate( dynamicOptionsLayer[ i ].xMag , dynamicOptionsLayer[ i ].yMag )
		end

        shepherd(dynamicOptionsLayer) 	--redirect any frames which have been placed outside of the bounds of the screen
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

function dynamicOptions.newDynamicOptionsLayer()

    local dynamicOptionsLayer = display.newGroup() -- the display group containing all of the frame dynamicOptionsLayer

    --Height coordinates are based off a title centered in the middle of the screen. Offset in newCirlce function moves them
    -- Create frames.
    local o1 = newFrame(1, W*0.175, H*0.6250)
    local p1 = newFrame(2, W*0.275, H*0.5625)
    local t1 = newFrame(3, W*0.375, H*0.3750)
    local i1 = newFrame(4, W*0.475, H*0.5625)
    local o2 = newFrame(1, W*0.625, H*0.5000)
    local n1 = newFrame(5, W*0.750, H*0.6250)
    local s1 = newFrame(6, W*0.850, H*0.5625)

    --bottom layer
    dynamicOptionsLayer:insert( i1 ) --i=1
    dynamicOptionsLayer:insert( o2 ) --i=2
    dynamicOptionsLayer:insert( n1 ) --i=3
    dynamicOptionsLayer:insert( s1 ) --i=4
    dynamicOptionsLayer:insert( t1 ) --i=5
    dynamicOptionsLayer:insert( p1 ) --i=6
    dynamicOptionsLayer:insert( o1 ) --i=7
    -- top layer

    return dynamicOptionsLayer
end

return dynamicOptions
