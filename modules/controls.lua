local controls = {}

local touchingBackground -- Whether or not the player is touching the background
local touchX
local touchY

--[[
    Initialize the module variables, the first time the module is loaded.
]]--
local function onModuleLoad()
    touchingBackground = false
    touchX = 0
    touchY = 0
end
onModuleLoad()

--[[
    Resets the module variables so that the controls stop at the end of a level.
]]--
function controls.resetControls()
    touchingBackground = false
    touchX = 0
    touchY = 0
end

-- Setters
function controls.setTouchingBackground(bool)
    touchingBackground = bool
end

function controls.setTouchY(y)
    touchY = y
end

function controls.setTouchX(x)
    touchX = x
end

--[[ 
    Applies a force to the player while a button is pushed. The direction of the force corresponds to
    the button that was pressed. See buttonPressed function. Use in the runtime function.
]]--
function controls.movePlayer(player, sensitivity)    
    local speed = player.size ^ 1.5 
    speed = ( (player.size ^ 1.5) * (.0030 + (sensitivity * .00006)) )
    --creates a range of .0030 - .0090

    -- Apply forces to the player when they are touching the background.
    if (touchingBackground == true) then
        local xForce = (touchX - player.x) * speed
        local yForce = (touchY - player.y) * speed
        player:applyForce(xForce, yForce, player.x, player.y)
    end

end

--[[ 
    Takes an object as a parameter and returns the object's x and y positions. If the
    object goes off-screen it will wrap back on the opposite edge. To use assign the objects .x and .y to the function.
    Call inside the runtime function.
]]--
function controls.wrapEffect(object) 
    if object.x > (W + .5 * object.contentWidth) then
        object.x = 0 - .5 * object.contentWidth
    end
    if object.x < (0 - .5 * object.contentWidth) then
        object.x = .5 * object.contentWidth + W
    end
    if object.y > (H + .5 * object.contentHeight) then
        object.y = 0 - .5 * object.contentHeight
    end
    if object.y < (0 - .5 * object.contentHeight) then
        object.y = H + .5 * object.contentHeight
    end
    
    return object.x , object. y 
end

return controls