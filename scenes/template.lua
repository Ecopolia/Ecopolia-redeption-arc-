local template = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Blue background
        love.graphics.clear(hex('5fcde4'))
        uiManager:draw("template_windows")
    end)

    pipeline:addStage(nil, function()
        uiManager:draw("template_buttons")
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
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    EotArea = Window.new({
        x = 10,
        y = 500,
        w = 130,
        h = 200,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    NextCardArea = Window.new({
        x = 1070,
        y = 450,
        w = 200,
        h = 250,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    PlacementBoard = Window.new({
        x = 250,
        y = 30,
        w = 800,
        h = 450,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    PlayerArea = Window.new({
        x = 10,
        y = 30,
        w = 220,
        h = 450,
        font = G.Fonts.m6x11plus_medium,
        visible = true,
        color = hex('c28569')
    })

    EnnemyArea = Window.new({
        x = 1070,
        y = 30,
        w = 200,
        h = 400,
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



    -- Create player placement squares with fake Z-axis vanishing point effect
    local playerSquares = {}
    local playerXStart = 350 -- Starting X coordinate for the first column
    local playerXGap = 90 -- Horizontal gap between columns
    local playerYStart = 500 -- Starting Y coordinate for the first row (closer to player)
    local playerYGap = 100 -- Vertical gap between rows
    local perspectiveScale = 0.2 -- Scaling factor for perspective effect

    -- Vanishing point at the top-middle of the screen
    local vanishingPointX = 450  -- Horizontal middle of the screen
    local vanishingPointY = 50   -- Top of the screen (higher is farther away)

    for col = 1, 2 do
        for row = 1, 3 do
            -- Apply a perspective scaling factor to simulate the Z-axis (row 1 is farther, row 3 is closer)
            local scale = 1 + ((row - 1) * perspectiveScale) -- Larger scale as we move down (closer)

            -- Adjust the X position to simulate perspective convergence toward the vanishing point
            local baseX = playerXStart + (col - 1) * playerXGap
            local skewedX = baseX + ((vanishingPointX - baseX) * (1 - scale)) -- Push X towards the vanishing point

            -- Adjust the Y position for perspective, moving the row upward as scale increases
            local baseY = playerYStart - (row - 1) * playerYGap
            local skewedY = baseY + ((vanishingPointY - baseY) * (1 - scale)) -- Move Y toward vanishing point

            -- Calculate the size of the diamond (width and height increase as we go down rows)
            local width = 80 * scale
            local height = 80 * scale -- Keep height and width the same for diamond effect

            -- Calculate the position of each corner of the diamond
            local vertices = {
                {skewedX, skewedY - height / 2},          -- Top vertex
                {skewedX + width / 2, skewedY},           -- Right vertex
                {skewedX, skewedY + height / 2},          -- Bottom vertex
                {skewedX - width / 2, skewedY}            -- Left vertex
            }

            -- Create the Freeform component
            local freeform = Freeform.new({
                points = vertices,
                color = {1, 0.8, 0},  -- Color to match the original button's background
                borderColor = {1, 1, 1}, -- Border color
                borderThickness = 2,
                visible = true
            })

            -- Register the freeform with a unique name
            local freeformName = "psq_" .. col .. "_" .. row
            uiManager:registerElement("template_buttons", freeformName, freeform)

            -- Store reference to the square
            table.insert(playerSquares, freeform)
        end
    end






    
    -- Create enemy placement squares using a loop
    local enemySquares = {}
    local enemyXPositions = {920, 830} 
    local enemyYStart = 120
    local enemyYGap = 90
    for col = 1, #enemyXPositions do
        for row = 1, 3 do
            local x = enemyXPositions[col]
            local y = enemyYStart + (row - 1) * enemyYGap

            local square = Button.new({
                text = "",
                x = x,
                y = y,
                w = 80,
                h = 80,
                onClick = function()
                    -- next turn trigger
                end,
                css = {
                    backgroundColor = hex('feae34'),
                    hoverBackgroundColor = hex('cb9326'),
                    textColor = {1, 1, 1},
                    borderColor = {1, 1, 1},
                }
            })

            -- Register the square with a unique name
            local squareName = "esq_" .. col .. "_" .. row
            uiManager:registerElement("template_buttons", squareName, square)
            
            table.insert(enemySquares, square)
        end
    end




    uiManager:registerElement("template_windows", "deck", DeckArea)
    uiManager:registerElement("template_windows", "eot", EotArea)
    uiManager:registerElement("template_windows", "nca", NextCardArea)
    uiManager:registerElement("template_windows", "pb", PlacementBoard)
    uiManager:registerElement("template_windows", "pa", PlayerArea)
    uiManager:registerElement("template_windows", "ea", EnnemyArea)

    uiManager:registerElement("template_buttons", "eotb", EndButton)

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
    uiManager:update("template_windows", dt)
    uiManager:update("template_buttons", dt)
end

function template:mousepressed(x, y, button)
    -- Handle mouse press events for UI elements
    uiManager:mousepressed("template_windows", x, y, button)
    uiManager:mousepressed("template_buttons", x, y, button)
end

return template
