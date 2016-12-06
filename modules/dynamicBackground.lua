local dynamicBackground = {}

local sheetOptions =	-- used with display.newImage()
{
    -- required parameters
    width = 200,
    height = 200,
    numFrames = 3,

    -- optional parameters; used for dynamic resolution support
    sheetContentWidth = 600,  -- width of original 1x size of entire sheet
    sheetContentHeight = 200   -- height of original 1x size of entire sheet
}

local imageSheet = graphics.newImageSheet( "images/primaryCircles.png", sheetOptions )

local minRadius = 850 	-- specifies the minimum possible circle radius
local maxRadius = 1200	-- specifies the maximum possible circle radius

local minVelocity = 5 	-- specifies the minimum possible velocity
local maxVelocity = 10 	-- specifies the maximum possible velocity

local CIRCLE_ALPHA = .25

--[[
    Assesses the position of each circle in the group
    and redirects dynamicBackroundLayer which are beyond the bounds of the screen.
]]--
local function shepherd(dynamicBackroundLayer)
    if ( dynamicBackroundLayer ~= nil ) then     -- if the dynamicBackroundLayer group has been initialized
        for i = 1 , dynamicBackroundLayer.numChildren  do     -- for each circle
            if ( dynamicBackroundLayer[ i ].x <= 0 or dynamicBackroundLayer[ i ].x >= W ) then    --i f the circle is beyond either x boundary of the screen
                dynamicBackroundLayer[ i ].xMag = dynamicBackroundLayer[ i ].xMag * ( -1 )    -- reverse x direction, head back into the fray 
            end

            if ( dynamicBackroundLayer[ i ].y <= 0 or dynamicBackroundLayer[ i ].y >= H ) then    -- if the circle is beyond either y boundary of the screen
                dynamicBackroundLayer[ i ].yMag = dynamicBackroundLayer[ i ].yMag * ( -1 )    -- reverse y direction, head back into the fray 
            end
        end
    end
end

--[[
	renders/ re-renders all elements in the dynamicBackroundLayer group
]]--
function dynamicBackground.move(dynamicBackroundLayer)
	
    if ( dynamicBackroundLayer ~= nil ) then 	-- if the dynamicBackroundLayer group has been initialized
		
        for i = 1 , dynamicBackroundLayer.numChildren do 	-- for each circle
            -- Move the image.
			dynamicBackroundLayer[ i ]:translate( dynamicBackroundLayer[ i ].xMag , dynamicBackroundLayer[ i ].yMag ) 	
		end

        shepherd(dynamicBackroundLayer) 	--redirect any circles which have been placed outside of the bounds of the screen
	end
end

--[[
	Returns a circle circle, represented by a displayobject.

	Circle fields:
	*x: the x position of the circle
	*y: the y position of the circle
	*xMag: the magnitude of the velocity in the x direction
	*yMag: the magnitude of the velocity in the y direction
	*size: the circles diameter
	*alpha: the circles alpha
	*image: the visualization of the circle (display.newImage)
]]--
local function newCircle(imageSheetFrame)
    local circle = display.newImage(imageSheet, imageSheetFrame)	--init the circles image

    -- Give the circles a random starting position.
    circle.x = math.random( W )
    circle.y = math.random( H )

    circle.alpha = CIRCLE_ALPHA

    circle.xMag = math.random( minVelocity , maxVelocity ) / 10	-- init xMag to a random value (pixels per second)
    circle.yMag = math.random( minVelocity , maxVelocity ) / 10 -- init yMag to a random value (pixels per second)

    local size = math.random( minRadius , maxRadius )	--i nit size to a random value (pixels)

    local sizeRatio = size / 200
    circle:scale( sizeRatio , sizeRatio )

    return circle
end

function dynamicBackground.newDynamicBackroundLayer()

    local dynamicBackroundLayer = display.newGroup() -- the display group containing all of the circle dynamicBackroundLayer

    -- Create circles.
    local circle1 = newCircle(1) 
    local circle2 = newCircle(2) 
    local circle3 = newCircle(3) 

    dynamicBackroundLayer:insert( circle1 ) -- yellow
    dynamicBackroundLayer:insert( circle3 ) -- cyan
    dynamicBackroundLayer:insert( circle2 ) -- magenta, top layer
    
    return dynamicBackroundLayer
end

return dynamicBackground