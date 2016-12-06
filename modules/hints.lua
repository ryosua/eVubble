local hints = {}

-- Modules
local UI = require "modules.UI"

-- Initialize the pseudo random number generator with os time
math.randomseed( os.time() )

-- Pop off some random numbers for good measure (Not sure if this does anything, but Lua Doc. says to so...)
math.random(); math.random(); math.random()

local hintList = 
{
    "The blue powerup adds more time to the countdown.",
    "The red powerup shrinks your size.",
    "The rainbow powerup counts for any color.",
    "The orange powerup pops 4 bubbles in the queue.",
    "The yellow powerup slows down the bubbles.",
    "The purple powerup is a significant score bonus.",
    "Unlock the wrong upgrade? Hit the recycle stars button to get your stars back.",
    "The growth upgrades reduce the size you will grow for making a mistake.",
    "The timer upgrades increase the time you have to complete a sequence.",
    "The luck upgrades increase the frequency of powerups.",
    "Unlocking upgrades changes your color.",
    "You can change the sensitivity of the controls in the options menu.",
    "You can turn off these tips by tapping the button on the bottom left of this screen.",
    "Shake to pause.",
    "You can purchase stars in the store if you get stuck trying to unlock an upgrade.",
    "Click the blinking ad star to watch ads and earn stars.",
    "The further away you tap from your player bubble, the faster you will move.",
}

function hints.getRandomHint()
    local i = math.random(table.getn(hintList))
    local hint = hintList[i]

    return hint
end 

function hints.newHintButton(displayGroup)
    local warningDialog, yesBtn, noBtn = UI.newWarningDialog("")
    displayGroup:insert(warningDialog)

    local function hideDialog()
        warningDialog.alpha = 0

        return true
    end
    yesBtn:addEventListener( "tap", hideDialog )
    noBtn.alpha = 0
    yesBtn.x = warningDialog.contentWidth * .5

    local function onHintButtonTap()
        if warningDialog.alpha == 0 then
            local warningText
            if saves.showHints == true then
                warningText = "You have turned off hints."
                saves.showHints = false
            else
                warningText = "You have turned on hints."
                saves.showHints = true
            end
            warningDialog.setText(warningText)

            warningDialog.alpha = 1

            loadsave.saveData(saves) 
        end
    
        return true
    end

    local hintButton = display.newImage( "images/hintsBtn.png" )
    hintButton.xScale = .65
    hintButton. yScale = hintButton.xScale
    hintButton.x = W * .1
    hintButton.y = H * .90
    hintButton.alpha = 1

    hintButton:addEventListener( "tap", onHintButtonTap )

    return hintButton

end



return hints