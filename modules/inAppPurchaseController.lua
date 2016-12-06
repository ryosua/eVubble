local inAppPurchaseController = {}

-- Modules
local musicAndSound = require "modules.musicAndSound"
local platform = require "modules.platform"
local widget = require "widget"

function inAppPurchaseController.new(platformI)
    local this = {}

    local platformI = platformI

    local spinner

    -- ID's for referencing ID
    local ONE_STAR_INDEX = 1
    local THREE_STARS_INDEX = 2

    -- Variables initialized in initializeStore().
    local store
    local googleIAP = false
    local currentProductList = {}
    currentProductList[ONE_STAR_INDEX] = "" -- removed
    currentProductList[THREE_STARS_INDEX] = "" -- removed

    --[[
        iOS takes an array of products, Google Play takes a single product as a string.

        consume - When conuming a purchase you need to pass the table, even on Google Play
        stars - The number of stars for the purchase
    ]]--
    local function getStarPurchase(consume, stars)
        assert(stars == 1 or stars == 3, "Stars must be 1 or 3")

        local starPurchase = {}
        if platformI.getPlatform() == platform.GOOGLE_PLAY then
            -- store.consumePurchase takes a table, not a string.
            if consume == false or consume == nil then
                if stars == 1 then
                    starPurchase = currentProductList[ONE_STAR_INDEX]
                elseif stars == 3 then
                    starPurchase = currentProductList[THREE_STARS_INDEX]
                end
            else
                if stars == 1 then
                    starPurchase[1] = currentProductList[ONE_STAR_INDEX]
                elseif stars == 3 then
                    starPurchase[1] = currentProductList[THREE_STARS_INDEX]
                end
            end
        elseif platformI.getPlatform() == platform.IOS then
            if stars == 1 then
                starPurchase[1] = currentProductList[ONE_STAR_INDEX]
            elseif stars == 3 then
                starPurchase[1] = currentProductList[THREE_STARS_INDEX]
            end
        end
        return starPurchase
    end

    local function onOneStarPurchase()
        musicAndSound.playSound("starSound")
        saves.stars = saves.stars + 1
        loadsave.saveData(saves)
    end

    local function onTheeStarsPurchase()
        musicAndSound.playSound("starSound")
        saves.stars = saves.stars + 3
        loadsave.saveData(saves)
    end

    local function onOneStarRefund()
        if saves.stars > 0 then
            saves.stars = saves.stars - 1
            loadsave.saveData(saves)
        end
    end

    local function onThreeStarsRefund()
        if saves.stars > 0 then
            saves.stars = saves.stars - 3
            loadsave.saveData(saves)
        end
    end

    local function startTheSpinner()
        spinner:start()
        spinner.alpha = 1
    end

    local function stopTheSpinner()
        spinner:stop()
        spinner.alpha = 0
    end

    local function onStoreTransaction(e)
        local transaction = e.transaction

        if ( transaction.state == "purchased" ) then
            if transaction.productIdentifier == currentProductList[ONE_STAR_INDEX] then
                if platformI.getPlatform() == platform.GOOGLE_PLAY then
                    store.consumePurchase( getStarPurchase(true, 1), nil)
                end
                onOneStarPurchase()
            elseif transaction.productIdentifier == currentProductList[THREE_STARS_INDEX] then
                if platformI.getPlatform() == platform.GOOGLE_PLAY then
                    store.consumePurchase( getStarPurchase(true, 3), nil)
                end
                onTheeStarsPurchase()
            end

            stopTheSpinner()
            
        elseif ( transaction.state == "refunded" ) then
            -- Google play only.
            if transaction.productIdentifier == currentProductList[ONE_STAR_INDEX] then
                onOneStarRefund()
            elseif transaction.productIdentifier == currentProductList[THREE_STARS_INDEX] then
                onThreeStarsRefund()
            end
            stopTheSpinner()
        elseif ( transaction.state == "cancelled" ) then
            stopTheSpinner()
        elseif ( transaction.state == "failed" ) then
            stopTheSpinner()
        else
            stopTheSpinner()
        end

        --[[
            From Corona API:
            As noted above, you must call store.finishTransaction() on the transaction object when the transaction is complete.
            If you don't, the store will think that the transaction was interrupted and will attempt to resume it on the next application launch.
            If you're offering the item as downloadable content, do not call this until the download is complete.
        ]]--
        store.finishTransaction( transaction )
    end

    local function initializeStore()
        if platformI.getPlatform() == platform.GOOGLE_PLAY then
            store = require( "plugin.google.iap.v3" )
            googleIAP = true
            store.init( "google", onStoreTransaction )
        elseif platformI.getPlatform() == platform.IOS then
            store = require( "store" )
            store.init( "apple", onStoreTransaction )
        elseif platformI.getPlatform() == platform.MAC_OS_X then
            print "In-app purchases are not supported in the Corona Simulator."
        end
    end
    initializeStore()

    local function canMakePurchases()
        return store.canMakePurchases
    end

    function this.newSpinner()
        spinner = widget.newSpinner()
        spinner.alpha = 0
        return spinner
    end

    function this.purchaseOneStar()
        store.purchase( getStarPurchase(false, 1) )
        startTheSpinner()
    end

    function this.purchaseThreeStars()
        store.purchase( getStarPurchase(false, 3) )
        startTheSpinner()
    end

    return this
end

return inAppPurchaseController