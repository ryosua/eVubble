--[[
	The controller for bubble objects. 
]]--

local bubbleCntl = {}

-- Modules
local bubbleQueue = require "modules.bubbleQueue"
local difficultyCntl = require "modules.difficultyCntl"
local memoryManagement = require "modules.memoryManagement"
local powerUpType = require "modules.powerUpType"
local imageSheet = require "modules.imageSheet"

function bubbleCntl.thePlayerShouldHaveATail(selections)
    local shouldHaveATail = true

    if selections[1] < 4 or selections[2] < 4 or selections[3] < 4 then
        shouldHaveATail = false
    end

    return shouldHaveATail
end

function bubbleCntl.new(playerHasATail, sceneGroup, transitions)
    local this = {}

    -- Constants
    local INITIAL_PLAYER_SIZE = 25

    -- Private variables.
    local spawnTable = {} --used to hold all enemies

    -- References
    local playerHasATailI = playerHasATail
    local sceneGroupI = sceneGroup
    local transitionsI = transitions

    -- Initialize the pseudo random number generator with os time
    math.randomseed( os.time() )

    -- Pop off some random numbers for good measure (Not sure if this does anything, but Lua Doc. says to so...)
    math.random(); math.random(); math.random()

    -- Amount of growth in radius size.
    local increaseSize = saves.playerData.growth

    -- Percent of time an upgrade is spawned.
    local percentUprade = saves.playerData.luck

    local function cleanParticles(particles)
        for i = 1, #particles do
            display.remove( particles[i] )
            particles[i] = nil
        end
        particles = nil
    end

    function this.getInitialPlayerSize()
        return INITIAL_PLAYER_SIZE
    end

    function this.getSpawnTable()
        return spawnTable
    end

    function this.enemyPop(bubble, particles, spread)
        local NUMBER_OF_PARTICLES = particles

        local particleTable = {}
        
        for i = 1, NUMBER_OF_PARTICLES do
            local size = math.random(10,20)

            local particle = display.newCircle(bubble.x, bubble.y,size)
            particle.xScale = 1
            particle.alpha = 0
            particle.yScale = particle.xScale
            sceneGroupI:insert(3 , particle)
            particleTable[#particleTable + 1] = particle
            
            local scale = math.random(1,25)/1000
            local spread = spread
            local rotation = 360
            local time = 5000
            local alpha = 1

            local function onComplete()
                cleanParticles(particleTable)
            end

            local function isCompleted()
                if #particleTable == 0 then
                    return true
                else
                    return false
                end
            end

            transitionsI[table.getn(transitionsI) + 1] = transition.to( particle, { transition = easing.outSine, time=time, x=(particle.x + math.random(-spread,spread)), y=(particle.y + math.random(-spread,spread)),
                                            rotation = math.random(-rotation,rotation), xScale= scale, yScale = scale, onComplete = onComplete } )
            transitionsI[table.getn(transitionsI)].isCompleted = isCompleted

            transitionsI[table.getn(transitionsI) + 1] = transition.to( particle, { time=1000, alpha=.50} )
            transitionsI[table.getn(transitionsI)].isCompleted = isCompleted
            
            --blue
            if bubble.colorIndex == 1 then
                particle:setFillColor( (math.random(0,50)/255), (math.random(0,100)/255), (math.random(100,200)/255) )
            --red
            elseif bubble.colorIndex == 2 then
                particle:setFillColor( (math.random(100,255)/255), (math.random(30,50)/255), (math.random(0,70)/255) )
            --green, but for some reason it changes to 7.
            elseif bubble.colorIndex == 3 then
                particle:setFillColor( (math.random(0,70)/255), (math.random(80,200)/255), (math.random(0,90)/255) )
            --orange
            elseif bubble.colorIndex == 4 then
                particle:setFillColor( (math.random(150,250)/255), (math.random(100,130)/255), (math.random(0,80)/255) )
            --yellow
            elseif bubble.colorIndex == 5 then
                particle:setFillColor( (math.random(200,250)/255), (math.random(175,250)/255), (math.random(0,60)/255) )
            --purple
            elseif bubble.colorIndex == 6 then
                particle:setFillColor( (math.random(75,215)/255), (math.random(0,75)/255), (math.random(150,200)/255) )
            -- Suprise green!
            elseif bubble.colorIndex == 7 then
                particle:setFillColor( (math.random(0,70)/255), (math.random(80,200)/255), (math.random(0,90)/255) )
            end
        end
    end

    function this.powerUpTrail(bubble, particles, spread)
        local NUMBER_OF_PARTICLES = particles

        local particleTable = {}
        
        for i = 1, NUMBER_OF_PARTICLES do
            local size = math.random(3,7)

            local particle = display.newCircle(bubble.x, bubble.y,size)
            particle.xScale = 1
            particle.alpha = 0
            particle.yScale = particle.xScale
            sceneGroupI:insert(3 , particle)
            particleTable[#particleTable + 1] = particle
            
            local scale = math.random(1,25)/1000
            local spread = spread
            local rotation = 360
            local time = 5000
            local alpha = 1

            local function onComplete()
                cleanParticles(particleTable)
            end

            local function isCompleted()
                if #particleTable == 0 then
                    return true
                else
                    return false
                end
            end

            transitionsI[table.getn(transitionsI) + 1] = transition.to( particle, { transition = easing.outSine, time=time, x=(particle.x + math.random(-spread,spread)), y=(particle.y + math.random(-spread,spread)),
                                            rotation = math.random(-rotation,rotation), xScale= scale, yScale = scale, onComplete = onComplete } )
            transitionsI[table.getn(transitionsI)].isCompleted = isCompleted

            transitionsI[table.getn(transitionsI) + 1] = transition.to( particle, { time=1000, alpha=.50} )
            transitionsI[table.getn(transitionsI)].isCompleted = isCompleted

            -- This allows us to call the cleanParticle function after the timer is canceled on powerups.
            bubble.onComplete = onComplete

            --blue
            if bubble.colorIndex == 1 then
                particle:setFillColor( (math.random(0,50)/255), (math.random(0,100)/255), (math.random(100,200)/255) )
                --
            --red
            elseif bubble.colorIndex == 2 then
                particle:setFillColor( (math.random(100,255)/255), (math.random(30,50)/255), (math.random(0,70)/255) )
            --green
            elseif bubble.colorIndex == 3 then
                particle:setFillColor( (math.random(0,70)/255), (math.random(80,200)/255), (math.random(0,90)/255) )
            --orange
            elseif bubble.colorIndex == 4 then
                particle:setFillColor( (math.random(150,250)/255), (math.random(100,130)/255), (math.random(0,80)/255) )
            --yellow
            elseif bubble.colorIndex == 5 then
                particle:setFillColor( (math.random(200,250)/255), (math.random(175,250)/255), (math.random(0,60)/255) )
            --purple
            elseif bubble.colorIndex == 6 then
                particle:setFillColor( (math.random(75,215)/255), (math.random(0,75)/255), (math.random(150,200)/255) )
            elseif bubble.colorIndex == nil then
                --player bubble
                particle:setFillColor( (math.random(0,255)/255), (math.random(0,255)/255), (math.random(0,255)/255) )
            end 
        end
    end

    function this.deathPop(player, dieTransitions, bleedGroup)
        local particles = 250

        for i=1, particles do
        
            local size = math.random(25,30)
            
            local particle = display.newCircle (player.x, player.y,size)
            particle.xScale = 1
            particle.alpha = .15
            particle.yScale = particle.xScale
            bleedGroup:insert(particle)
            
            local scale = .001
            local spread = 1250
            local rotation = 360
            local time = 1000
            local alpha = 1
            
            dieTransitions[table.getn(dieTransitions) + 1] = transition.to( particle, { transition = easing.outSine, time=time, x=(particle.x + math.random(-math.random(spread - 500, spread+500),math.random(spread - 500, spread+500))), y=(particle.y + math.random(-math.random(spread - 500, spread+500),math.random(spread - 500, spread+500))),
                                            rotation = math.random(-rotation,rotation), xScale= scale, yScale = scale } )

            dieTransitions[table.getn(dieTransitions) + 1] = transition.to( particle, { time=1000, alpha=1} )
            
            --blue
            if (i % 6) == 0 then
                particle:setFillColor ( (math.random(10,40)/255), (math.random(10,90)/255), (math.random(110,190)/255) )
            --red
            elseif (i % 6) == 1 then
                particle:setFillColor ( (math.random(110,245)/255), (math.random(35,45)/255), (math.random(10,60)/255) )
            --green
            elseif (i % 6) == 2 then
                particle:setFillColor ( (math.random(10,60)/255), (math.random(90,190)/255), (math.random(10,80)/255) )
            --orange
            elseif (i % 6) == 3 then
                particle:setFillColor ( (math.random(160,240)/255), (math.random(105,125)/255), (math.random(10,70)/255) )
            --yellow
            elseif (i % 6) == 4 then
                particle:setFillColor ( (math.random(210,240)/255), (math.random(185,240)/255), (math.random(10,50)/255) )
            --purple
            else 
                particle:setFillColor ( (math.random(85,205)/255), (math.random(10,65)/255), (math.random(160,190)/255) )
            end
        end
    end

    function this.moveObject(object)
        local magx = math.random(20, 50) --magnitude, randomly generated
        local magy = math.random(20, 50) --magnitude, randomly generated
        
        local forceX = ((magx * object.xdir) * object.size ^ 1.5) / difficultyCntl.getSlowness()
        local forceY = ((magy *  object.ydir) * object.size ^ 1.5) / difficultyCntl.getSlowness()
        object:applyForce( forceX, forceY, object.x, object.y)
        --The forces are made from a random magnitude, a scale factor, and a direction(for both the x and y components)
        --To slow the objects down divide by a bigger number 
    end

    --[[ 
        Takes an object, returns true if it is onscreen and false if it is not.
    ]]--
    function this.onScreen(object)
        if (object.x > (W + .5 * object.contentWidth)) or (object.x < (0 - .5 * object.contentWidth)) or (object.y > (H + .5 * object.contentHeight)) or (object.y < (0 - .5 * object.contentHeight)) then
            return false
        else
            return true
        end
    end

    function this.tag(object)
        if this.onScreen(object) and object.onScreenb == false  then
            object.onScreenb = true
        end
        if (object.onScreenb == true) and (this.onScreen(object) == false) then
            object.tag = true
        end
    end 

    --[[
        Determines the objects direction based on where it is spawned.

        direction = {x, y}
    ]]--
    local function getDirection(xPosition, yPosition)
        local direction = {}
        direction.x = 1
        direction.y = 1

        --1. Left Side
        if (xPosition < W) and (yPosition < H) then
            direction.x = 1
            if (math.random(0, 1) == 1) then
                direction.y = 1
            else
                direction.y = -1
            end
        end
        
        --2. Bottom
        if (xPosition < W) and (yPosition > H) then
            direction.y = -1
            if (math.random(0, 1) == 1) then
                direction.x = 1
            else
                direction.x = -1
            end
        end
            
        --3. Right
        if (xPosition > W) and (yPosition < H) then
            direction.x = -1
            if (math.random(0, 1) == 1) then
                direction.y = 1
            else
                direction.y = -1
            end
        end
        
        --4. Top
        if ((xPosition < W) and (xPosition > 0))  and (yPosition < H) then
            direction.y = 1
            if (math.random(0, 1) == 1) then
                direction.x = 1
            else
                direction.x = -1
            end
        end

        return direction
    end

    --[[
        Returns the data spawn conditions for the enemy or the powerup.

        data = { size, xPosition, yPosition, xDirection, yDirection, colorIndex, isPowerUp}
    ]]--
    local function generateSpawnData()
        local data = {}

        -- Set the object size randomly.
        data.size = math.random(18, 22)

        -- Set the x and y position to around the corners of the screen, just a bubble's width outside view.
        data.xPosition = .5 * W
        data.yPosition = .5 * H
        if (math.random(0, 1) == 0) then
            data.xPosition = math.random(0, W)
            if (math.random(0, 1) == 0) then
                data.yPosition = 0 - data.size
            else
                data.yPosition = H + data.size
            end
        else
            if (math.random(0, 1) == 0) then
                data.xPosition = 0 - data.size
            else
                data.xPosition = W + data.size
                data.yPosition = math.random(0, H)
            end
        end

        -- Set the directions.
        local directions = getDirection(data.xPosition, data.yPosition)
        data.xDirection = directions.x
        data.yDirection = directions.y

        -- Set the color index.
        data.colorIndex = bubbleQueue.getRandomColor()

        -- Set where or not to spawn a powerup.
        data.isPowerUp = false
        if (math.random(1, 100) <= percentUprade) then
            data.isPowerUp = true
        end

        return data
    end

    --[[ 
        Creates an enemy, adds it to the spawn table and display group, and sets its initial velocity.
    ]]--
    local function spawnEnemy()
        local object = {} --init

        local spawnData = generateSpawnData()

        local powerUp = powerUpType.colorIndexToPowerUpType[spawnData.colorIndex]

        -- The wildcard powerup spawns a rainbow bubble, all others the bubble corresponding to the color index.
        if spawnData.isPowerUp == true and powerUp == powerUpType.WILD_CARD_BUBBLE then
            object = display.newImage(imageSheet.enemyImageSheet, 7)
        elseif spawnData.isPowerUp == true then
            object = display.newImage(imageSheet.powerupImageSheet, spawnData.colorIndex)
        else
            object = display.newImage(imageSheet.enemyImageSheet, spawnData.colorIndex)
        end

        if spawnData.isPowerUp == true then
            local function spawnPowerUpTrail()
                this.powerUpTrail(object, 1, object.size * 3)
            end
            object.trailTimer = timer.performWithDelay(100, spawnPowerUpTrail, 0)
        end

        physics.addBody( object, { density = 1.0, friction = 0, bounce = 1, radius = spawnData.size} )

        object.colorIndex = spawnData.colorIndex
        object.xScale = spawnData.size / 240
        object.yScale = object.xScale
        object.anchorX = 0.5
        object.anchorY = 0.5
        object.x = spawnData.xPosition
        object.y = spawnData.yPosition
        object.isSensor = true
        object.xdir = spawnData.xDirection
        object.ydir = spawnData.yDirection
        object.size = spawnData.size

        -- Set the powerup type.
        if spawnData.isPowerUp == true then
            -- Set the powerup.
            object.powerUp = powerUp
        end
        
        -- The object is named the length of the table + 1 because the length of the table starts at zero.
        object.name = table.getn(this.getSpawnTable()) + 1

        -- Set tags - these are used to keep track of which enemies to delete.
        object.tag = false
        object.onScreenb = false

        -- Give enemies an initial velocity, because there is no friction on the enemies, they keep this velocity.
        this.moveObject(object)

        -- Length starts at 0, so we add one lua tables have a starting index of 1.
        this.getSpawnTable()[table.getn(this.getSpawnTable()) + 1] = object
        
        --Insert the new enemy just above the player in the group.
        sceneGroupI:insert (((sceneGroupI.numChildren - sceneGroupI.numChildren) + 3 ), this.getSpawnTable()[table.getn(this.getSpawnTable())])
    end

    --local i = 0

    --[[
        Calls spawnEnemy continuously.
    ]]--
    function this.spawnContinuous()
        local function spawnClosure()
            return spawnEnemy() 
        end
        return timer.performWithDelay(difficultyCntl.getSpawnRate(), spawnClosure, 0)
    end


    --[[ 
        Deletes a display object with a physics body properly.
    ]]--
    function this.deleteObject(object)
        --physics.removeBody(object)
        display.remove(object) 
        object = nil
        return object
    end

    --[[
        Gets the player image file from the saved frame table.
    ]]--
    local function getPlayerImage(frame)
        local file = frame[1]
        local index = frame[2]

        if (file == "playerGrid_1") then
            return display.newImage( imageSheet.playerGrid_1, index )

        elseif (file == "playerGrid_2") then
            return display.newImage( imageSheet.playerGrid_2, index )
        end
    end

    --[[
        Creates and returns player - a display image with a physics body.
    ]]--
    function this.newPlayer(size, x, y, xVelocity, yVelocity)
        local IMAGINARY_SCALE_FACTOR = size / 160

        -- The new player to return
        local new = getPlayerImage(saves.playerData.frame)
        new.size = size -- Size is a custom field, not one of a display object.
        new.anchorX = 0.5
        new.anchorY = 0.5
        new.xScale = IMAGINARY_SCALE_FACTOR
        new.yScale = IMAGINARY_SCALE_FACTOR
        new.x, new.y = x, y
        physics.addBody( new, { density = 1.0, friction = 0, bounce = 0, radius = new.size  } )
        new.linearDamping = 1 -- Simulates friction
        new:setLinearVelocity( xVelocity, yVelocity )
        if playerHasATailI == true then
            local function spawnPowerUpTrail()
                this.powerUpTrail(new, 1, new.size * 3)
            end
            new.trailTimer = timer.performWithDelay(100, spawnPowerUpTrail, 0)
        end

        -- New object is inserted into the local group just above dynamic background in eat function. 
        -- On level 1 this is done seperately.
        if sceneGroupI.numChildren >= 3 then
            sceneGroupI:insert(3, new)
        end

        return new
    end

    --[[ 
        This function is called every time the player collides with an object and grows bigger.
        It creates a new object with a biggers size, preserving the old object's velocity and then deletes the old object.

        Params:
        player - the player that ate the object

        Returns:
        new - the new player
     ]]--
    function this.eat(player)    
        -- Get the players velocity to transfer it to the new player.
        local xVelocity, yVelocity = player:getLinearVelocity()
        
        -- Create the new player to return.
        local new = this.newPlayer(player.size + increaseSize, player.x, player.y, xVelocity, yVelocity)
     
        -- Remove old player
        physics.removeBody( player )
        player:removeSelf()
        player = nil
        
        return new
    end


    local function getReducedSize(size)
        local REDUCTION_FACTOR = .75

        return size * REDUCTION_FACTOR
    end

    function this.applyReducePlayerSizePowerUp(player)
        if getReducedSize(player.size) >= this.getInitialPlayerSize() then
            -- Get the players velocity to transfer it to the new player.
            local xVelocity, yVelocity = player:getLinearVelocity()
            
            -- Create the new player to return.
            local new = this.newPlayer(getReducedSize(player.size), player.x, player.y, xVelocity, yVelocity)
            
            -- Remove old player
            physics.removeBody( player )
            player:removeSelf()
            player = nil
            
            return new
        else
            return player
        end    
    end

    --[[
        Sets the enemies slower, called for slowEnemies powerUp
    ]]--
    function this.slowEnemies(spawnTimerContainer)
        -- Get the difficulty settings.
        local slowness = difficultyCntl.getSlowness()
        local spawnRate = difficultyCntl.getSpawnRate()

        -- Adjust the difficulty settings.
        local SLOWNESS_FACTOR = 1.40 --log (1.66,)
        difficultyCntl.setSlowness( math.floor(slowness * SLOWNESS_FACTOR) )
        difficultyCntl.setSpawnRate( math.floor(spawnRate * SLOWNESS_FACTOR) )

        assert( spawnTimerContainer ~= nil )
        assert( spawnTimerContainer[1] ~= nil, "Problem with slow enemies timer." )
        memoryManagement.cancelTimer(spawnTimerContainer[1])
        spawnTimerContainer[1] = nil
        spawnTimerContainer[1] = this.spawnContinuous()
        
        -- slow all existing enemies
        for i = 1, (table.getn(this.getSpawnTable())) do
            if this.getSpawnTable()[i] ~= nil and this.getSpawnTable()[i].tag == false and this.getSpawnTable()[i].powerUp ~= nil then
                local xVelocity, yVelocity = this.getSpawnTable()[i]:getLinearVelocity()
            
                xVelocity, yVelocity = .5 * xVelocity, .5 * yVelocity
                this.getSpawnTable()[i]:setLinearVelocity( xVelocity, yVelocity )
            end
        end
    end

    --[[
        Nils references and variables just in case they are still reachable.
    ]]--
    function this.clean()
        -- Constants
        INITIAL_PLAYER_SIZE = nil

        -- Private variables.
        spawnTable = nil

        -- References
        playerHasATailI = nil
        sceneGroupI = nil
        transitionsI = nil
        increaseSize = nil
        percentUprade = nil

        -- Functions
        this.getInitialPlayerSize = nil
        this.getSpawnTable = nil
        this.enemyPop = nil
        this.powerUpTrail = nil
        this.deathPop = nil
        this.moveObject = nil
        this.onScreen = nil
        this.tag = nil
        getDirection = nil
        generateSpawnData = nil
        spawnEnemy = nil
        this.spawnContinuous = nil
        this.deleteObject = nil
        getPlayerImage = nil
        this.newPlayer = nil
        this.eat = nil
        getReducedSize = nil
        this.applyReducePlayerSizePowerUp = nil
        this.slowEnemies = nil

        -- Instance variable
        this = nil
    end

    return this
end

return bubbleCntl