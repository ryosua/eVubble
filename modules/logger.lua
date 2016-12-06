--[[
    A module that prints stuff when in debug mode, but does not print stuff when not in debug mode.
]]--

local logger = {}

function logger.new()
    local this = {}

    local debug = false

    function this.log(statement)
        if debug == true then
            print(statement)
        end
    end

    function this.isDebug()
        return debug
    end

    return this
end

return logger