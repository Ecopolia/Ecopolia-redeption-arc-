-- Local NPC test table
local npc_test = {}

-- Function to set up the rendering pipeline
local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    -- Add the video drawing stage without a shader
    pipeline:addStage(nil, function()
        love.graphics.clear(0, 0, 0)  -- Clear the screen with a black background
    end)

    -- Add the PXL shader stage
    pipeline:addStage(G.SHADERS['PXL'], function()
        uiManager:draw("npc_test")
    end)

    return pipeline
end

function npc_test:load(args)
    ManualtransitionIn()

    -- Load the NPC data
    local spritesheet = love.graphics.newImage("assets/spritesheets/placeholder_npc.png")
    local grid = anim8.newGrid(24, 24, spritesheet:getWidth(), spritesheet:getHeight())

    self.npcs = {}
    local npcCount = 5  -- Number of NPCs to spawn
    local radius = 100  -- NPC movement radius
    local clickableRadius = 50  -- Clickable area around the NPC

    -- Create multiple NPCs
    for i = 1, npcCount do
        local npc = {
            tag = 'npc_' .. i,
            images = {
                spritesheet = spritesheet
            },
            animations = {
                idle = anim8.newAnimation(grid('1-2', 1), 0.2),  -- Idle animation
                walk = anim8.newAnimation(grid('1-4', 2), 0.2)   -- Walk animation
            },
            center = {x = love.math.random(200, G.WINDOW.WIDTH - 200), y = love.math.random(200, G.WINDOW.HEIGHT - 200)},  -- Fixed center position for the radius
            position = {x = 0, y = 0},  -- Current position (to be updated within the radius)
            scale = 2,  -- Scale up the sprite
            radius = radius,  -- Fixed radius for movement
            clickableRadius = clickableRadius,  -- Radius for clickable area
            speed = 60,  -- Movement speed in pixels per second
            direction = 1,  -- 1 for right, -1 for left
            target = nil,  -- Target position for random movement
            moving = true,  -- Flag to track if the NPC is moving (for switching animations)
            clicked = false, -- Tracks if the NPC was clicked (used to prevent repeated clicks)
            hover = false,   -- Track if the mouse is hovering over the clickable zone
            color = {love.math.random(), love.math.random(), love.math.random(), 1}  -- Random color (RGBA)
        }

        -- Set the initial position randomly within the radius around the center
        self:setInitialPosition(npc)
        self:setRandomTarget(npc)  -- Set a random target position within the fixed radius
        table.insert(self.npcs, npc)
    end

    self.pipeline = setupPipeline()
    self.timer = Timer.new()  -- Initialize the HUMP timer
end

-- Function to set an initial position for the NPC within the defined radius
function npc_test:setInitialPosition(npc)
    local angle = love.math.random() * (2 * math.pi)  -- Random angle between 0 and 2π
    local r = love.math.random(0, npc.radius)           -- Random distance within the radius

    npc.position.x = npc.center.x + math.cos(angle) * r
    npc.position.y = npc.center.y + math.sin(angle) * r
end

-- Function to set a random target within the defined radius for the NPC
function npc_test:setRandomTarget(npc)
    local angle = love.math.random() * (2 * math.pi)  -- Random angle between 0 and 2π
    local r = love.math.random(0, npc.radius)           -- Random distance within the radius

    npc.target = {
        x = npc.center.x + math.cos(angle) * r,
        y = npc.center.y + math.sin(angle) * r
    }
end

-- Function to handle the NPC's idle state after being clicked
function npc_test:onClick(npc)
    print("npc clicked")
end

function npc_test:update(dt)
    -- Update the HUMP timer
    self.timer:update(dt)

    -- Update NPC animations and handle movement
    for _, npc in ipairs(self.npcs) do
        -- If the NPC is moving, move toward the target
        if npc.moving and npc.target then
            local dx = npc.target.x - npc.position.x
            local dy = npc.target.y - npc.position.y
            local distance = math.sqrt(dx * dx + dy * dy)

            -- If the NPC has reached the target, set a new random target within the fixed radius
            if distance < 2 then
                self:setRandomTarget(npc)
            else
                -- Normalize the direction and move toward the target
                local dirX = dx / distance
                local dirY = dy / distance

                npc.position.x = npc.position.x + dirX * npc.speed * dt
                npc.position.y = npc.position.y + dirY * npc.speed * dt

                -- Update the direction for sprite flipping (moving left or right)
                npc.direction = dirX >= 0 and 1 or -1

                -- Update the walk animation
                npc.animations.walk:update(dt)
            end
        else
            -- If not moving, update idle animation
            npc.animations.idle:update(dt)
        end

        -- Check if the mouse is hovering over the clickable zone
        npc.hover = self:isInClickableZone(npc, love.mouse.getX(), love.mouse.getY())
    end

    -- Update the UI (if needed)
    uiManager:update("npc_test", dt)
end

function npc_test:draw()
    if self.pipeline then
        self.pipeline:run()  -- Run the pipeline
    end

    -- Draw NPCs, their radius areas, and their clickable zones
    for _, npc in ipairs(self.npcs) do
        -- Draw the radius area as a circle
        love.graphics.setColor(1, 1, 1, 0.1)  -- Set color with transparency
        love.graphics.circle("line", npc.center.x, npc.center.y, npc.radius)

        -- Draw the clickable zone as a filled circle if the mouse is hovering, else draw it as a line
        if npc.hover then
            love.graphics.setColor(0, 1, 0, 0.3)  -- Set a semi-transparent green color for the clickable zone
            love.graphics.circle("fill", npc.position.x, npc.position.y, npc.clickableRadius)  -- Filled circle when hovered
        else
            love.graphics.setColor(0, 1, 0, 0.1)  -- Set a more transparent color for the non-hover state
            love.graphics.circle("line", npc.position.x, npc.position.y, npc.clickableRadius)  -- Outline when not hovered
        end

        -- Apply the random color filter
        love.graphics.setColor(npc.color)

        -- Select the appropriate animation
        local anim = npc.moving and npc.animations.walk or npc.animations.idle

        -- Flip the sprite if moving left (direction is -1), otherwise keep normal scale
        local scaleX = npc.scale * npc.direction

        -- Draw the current animation frame, adjusting position to center the sprite
        anim:draw(npc.images.spritesheet, npc.position.x, npc.position.y, 0, scaleX, npc.scale, 12, 12)  -- Offset by 12,12 (half of 24x24) to center

        -- Reset the color
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Detect if the mouse click is within the NPC's bounding box
function npc_test:isClicked(npc, x, y)
    local width, height = 24 * npc.scale, 24 * npc.scale  -- Scaled width and height of the sprite
    return x >= npc.position.x - 12 and x <= npc.position.x + width - 12
        and y >= npc.position.y - 12 and y <= npc.position.y + height - 12
end

-- Detect if the mouse click is within the clickable zone
function npc_test:isInClickableZone(npc, x, y)
    local dx = x - npc.position.x
    local dy = y - npc.position.y
    return (dx * dx + dy * dy) <= (npc.clickableRadius * npc.clickableRadius)  -- Check if the click is within the clickable radius
end

function npc_test:mousepressed(x, y, button)
    if button == 1 then  -- Only handle left mouse button clicks
        for _, npc in ipairs(self.npcs) do
            if not npc.clicked and self:isInClickableZone(npc, x, y) then
                npc.clicked = true  -- Prevent multiple clicks
                self:onClick(npc)  -- Trigger the onClick event
            end
        end
    end
end

function npc_test:keypressed(key)
    -- Handle key press events if necessary
end

return npc_test
