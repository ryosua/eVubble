local adController = {}

-- Modules
local ads = require "ads"
local musicAndSound = require "modules.musicAndSound"
local platform = require "modules.platform"
local UI = require "modules.UI"

function adController.new(platformI)
    local this = {}

    local platformI = platformI

    local NUMBER_OF_PLAYS_BETWEEN_ADS = 3

    local function awardFreeStar()
        musicAndSound.playSound("starSound")
        saves.stars = saves.stars + 1
        saves.numberOfStarsWonByWatchingAds = saves.numberOfStarsWonByWatchingAds + 1
        loadsave.saveData(saves)
        native.showAlert( "Congrats!", "You have earned a free star!", { "OK" } )
    end

    --[[
    The number of ads they will have to watch to get a star will start at 1 then increase logarithmically 
    based on the number of ads they have watched.

    x - the number of stars won
    ]]--
    local function getNumberOfAdsThatFreeStarIsUnlockedAt()
        local maxAds = 100
        local starsWon = saves.numberOfStarsWonByWatchingAds

        local t = 
        {
            [1] = 1,
            [2] = 2,
            [3] = 5,
            [4] = 10,
            [5] = 20,
            [6] = 30,
            [7] = 50,
            [8] = 80,
            [9] = 90,
            [10] = maxAds,
        }

        local tableSize = #t
        local numberOfAds
        if starsWon >= tableSize then
            numberOfAds = maxAds
        else
            numberOfAds = t[starsWon + 1]
        end

        return numberOfAds
    end

    local function getNumberOfAdsLeftUntilFreeStar()
        local number = getNumberOfAdsThatFreeStarIsUnlockedAt() - saves.adsWatchedTowardsFreeStar
        return number
    end

    local adOptInDialog, yesBtn, noButton 

    local function hide()
        adOptInDialog.alpha = 0
        return true
    end

    local function vungleAdListener(e)
        if ( e.type == "adStart" and e.isError ) then
            -- Ad has not finished caching and will not play
        elseif ( e.type == "adStart" and not e.isError ) then
            -- Ad will play
        elseif ( e.type == "cachedAdAvailable" ) then
            -- Ad has finished caching and is ready to play
        elseif ( e.type == "adView" ) then
            -- An ad has completed
            
            saves.adsWatchedTowardsFreeStar = saves.adsWatchedTowardsFreeStar + 1

            if getNumberOfAdsLeftUntilFreeStar() == 0 then
                saves.adsWatchedTowardsFreeStar = 0
                awardFreeStar()
            end
            loadsave.saveData(saves)
        elseif ( e.type == "adEnd" ) then
            -- The ad experience has been closed- this
            -- is a good place to resume your app
            hide()
        end
    end

    local adsSupported = false
    local appID
    local function init()
        if platformI.getPlatform() == platform.GOOGLE_PLAY then
            appID = "" -- removed
            adsSupported = true
        elseif platformI.getPlatform() == platform.IOS then
            appID = "" -- removed
            adsSupported = true
        end

        -- Do this as early as possible in your app
        -- An ad will begin caching on init and it can take
        -- up to 30 seconds before it is ready to play
        ads.init( "vungle", appID, vungleAdListener )
    end
    init()

    local function showAd()
        ads.show( "incentivized" )
        return true
    end

    --[[
        Returns a button or nil if an ad is not available.
    ]]--
    function this.loadAdButton(displayGroup, transitions)
        local button

        -- DEBUG always show ad
        local thereIsAnAd = (ads.isAdAvailable() == true) and (adsSupported == true)
        local dueToPlayAnAd = saves.numberOfPlays % NUMBER_OF_PLAYS_BETWEEN_ADS == 0

        if thereIsAnAd == true and dueToPlayAnAd == true then
            button = display.newImage("images/adStar.png", 0, 0)
            button.x = W * .2
            button.y = H * .2
            button.alpha = .40

            transitions.adPulseTransition = transition.blink( button, { time = 2000 } )

            local dialogText = "Watch an ad to earn stars? (".. getNumberOfAdsLeftUntilFreeStar() .. " more left for a free star)"
            adOptInDialog, yesBtn, noButton = UI.newWarningDialog(dialogText)

            yesBtn:addEventListener( "tap", showAd )
            noButton:addEventListener( "tap", hide )

            local function onShowAdButtonTap()
                button.alpha = 0
                transition.cancel(transitions.adPulseTransition)
                adOptInDialog.alpha = 1
                return true
            end

            button:addEventListener( "tap", onShowAdButtonTap)
            displayGroup:insert(button)
            displayGroup:insert(adOptInDialog)
        else
            button = nil
        end

        return button
    end

    return this
end

return adController