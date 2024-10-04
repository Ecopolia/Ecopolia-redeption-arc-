local npc_test = {}
-- Global NPC table for the scene
npcs = {}

-- Initialize debug graphs
local fpsGraph, memGraph, dtGraph

-- Function to set up the rendering pipeline
local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    -- Add the video drawing stage without a shader
    pipeline:addStage(nil, function()
        love.graphics.clear(0, 0, 0)
    end)

    -- Add the PXL shader stage
    pipeline:addStage(nil, function()
        uiManager:draw("npc_test")
    end)

    return pipeline
end

function npc_test:load(args)
    ManualtransitionIn()

    -- Load the NPC data
    local npcCount = 5  -- Number of NPCs to spawn

    -- Create multiple NPC UI elements
    for i = 1, npcCount do
        local npcConfig = {
            x = love.math.random(200, G.WINDOW.WIDTH - 200),
            y = love.math.random(200, G.WINDOW.HEIGHT - 200),
            w = 100,
            h = 100,
            spritesheet = "assets/spritesheets/placeholder_npc.png",
            scale = 2,
            radius = 100,
            clickableRadius = 50,
            speed = 30,
            onClick = function() print('clicked npc_' .. i) end
        }

        -- Create NPC as a UI element
        local npcElement = NpcElement.new(npcConfig)
        table.insert(npcs, npcElement)
        uiManager:registerElement("npc_test",'npc_' .. i, npcElement)
    end

    self.pipeline = setupPipeline()
    self.timer = Timer.new()  -- Initialize the HUMP timer

    -- Initialize debug graphs
    fpsGraph = debugGraph:new('fps', 0, 0, 50, 30, 0.5, 'fps', love.graphics.newFont(16))
    memGraph = debugGraph:new('mem', 0, 30, 50, 30, 0.5, 'mem', love.graphics.newFont(16))
    dtGraph = debugGraph:new('custom', 0, 60, 50, 30, 0.5, 'custom', love.graphics.newFont(16))
end

function npc_test:update(dt)
    -- Update the HUMP timer
    self.timer:update(dt)

    -- Update NPCs
    for _, npc in ipairs(npcs) do
        npc:update(dt)
    end

    -- Update the UI (if needed)
    uiManager:update("npc_test", dt)

    -- Update the graphs
    fpsGraph:update(dt)
    memGraph:update(dt)

    -- Update our custom graph
    dtGraph:update(dt, math.floor(dt * 1000))
    dtGraph.label = 'DT: ' ..  math.round(dt, 4)
end

function npc_test:draw()
    if self.pipeline then
        self.pipeline:run()
    end

    if version == 'dev-mode' then
        -- Draw graphs
        fpsGraph:draw()
        memGraph:draw()
        dtGraph:draw()
    end
end

function npc_test:mousepressed(x, y, button)
end

function npc_test:keypressed(key)
end

return npc_test
