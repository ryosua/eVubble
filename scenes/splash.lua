-- Modules
local composer = require "composer"
local memoryManagement = require "modules.memoryManagement"

local function changeScene()  
    composer.gotoScene("scenes.menu")
    return true
end

local darkSplash
local splash

-- Memory management
local transitions = {}
local timers = {}

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = nil
    
    splash = display.newImage ("images/splash2B.png", 0, 0 )
    splash.x = W / 2
    splash.y = H / 2
    
    darkSplash = display.newImage ("images/fade.png", 0, 0 )
    darkSplash.x = W / 2
    darkSplash.y = H / 2
    darkSplash.alpha = 1
    
    sun = display.newImage ("images/splashSun.png", 0, 0 )
    sun.x = W / 2
    sun.y = H * 1.10
    sun.alpha = 1
    
    sky = display.newImage ("images/splashSky.png", 0, 0 )
    sky.x = W / 2
    sky.y = H / 2
    sky.alpha = 1
    
    splash:addEventListener ("tap", changeScene)

    sceneGroup:insert( sky )
    sceneGroup:insert( sun )
    sceneGroup:insert( splash )
    sceneGroup:insert( darkSplash )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        -- fade to black background from alpha 0 to alpha 1
        transitions[#transitions + 1] = transition.to( darkSplash, {transition=easing.inCirc, time=4250, alpha = 0} )
        transitions[#transitions + 1] = transition.to( sun, {transition=easing.inCubic, time=4250, y=H * .6} )
        
        -- change scene automatically with timer
        timers[#timers + 1] = timer.performWithDelay(5000, changeScene)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        memoryManagement.cancelAllTransitions(transitions)
        memoryManagement.cancelAllTimers(timers)
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    -- Remove event listeners.
    splash:removeEventListener("tap", changeScene)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene