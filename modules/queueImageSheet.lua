--Image sheet w/ identical frame sizes
local sheetOptions =    --used with display.newImage()
    {
        --required parameters
        width = 500,
        height = 500,
        numFrames = 6,

        --optional parameters; used for dynamic resolution support
        sheetContentWidth = 1500,  -- width of original 1x size of entire sheet
        sheetContentHeight = 1000   -- height of original 1x size of entire sheet
    }

local imageSheet = graphics.newImageSheet( "images/sequenceTiles.png", sheetOptions )  --imagesheet declaration

return imageSheet