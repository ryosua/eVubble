local imageSheet = {}

--Widget Imagesheet
local sliderSheetOptions = {
    frames = {
        { x=0, y=0, width=37.5, height=37.5 },
        { x=37.5, y=0, width=37.5, height=37.5 },
        { x=75, y=0, width=37.5, height=37.5 },
        { x=112.5, y=0, width=37.5, height=37.5 },
        { x=150, y=0, width=37.5, height=37.5 }
    },
    sheetContentWidth = 187.5,
    sheetContentHeight = 37.5
}

imageSheet.sliderSheet = graphics.newImageSheet( "images/sliderSheet.png", sliderSheetOptions )

--First 36 frames
local playerGrid_1Options = 
{
    width = 330,
    height = 330,
    numFrames = 36,
    ----------Frame Index----------
    --SEE EVOLVECNTRL.LUA
    -------------------------------
}

imageSheet.playerGrid_1 = graphics.newImageSheet( "images/playerGrid_1.png", playerGrid_1Options )

--Second 28 frames
local playerGrid_2Options = 
{
    width = 330,
    height = 330,
    numFrames = 28,
    ----------Frame Index----------
    --SEE EVOLVECNTRL.LUA
    -------------------------------
}

imageSheet.playerGrid_2 = graphics.newImageSheet( "images/playerGrid_2.png", playerGrid_2Options )


local swatchSheetOptions = 
{
    --required parameters
    width = 300,
    height = 50,
    numFrames = 5,

    --optional parameters; used for dynamic resolution support
    sheetContentWidth = 300,  -- width of original 1x size of entire sheet
    sheetContentHeight = 250   -- height of original 1x size of entire sheet
}

imageSheet.swatchSheet = graphics.newImageSheet( "images/scoreSwatches.png", swatchSheetOptions )

local enemyImageSheetOptions = 
{
    --required parameters
    width = 500,
    height = 500,
    numFrames = 9,

    --optional parameters; used for dynamic resolution support
    sheetContentWidth = 1500,  -- width of original 1x size of entire sheet
    sheetContentHeight = 1500   -- height of original 1x size of entire sheet
}

imageSheet.enemyImageSheet = graphics.newImageSheet( "images/conceptEnemySheet.png", enemyImageSheetOptions )

local powerupImageSheetOptions = 
{
    --required parameters
    width = 650,
    height = 650,
    numFrames = 6,

    --optional parameters; used for dynamic resolution support
    sheetContentWidth = 1950,  -- width of original 1x size of entire sheet
    sheetContentHeight = 1300   -- height of original 1x size of entire sheet
}

imageSheet.powerupImageSheet = graphics.newImageSheet( "images/conceptEnemySheetPowerup.png", powerupImageSheetOptions )

return imageSheet