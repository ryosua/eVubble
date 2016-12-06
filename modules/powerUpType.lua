--[[
    Defines constants for the powerups.
]]--

local powerUpType = {}

-- Enumerated powerup type.
powerUpType.TIMER_EXTENSION = 1
powerUpType.REDUCE_PLAYER_SIZE = 2
powerUpType.WILD_CARD_BUBBLE = 3
powerUpType.SCORE_POWERUP = 4
powerUpType.SLOW_ENEMIES = 5
powerUpType.CLEAR_QUEUE = 6

-- Colors represent the indexs on the image sheet.
local BLUE = 1
local RED = 2
local GREEN = 3
local ORANGE = 4
local YELLOW = 5
local PURPLE = 6

powerUpType.colorIndexToPowerUpType = {}
powerUpType.colorIndexToPowerUpType[BLUE] = powerUpType.TIMER_EXTENSION 
powerUpType.colorIndexToPowerUpType[RED] = powerUpType.REDUCE_PLAYER_SIZE
powerUpType.colorIndexToPowerUpType[GREEN] = powerUpType.WILD_CARD_BUBBLE
powerUpType.colorIndexToPowerUpType[ORANGE] = powerUpType.CLEAR_QUEUE 
powerUpType.colorIndexToPowerUpType[YELLOW] = powerUpType.SLOW_ENEMIES
powerUpType.colorIndexToPowerUpType[PURPLE] = powerUpType.SCORE_POWERUP

return powerUpType