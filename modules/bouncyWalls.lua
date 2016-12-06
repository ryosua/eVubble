local bouncyWalls = {}

function bouncyWalls.new()
    local this = display.newGroup()

    local WALL_THICKNESS = W * .05
    local offset = WALL_THICKNESS * 2

    local leftWall = display.newRect(0 - offset, 0, WALL_THICKNESS, H)
    leftWall.wall = true
    leftWall:setFillColor(0, 0, 0)
    leftWall.anchorX = 0
    leftWall.anchorY = 0
    physics.addBody( leftWall, "static", { density = 1.0, friction = 0, bounce = 1} )
    leftWall.isSleepingAllowed = false
    this:insert(leftWall)

    local rightWall = display.newRect(W + .5 * offset, 0, WALL_THICKNESS, H)
    rightWall.wall = true
    rightWall:setFillColor(0, 0, 0)
    rightWall.anchorX = 0
    rightWall.anchorY = 0
    physics.addBody( rightWall, "static", { density = 1.0, friction = 0, bounce = 1} )
    rightWall.isSleepingAllowed = false
    this:insert(rightWall)

    local topWall = display.newRect(0, 0 - offset, W, WALL_THICKNESS)
    topWall.wall = true
    topWall:setFillColor(0, 0, 0)
    topWall.anchorX = 0
    topWall.anchorY = 0
    physics.addBody( topWall, "static", { density = 1.0, friction = 0, bounce = 1} )
    topWall.isSleepingAllowed = false
    this:insert(topWall)

    local bottomWall = display.newRect(0, H + .5 * offset, W, WALL_THICKNESS)
    bottomWall.wall = true
    bottomWall:setFillColor(0, 0, 0)
    bottomWall.anchorX = 0
    bottomWall.anchorY = 0
    physics.addBody( bottomWall, "static", { density = 1.0, friction = 0, bounce = 1} )
    bottomWall.isSleepingAllowed = false
    this:insert(bottomWall)

    function this.update(player)
        leftWall.x = 0 - WALL_THICKNESS - player.contentWidth * .5
        rightWall.x = W + .5 * player.contentWidth
        topWall.y = 0 - WALL_THICKNESS - player.contentWidth * .5
        bottomWall.y = H + .5 * player.contentWidth
    end

    return this
end

return bouncyWalls