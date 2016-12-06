--[[
    A module to control the score.

    init() method must be called at the beginning of each level to reset the level score.

    The player gets 1 point for each bubble correctly popped. They also get a bonus for a completed sequence that is
    equal to the sum of their time left + their current streak.

    Level score refers to the accumulated score that the player earns over the 
    entire level.

    Sequence bonus refers to the bonus score that the player earned for just one completed sequence.
]]--

-- Module variable
local scoreCntl = {}

-- Local variables
local levelScore = 0

--[[
    Initializes the module variables, must be called at the start of a new level to reset the initial state.
]]--
function scoreCntl.init()
    levelScore = 0
end

--[[
    Calculates the sequence bonus after a sequence is completed and before the next sequence is started.
]]--
function scoreCntl.calculateSequenceBonus(timeLeft, streak)
    local sequenceBonus = timeLeft + streak
    return sequenceBonus
end

-- Setters
function scoreCntl.setLevelScore(newScore)
    levelScore = math.floor(newScore)
end

-- Getters
function scoreCntl.getLevelScore()
    return levelScore
end

function scoreCntl.applyScorePowerUp()
    scoreCntl.setLevelScore(scoreCntl.getLevelScore() * 1.25)
end

return scoreCntl