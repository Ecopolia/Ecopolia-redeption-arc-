local npc_test = {}

-- Initialize debug graphs and grid manager
local fpsGraph, memGraph, dtGraph

-- Function to set up the rendering pipeline
local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    -- Clear screen
    pipeline:addStage(nil, function()
        love.graphics.clear(0, 0, 0)
        world:draw()
    end)

    -- Stage for UI (like NPCs) using PXL shader (if any)
    pipeline:addStage(nil, function()
        -- Draw the rest of the UI elements
        uiManager:draw("npc_test")
        
    end)
    
        

    return pipeline
end


function npc_test:load(args)
    ManualtransitionIn()

    world = bf.newWorld(0, 90.81, true)

    world:newCollider("Rectangle", {250, 100, 50, 50})

    -- Create an NPC that moves along a predefined path
    local npc_path = NpcElement.new({
        x = 200,
        y = 100,
        w = 50,
        h = 50,
        scale = 2,
        speed = 60,
        radius = 0,
        clickableRadius = 20,
        mode = "predefined-path", 
        path = {{x = 200, y = 100}, {x = 300, y = 100}, {x = 400, y = 100}, {x = 500, y = 100}, {x = 600, y = 100}, {x = 700, y = 100}},
        debug = true,
        onClick = function() print("NPC clicked!") end,
        world = world
    })

    local npc_tour = NpcElement.new({
        x = 400,
        y = 300,
        w = 50,
        h = 50,
        scale = 2,
        speed = 60,
        radius = 0,
        clickableRadius = 20,
        mode = "predefined-roundtour",
        path = {{x = 400, y = 300}, {x = 500, y = 300}, {x = 500, y = 400}, {x = 400, y = 400}},
        debug = true,
        onClick = function() print("NPC clicked!") end,
        world = world
    })

    local npc_random = NpcElement.new({
        x = 700,
        y = 300,
        w = 50,
        h = 50,
        scale = 2,
        speed = 60,
        radius = 100,
        clickableRadius = 20,
        debug = true,
        onClick = function() print("NPC clicked!") end,
        world = world
    })

    world:newCollider("Rectangle", {780, 300, 50, 50})
    world:newCollider("Rectangle", {780, 400, 50, 50})

    world:newCollider("Rectangle", {680, 300, 50, 50})
    world:newCollider("Rectangle", {680, 400, 50, 50})

    uiManager:registerElement("npc_test", "npc_path", npc_path)
    uiManager:registerElement("npc_test", "npc_tour", npc_tour)
    uiManager:registerElement("npc_test", "npc_random", npc_random)

    -- Set up the pipeline and debug graphs
    self.pipeline = setupPipeline()
    self.timer = Timer.new()
    fpsGraph = debugGraph:new('fps', 0, 0, 50, 30, 0.5, 'fps', love.graphics.newFont(16))
    memGraph = debugGraph:new('mem', 0, 30, 50, 30, 0.5, 'mem', love.graphics.newFont(16))
    dtGraph = debugGraph:new('custom', 0, 60, 50, 30, 0.5, 'custom', love.graphics.newFont(16))

end

function npc_test:update(dt)
    -- Update the HUMP timer
    self.timer:update(dt)

    -- Update the UI
    uiManager:update("npc_test", dt)

    -- Update the graphs
    fpsGraph:update(dt)
    memGraph:update(dt)
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
