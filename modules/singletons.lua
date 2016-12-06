--[[
    A module allowing accsess to the one instance allowed of any singleton module. The module's themselves do not enforce
    that only one instance can be instantiated, but rather through accessing the modules through this interface, only one
    instance of the selected class is needed. The instances are created the first time they are accessed, then live for 
    the life of the application session.
]]--

-- Modules
local adController = require "modules.adController"
local inAppPurchaseController = require "modules.inAppPurchaseController"
local logger = require "modules.logger"
local platform = require "modules.platform"

local singletons = {}

function singletons.new()
    local this = {}

    local adControllerI
    local inAppPurchaseControllerI
    local loggerI
    local platformI

    function this.getLoggerI()
        if loggerI == nil then
            loggerI = logger.new()
        end
        return loggerI
    end

    function this.getPlatformI()
        if platformI == nil then
            platformI = platform.new()
        end
        return platformI
    end

    -- Init ad controller(we want this done asap to begin caching the first ad)
    adControllerI = adController.new(this.getPlatformI())

    function this.getAdControllerI()
        return adControllerI
    end

    function this.getInAppPurchasesI()
        if inAppPurchaseControllerI == nil then
            inAppPurchaseControllerI = inAppPurchaseController.new(this.getPlatformI())
        end
        return inAppPurchaseControllerI
    end

    return this
end

return singletons