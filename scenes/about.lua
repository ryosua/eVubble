-- Modules
local composer = require "composer"
local musicAndSound = require "modules.musicAndSound"
local ratingPrompt = require "modules.ratingPrompt"
local UI = require "modules.UI"

local font = native.systemFont
local fontSize = 20 

local function onFacebookTap()
    musicAndSound.playSound("pop")
    system.openURL( "" ) -- removed
end

local function onTwitterTap()
    musicAndSound.playSound("pop")
    system.openURL( "" ) -- removed
end

local function onSiteTap()
    musicAndSound.playSound("pop")
    system.openURL( "" ) -- removed
end

local function onRateTap()
    musicAndSound.playSound("pop")
    if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) or string.sub(system.getInfo("model"),1,2) == "iP" then --If apple product
        system.openURL( "") -- removed
    else
        system.openURL( "") -- removed -- If Android
    end
end

local function onAppsTap()
    musicAndSound.playSound("pop")
    if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) or string.sub(system.getInfo("model"),1,2) == "iP" then --If apple product
        system.openURL( "") -- removed
    else
        system.openURL( "") -- removed -- If Android
    end
end

local function onContactTap()
    musicAndSound.playSound("pop")
    local options =
    {
        to = "", -- removed
        subject = "eVubble Feedback",
        body = "",
    }

    native.showPopup("mail", options)
end

local apps
local contact
local fb
local hideIcons
local megaphone
local rate
local showShoutOut
local shoutOut
local site
local twitter
local ytree

