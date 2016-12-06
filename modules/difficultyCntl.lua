--[[
    The controller for the level difficulty. 
]]--

local difficultyCntl = {}

-- The constant e.
local E = math.exp(1)

-- A variable that controls how slow the bubbles move across the screen. 
-- A large number means bubbles are spawned with less force.
local slowness = 100

-- How often bubbles are spawned in ms
local spawnRate = 2000

--[[
    Resets the difficulty. Call at the start of each new level.
]]--
function difficultyCntl.init()
    slowness = 100
    spawnRate = 2000
end

-- Getters
function difficultyCntl.getSlowness()
    return slowness
end
function difficultyCntl.getSpawnRate()
    return spawnRate
end

--[[
    Updates the difficulty settings based on the current sequenceNumber.
]]--
function difficultyCntl.updateDifficulty(sequenceNumber)
    -- Make enemies move faster
    slowness = 130.47 * math.pow(E, (-.063 * sequenceNumber) ) 

    -- Make enemies spawn faster
    spawnRate = 2306.3 * math.pow(E, (-.042 * sequenceNumber) )
end


-- Setters
function difficultyCntl.setSlowness(newValue)
    slowness = newValue
end

function difficultyCntl.setSpawnRate(newValue)
    spawnRate = newValue
end

return difficultyCntl