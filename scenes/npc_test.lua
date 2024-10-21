local npc_test = {}

local mapLoaded = false
local loadingCoroutine = nil
local gamemap = nil
local camera = nil
local zoomFactor = 100
local mapscale = 0.5

-- Initialize debug graphs and grid manager
local fpsGraph, memGraph, dtGraph

-- Function to set up the rendering pipeline
local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    -- Clear screen
    pipeline:addStage(nil, function()
        love.graphics.clear(0.1, 0.1, 0.1, 1)
        if not mapLoaded then
            love.graphics.print("Chargement de la carte...", 400, 300)
        end
    end)

    -- Stage to draw the map directly without using a camera
    pipeline:addStage(nil, function()
        if mapLoaded and gamemap then
            -- Draw the entire map without scaling or zoom
            gamemap:draw(0, 0, nil, nil, mapscale, mapscale)
        end
    end)

    -- Stage for UI (like NPCs)
    pipeline:addStage(nil, function()
        -- Draw the rest of the UI elements
        uiManager:draw("npc_test")
            
        world:draw()
    end)

    pipeline:addStage(nil, function()
    end)

    return pipeline
end

function npc_test:load(args)
    ManualtransitionIn()

    loadingCoroutine = coroutine.create(function()
        -- Simulate loading delay
        love.timer.sleep(2)
        -- Load the map
       gamemap = sti('assets/maps/Level_0.lua')

        -- Create and center the camera on an initial position
        camera = Camera(0, 0)
        mapLoaded = true
    end)

    world = bf.newWorld(0, 90.81, true)


    -- -- Create an NPC that moves along a predefined path
    -- local npc_path = NpcElement.new({
    --     x = 200,
    --     y = 100,
    --     w = 50,
    --     h = 50,
    --     scale = 2,
    --     speed = 60,
    --     radius = 0,
    --     clickableRadius = 20,
    --     mode = "predefined-path", 
    --     path = {{x = 200, y = 100}, {x = 300, y = 100}, {x = 400, y = 100}, {x = 500, y = 100}, {x = 600, y = 100}, {x = 700, y = 100}},
    --     onClick = function() print("NPC clicked!") end,
    --     world = world
    -- })

    -- local npc_tour = NpcElement.new({
    --     x = 400,
    --     y = 300,
    --     w = 50,
    --     h = 50,
    --     scale = 2,
    --     speed = 60,
    --     radius = 0,
    --     clickableRadius = 20,
    --     mode = "predefined-roundtour",
    --     path = {{x = 400, y = 300}, {x = 500, y = 300}, {x = 500, y = 400}, {x = 400, y = 400}},
    --     onClick = function() print("NPC clicked!") end,
    --     world = world
    -- })

    npc_random = NpcElement.new({
        x = 485,
        y = 170,
        w = 50,
        h = 50,
        scale = 2,
        speed = 30,
        radius = 100,
        clickableRadius = 20,
        mode = "predefined-path", 
        debug = true,
        path = {{x = 200, y = 600}, {x = 300, y = 600}, {x = 400, y = 600}, {x = 500, y = 600}, {x = 600, y = 600}, {x = 700, y = 600}},
        onClick = function() print("NPC clicked!") end,
        world = world
    })

    -- world:newCollider("Rectangle", {512, 190, 50, 60})


    -- uiManager:registerElement("npc_test", "npc_path", npc_path)
    -- uiManager:registerElement("npc_test", "npc_tour", npc_tour)
    uiManager:registerElement("npc_test", "npc_random", npc_random)

    -- Set up the pipeline and debug graphs
    self.pipeline = setupPipeline()
    self.timer = Timer.new()
    fpsGraph = debugGraph:new('fps', 0, 0, 50, 30, 0.5, 'fps', love.graphics.newFont(16))
    memGraph = debugGraph:new('mem', 0, 30, 50, 30, 0.5, 'mem', love.graphics.newFont(16))
    dtGraph = debugGraph:new('custom', 0, 60, 50, 30, 0.5, 'custom', love.graphics.newFont(16))

end

function npc_test:update(dt)
    if loadingCoroutine and coroutine.status(loadingCoroutine) ~= "dead" then
        coroutine.resume(loadingCoroutine)
    end

    if mapLoaded and gamemap then
        -- Mettre à jour la carte (par exemple, si elle contient des éléments interactifs ou de la physique)
        gamemap:update(dt)

    end

    -- Update the HUMP timer
    self.timer:update(dt)

    -- Update the UI
    G.SETTINGS.GRAPHICS.fog_light = {npc_random.position.x, npc_random.position.y}
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
