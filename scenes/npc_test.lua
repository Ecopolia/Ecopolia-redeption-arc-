local npc_test = {}

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
    local npcCount = 2  -- Number of NPCs to spawn

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
            onClick = function() print('clicked npc_' .. i) end,
            debug = true
        }

        -- Create NPC as a UI element
        local npcElement = NpcElement.new(npcConfig)
        uiManager:registerElement("npc_test",'npc_' .. i, npcElement)
    end

    local npc_path = NpcElement.new({
        x = 100,
        y = 100,
        w = 50,
        h = 50,
        scale = 2,
        speed = 30,
        radius = 0,
        clickableRadius = 30,
        mode = "predefined-path", -- or "random-in-area" or "predefined-roundtour"
        path = {{x = 200, y = 150}, {x = 300, y = 200}, {x = 250, y = 100}},
        debug = true,
        onClick = function() print("NPC clicked!") end
    })

    uiManager:registerElement("npc_test", "npc_path", npc_path)

    local npc_roundtour = NpcElement.new({
        x = 400,
        y = 300,
        w = 50,
        h = 50,
        scale = 2,
        speed = 30,
        radius = 0,
        clickableRadius = 30,
        mode = "predefined-roundtour",
        path = {{x = 450, y = 350}, {x = 550, y = 400}, {x = 500, y = 300}},
        debug = true,
        onClick = function() print("Roundtour NPC clicked!") end,
        waitInterval = 3
    })
    
    uiManager:registerElement("npc_test", "npc_roundtour", npc_roundtour)

    self.pipeline = setupPipeline()
    self.timer = Timer.new()

    -- Initialize debug graphs
    fpsGraph = debugGraph:new('fps', 0, 0, 50, 30, 0.5, 'fps', love.graphics.newFont(16))
    memGraph = debugGraph:new('mem', 0, 30, 50, 30, 0.5, 'mem', love.graphics.newFont(16))
    dtGraph = debugGraph:new('custom', 0, 60, 50, 30, 0.5, 'custom', love.graphics.newFont(16))
end

function npc_test:update(dt)
    -- Update the HUMP timer
    self.timer:update(dt)


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
