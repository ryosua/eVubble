--[[
    A module used to determine what platform a device is on.
]]--

local platform = {}

platform.IOS = 1
platform.GOOGLE_PLAY = 2
platform.MAC_OS_X = 3

function platform.new()
    local this = {}

    --[[
        Returns the name of the platform.
    ]]--
    function this.getPlatformName()
        return system.getInfo("platformName")
    end

    local currentPlatform
    if this.getPlatformName() == "Android" then
        currentPlatform = platform.GOOGLE_PLAY
    elseif this.getPlatformName() == "Mac OS X" then
        currentPlatform = platform.MAC_OS_X
    else
        currentPlatform = platform.IOS
    end

    --[[
        Returns the platform type. Use this function for completing different operations on different platforms.
    ]]--
    function this.getPlatform()
        return currentPlatform
    end

    return this
end

return platform