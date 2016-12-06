--[[
	A module for the rating prompt system.
]]--

local ratingPrompt = {}

-- Modules
local musicAndSound = require "modules.musicAndSound"
local UI = require "modules.UI"

local DELAY = 100
local timerStashRef

local ratingTitle = "Enjoying eVubble?"

local choices = {} 
	choices.yes = "Yes!"
	choices.no = "Not really"

--[[ 
	This is the table that is actually getting passed to the alert object. 
	It needs to be indexed by numbers (array stlye, not dictinary syle) because these determine the order
]]--
local choiceArray = {}
	choiceArray[1] = choices.yes
	choiceArray[2] = choices.no

--[[
	The player earns a star for rating the app or sending us an email.
]]--
local function awardStar()
	saves.stars = saves.stars + 1
	loadsave.saveData(saves)

	local warningDialog, yesBtn, noBtn = UI.newWarningDialog("You've earned a star.")
	noBtn.alpha = 0
    yesBtn.x = warningDialog.contentWidth * .5

    musicAndSound.playSound("starSound")

    local function closeDialog()
        warningDialog.alpha = 0

        -- Instead of creating a dependancy on the calling scene to access the scene group,
        -- just deal with removing the graphic manually.
        display.remove( warningDialog )
        warningDialog = nil

        return true
    end

    yesBtn:addEventListener( "tap", closeDialog )

    -- Show dialog.
    warningDialog.alpha = 1
end

local function openNewEmail()
	local options =
	{
	    to = "contact@yosuatreegames.com",
	    subject = "eVubble Feedback",
	    body = "",
	}

	native.showPopup("mail", options)
end

local function openAppInStore()
	if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) or string.sub(system.getInfo("model"),1,2) == "iP" then --If apple product
		system.openURL( "") -- removed
	else
		system.openURL( "") -- removed
	end
end

local function getRatingSetting()
	return saves.ratingSetting
end

local function getNumberOfUpgrades()
	local selections = saves.upgradeSelections
	local num = (selections[1] + selections[2] + selections[3]) - 3 -- The default selection is 1 for each.

	return num
end

local function getRatingPromptCounter()
	return saves.ratingPromptCounter
end 

local function onRatingSelection(e)
	if e.action == "clicked" then
		local i = e.index

		if (i == 1) then
			local prompt = "Would you mind rating eVubble?"
			local choices = {"Ok, sure", "No, thanks"}
			local onFeedbackSelection = function(e)
				if e.action == "clicked" then
					local i = e.index
					if (i == 1) then
						openAppInStore()
						awardStar()
					end
				end
			end

			timerStashRef[table.getn(timerStashRef) + 1] = timer.performWithDelay( DELAY, 
    			function()
        			native.showAlert("", prompt, choices, onFeedbackSelection)
   				end
			)

		elseif (i == 2) then
			local prompt = "Would you mind giving us some feedback?"
			local choices = {"Ok, sure", "No, thanks"}
			local onFeedbackSelection = function(e)
				if e.action == "clicked" then
					local i = e.index
					if (i == 1) then
						openNewEmail()
						awardStar()
					end
				end
			end

			timerStashRef[table.getn(timerStashRef) + 1] = timer.performWithDelay( DELAY, 
    			function()
        			native.showAlert("", prompt, choices, onFeedbackSelection)
   				end
			)
		end

		saves.ratingSetting = choices.no -- Don't ask again

		loadsave.saveData(saves)
	end
end

--[[
	Opens the initial rating prompt menu.
]]--
function ratingPrompt.promptForRating()
	timerStashRef[table.getn(timerStashRef) + 1] = timer.performWithDelay( DELAY, 
        function()
            native.showAlert("", ratingTitle, choiceArray, onRatingSelection)
        end
    )
end

--[[
	Determines whether or not the rating prompt button should be shown.
]]--
local function shouldPromptForRating()
	local shouldPrompt = false

	local ratingPromptCounter = getRatingPromptCounter()
	local NUMBER_OF_UPGRADES_TRIGGER = 5 -- Number of upgrades required for the rating prompt to be shown.
	local showDialog = (getNumberOfUpgrades() >= NUMBER_OF_UPGRADES_TRIGGER) and (ratingPromptCounter < 3)-- greater than because they may not have won on easy yet
	if (getRatingSetting() == choices.yes) and (showDialog == true)  then
		shouldPrompt = true
	end

	return shouldPrompt
end

--[[
	If should prompt for rating is true,
	returns the button to trigger the rating prompt system, complete with event listener, and increments the
	ratingPromptCounter so that the button is only shown for a few times.
	Otherwise nil is returned.
]]--
function ratingPrompt.newRatingPromptButton(timerStash)
	timerStashRef = timerStash

	if	shouldPromptForRating() == true then
		local plus1 = display.newImage("images/plus1.png", 0, 0)
	    plus1.xScale = .65
	    plus1.yScale = plus1.xScale
	    plus1.x = W * .90 
	    plus1.y = H * .10
	    plus1.alpha = .40

	    --Increment and save ratingPromptCounter
		saves.ratingPromptCounter = saves.ratingPromptCounter + 1
		loadsave.saveData(saves)

	    return plus1
	else
		-- We don't want the to ask the user for a rating at the moment.
		return nil
	end
end

return ratingPrompt