local scene = composer.newScene()
function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "scenes.menu"
    
    local yPressed = false
    local megaphonePressed = false

    local background = display.newImage ("images/aboutBackground.png", 0, 0 )
    background.x = W / 2
    background.y = H / 2
    
    local homeBtn = UI.newHomeButton("light", true)

    local SPACING = 30
    local ICON_HEIGHT = H * .60
    local ICON_SCALE = .75
    local BTN_SPACING = H * .15
    local BTN_SPACING = H * .125
    local BTN_X = W*.55
    
    local ytreeText = display.newImage ("images/yosuatreegamesLLC.png", 0, 0 )
    ytreeText.x = W * .50
    ytreeText.y = H * .10
    ytreeText.xScale = ICON_SCALE
    ytreeText.yScale = ICON_SCALE
    ytreeText.anchorX = .5
    ytreeText.anchorY = 0
    
    ytree = display.newImage ("images/yBtn.png", 0, 0 )
    ytree.x = W * .20
    ytree.y = ICON_HEIGHT
    ytree.xScale = ICON_SCALE
    ytree.yScale = ICON_SCALE
    
    fb = display.newImage ("images/fBtn.png", 0, 0 )
    fb.x = W * .40
    fb.y = ICON_HEIGHT
    fb.xScale = ICON_SCALE
    fb.yScale = ICON_SCALE
    fb:addEventListener( "tap", onFacebookTap )
    
    twitter = display.newImage ("images/tBtn.png", 0, 0 )
    twitter.x = W * .60
    twitter.y = ICON_HEIGHT
    twitter.xScale = ICON_SCALE
    twitter.yScale = ICON_SCALE
    twitter:addEventListener( "tap", onTwitterTap )
    
    megaphone = display.newImage ("images/megaphone.png", 0, 0 )
    megaphone.x = W * .80
    megaphone.y = ICON_HEIGHT
    megaphone.xScale = ICON_SCALE
    megaphone.yScale = ICON_SCALE
    
    apps = display.newImage ("images/apps.png", 0, 0 )
    apps.x = BTN_X
    apps.y = H * .40
    apps.xScale = ICON_SCALE
    apps.yScale = ICON_SCALE
    apps.alpha = 0
    apps:addEventListener( "tap", onAppsTap )

    rate = display.newImage ("images/rate.png", 0, 0 )
    rate.x = BTN_X
    rate.y = apps.y + BTN_SPACING
    rate.xScale = ICON_SCALE
    rate.yScale = ICON_SCALE
    rate.alpha = 0
    rate:addEventListener( "tap", onRateTap )

    site = display.newImage ("images/site.png", 0, 0 )
    site.x = BTN_X
    site.y = apps.y + (2*BTN_SPACING)
    site.xScale = ICON_SCALE
    site.yScale = ICON_SCALE
    site.alpha = 0
    site:addEventListener( "tap", onSiteTap )

    contact = display.newImage ("images/contact.png", 0, 0 )
    contact.x = BTN_X
    contact.y = apps.y + (3*BTN_SPACING)
    contact.xScale = ICON_SCALE
    contact.yScale = ICON_SCALE
    contact.alpha = 0
    contact:addEventListener( "tap", onContactTap )
   
    shoutOut = display.newText( "Sound credit - http://www.freesfx.co.uk", W * .05, H * .275, font, fontSize - 5 )
    shoutOut:setFillColor(1, 1, 1)
    shoutOut.anchorX = 0
    shoutOut.anchorY = 0.5
    shoutOut.alpha = 0

    local multilineTextHeight = .2 * H

    local multilineTextWidth = .6 * W

    local menuMusicTextOptions = 
    {
        text = 'Menu Music - "Cylinder Five" Chris Zabriskie Licensed under Creative Commons: By Attribution',
        x = W * .05,
        y = shoutOut.y + multilineTextHeight,
        font = font,
        fontSize = fontSize - 5,
        width = multilineTextWidth,
        height = multilineTextHeight,
    }

    local menuMusicText = display.newText( menuMusicTextOptions )
    menuMusicText:setFillColor(1, 1, 1)
    menuMusicText.anchorX = 0
    menuMusicText.anchorY = 0.5
    menuMusicText.alpha = 0

    local gameMusicOptions = 
    {
        text = 'Game Music - "Odyssey" Kevin MacLeod (incompetech.com) Licensed under Creative Commons: By Attribution',
        x = W * .05,
        y = menuMusicText.y + multilineTextHeight,
        font = font,
        fontSize = fontSize - 5,
        width = multilineTextWidth,
        height = multilineTextHeight,
    }

    local gameMusicText = display.newText( gameMusicOptions )
    gameMusicText:setFillColor(1, 1, 1)
    gameMusicText.anchorX = 0
    gameMusicText.anchorY = 0.5
    gameMusicText.alpha = 0
   
    function hideIcons()
        musicAndSound.playSound("pop")
        if yPressed == false then 
            yPressed = true
            fb.alpha = 0
            twitter.alpha = 0
            apps.alpha = 1
            rate.alpha = 1
            contact.alpha = 1
            site.alpha = 1
            megaphone.alpha = 0
            ytree.xScale = ICON_SCALE * 1.25
            ytree.yScale = ytree.xScale
        else 
            yPressed = false
            fb.alpha = 1
            twitter.alpha = 1
            apps.alpha = 0
            rate.alpha = 0
            contact.alpha = 0
            site.alpha = 0
            megaphone.alpha = 1
            ytree.xScale = ICON_SCALE
            ytree.yScale = ytree.xScale
        end
        return true
    end
    ytree:addEventListener( "tap", hideIcons )
    
    function showShoutOut()
       musicAndSound.playSound("pop")
        if megaphonePressed == false then 
            megaphonePressed = true
            fb.alpha = 0
            twitter.alpha = 0
            apps.alpha = 0
            rate.alpha = 0
            contact.alpha = 0
            site.alpha = 0
            ytree.alpha = 0
            shoutOut.alpha = 1
            menuMusicText.alpha = 1
            gameMusicText.alpha = 1
            megaphone.alpha = 1
            megaphone.xScale = ICON_SCALE * 1.25
            megaphone.yScale = megaphone.xScale
        else 
            megaphonePressed = false
            shoutOut.alpha = 0
            fb.alpha = 1
            twitter.alpha = 1
            apps.alpha = 0
            rate.alpha = 0
            contact.alpha = 0
            site.alpha = 0
            ytree.alpha = 1
            megaphone.alpha = 1
            menuMusicText.alpha = 0
            gameMusicText.alpha = 0
            megaphone.xScale = ICON_SCALE
            megaphone.yScale = ICON_SCALE
        end
        return true
    end
    megaphone:addEventListener("tap", showShoutOut)
        
    sceneGroup:insert( background )
    sceneGroup:insert( homeBtn )
    sceneGroup:insert( ytreeText )
    sceneGroup:insert( ytree )
    sceneGroup:insert( fb ) 
    sceneGroup:insert( apps )
    sceneGroup:insert( rate )
    sceneGroup:insert( contact )
    sceneGroup:insert( site )
    sceneGroup:insert( twitter )
    sceneGroup:insert( megaphone )
    sceneGroup:insert( shoutOut )
    sceneGroup:insert( menuMusicText )
    sceneGroup:insert( gameMusicText )
    -- Acheivement button will be nil for iOS.    
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        -- Play pop sound on scene load
        musicAndSound.playSound("pop")
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    -- Remove event listeners.
    fb:removeEventListener( "tap", onFacebookTap )
    twitter:removeEventListener( "tap", onTwitterTap )
    apps:removeEventListener( "tap", onAppsTap )
    rate:removeEventListener( "tap", onRateTap )
    site:removeEventListener( "tap", onSiteTap )
    contact:removeEventListener( "tap", onContactTap )
    ytree:removeEventListener( "tap", hideIcons )
    megaphone:removeEventListener("tap", showShoutOut)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene