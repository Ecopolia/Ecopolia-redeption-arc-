local template = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Blue background
        love.graphics.clear(hex('5fcde4'))
        uiManager:draw("template")
    end)

    -- Add the CRT shader stage
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end

function template:load(args)
    G.SETTINGS.GRAPHICS.glitch_intensity = 0
    ManualtransitionIn()

    -- #c28569
    DeckArea = Window.new({
        x = 160,
        y = 500,
        w = 890,
        h = 200,
        z = 0,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    EotArea = Window.new({
        x = 10,
        y = 500,
        w = 130,
        h = 200,
        z = 0,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    NextCardArea = Window.new({
        x = 1070,
        y = 450,
        w = 200,
        h = 250,
        z = 0,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    PlacementBoard = Window.new({
        x = 250,
        y = 30,
        w = 800,
        h = 450,
        z = 0,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    PlayerArea = Window.new({
        x = 10,
        y = 30,
        w = 220,
        h = 450,
        z = 0,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    EnnemyArea = Window.new({
        x = 1070,
        y = 30,
        w = 200,
        h = 400,
        z = 0,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    EndButton = Button.new({
        text = "[shake=0.4][breathe=0.2]End of turn[/shake][/breathe]",
        x = 35,
        y = 520,
        w = 80,
        h = 40,
        z = 1,
        onClick = function()
            -- next turn trigger
        end,
        css = {
            backgroundColor = hex('feae34'),
            hoverBackgroundColor = hex('cb9326'),
            textColor = {1, 1, 1},
            borderColor = {1, 1, 1},
            font = G.Fonts.m6x11plus_small,
        }
    })


    -- Register the areas with lower Z-index values
    uiManager:registerElement("template", "deck", DeckArea)
    uiManager:registerElement("template", "eot", EotArea)
    uiManager:registerElement("template", "nca", NextCardArea)
    uiManager:registerElement("template", "pb", PlacementBoard)
    uiManager:registerElement("template", "pa", PlayerArea)
    uiManager:registerElement("template", "ea", EnnemyArea)
    uiManager:registerElement("template", "eotb", EndButton)  

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
