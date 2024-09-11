local template = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Blue background
        love.graphics.clear(0, 0, 0.7)
        uiManager:draw("template")
    end)

    -- Add the CRT shader stage
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end

function template:load(args)
    -- Initialize NPCs for ATB
    local npcs = {
        NPC.new("Skeletton", {math.random(), math.random(), math.random()}, 1, 'ennemy'),
        NPC.new("Mage", {math.random(), math.random(), math.random()}, 1.5),
        NPC.new("Thief", {math.random(), math.random(), math.random()}, 2.5)
    }
    
    -- Create ATB using the UI Manager
    self.atbBar = ATB.new({
        x = 400, 
        y = 300, 
        w = 500, 
        h = 30
    }, npcs)
    
    -- Register ATB bar with uiManager
    uiManager:registerElement("template", "atbBar", self.atbBar)

    -- Setup the rendering pipeline
    self.pipeline = setupPipeline()
end

function template:draw()
    if not self.pipeline then
        print("Waiting for pipeline to draw")
        return
    end

    self.pipeline:run()
end

function template:outsideShaderDraw()
    -- This function is currently empty
end

function template:update(dt)
    -- Update the ATB bar and other UI elements
    uiManager:update("template", dt)
end

function template:mousepressed(x, y, button)
    -- Handle mouse press events for UI elements
    uiManager:mousepressed("template", x, y, button)
end

return template
