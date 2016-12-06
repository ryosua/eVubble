--[[
        Code is from a tutorial on Corona's website(with some modifications):
        http://coronalabs.com/blog/2013/03/26/androidizing-your-mobile-app/
]]--

-- Modules
local composer = require "composer"

local keyListener = {}

function keyListener.onKeyEvent(event)

    local phase = event.phase
    local keyName = event.keyName

    local currentScene = composer.getSceneName( "current" )

    if ( ("back" == keyName) and phase == "up" ) then
        if (  currentScene == "scenes.splash" ) then
            native.requestExit()
        else
            -- There is no simple way to hide the evolve overlays because there is an animation.
            -- For now, just hide the options overlay, and go back to "scenes.options" for evolve overlay.
            if ( composer.getSceneName( "overlay" ) == "scenes.optionsOverlay") then
                composer.hideOverlay()
            else
                local lastScene = composer.state.returnTo
                if ( lastScene ) then
                     composer.gotoScene( lastScene )
                else
                    -- Do nothing
                    --native.requestExit()
                end
            end
        end
    end

    if ( keyName == "volumeUp" and phase == "down" ) then
        local masterVolume = audio.getVolume()
        if ( masterVolume < 1.0 ) then
            masterVolume = masterVolume + 0.1
            audio.setVolume( masterVolume )
        end
        return true
    elseif ( keyName == "volumeDown" and phase == "down" ) then
        local masterVolume = audio.getVolume()
        if ( masterVolume > 0.0 ) then
            masterVolume = masterVolume - 0.1
            audio.setVolume( masterVolume )
        end
        return true
    end
    
    return true   -- Because behavior for the key is overrided.
end

return keyListener