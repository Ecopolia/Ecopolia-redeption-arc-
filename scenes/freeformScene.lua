local freeformScene = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Light grey background
        love.graphics.clear(hex('e0e0e0'))

        -- Draw the vanishing point outline
        drawVanishingPoint()

        -- Draw UI elements
        uiManager:draw("freeformScene")
    end)

    -- Optionally add other shader stages here
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end

-- Function to draw the vanishing point outline
function drawVanishingPoint()
    local vanishingPointX = G.WINDOW.WIDTH / 2
    local vanishingPointY = 50 -- Near the top of the screen

    -- Draw converging lines
    love.graphics.setColor(1, 0, 0) -- Red color for visibility
    love.graphics.setLineWidth(1)

    -- Top left to vanishing point
    -- love.graphics.line(0, 0, vanishingPointX, vanishingPointY)
    -- Top right to vanishing point
    -- love.graphics.line(G.WINDOW.WIDTH, 0, vanishingPointX, vanishingPointY)
    -- Bottom left to vanishing point
    love.graphics.line(0, G.WINDOW.HEIGHT, vanishingPointX, vanishingPointY)
    -- Bottom right to vanishing point
    -- love.graphics.line(G.WINDOW.WIDTH, G.WINDOW.HEIGHT, vanishingPointX, vanishingPointY)

    -- Draw a marker at the vanishing point
    love.graphics.setColor(0, 0, 1) -- Blue color for marker
    love.graphics.setLineWidth(2)
    love.graphics.circle("fill", vanishingPointX, vanishingPointY, 5) -- Marker at vanishing point
end

function freeformScene:load(args)
    -- Create various Freeform shapes
    local shapes = {}

    -- Parameters for the rhombuses
    local baseWidth, baseHeight = 100, 50
    local numRows = 3
    local rowSpacing = 100
    local perspectiveScale = 0.2 -- Scale factor for perspective effect

    -- Vanishing point coordinates
    local vanishingPointX = G.WINDOW.WIDTH / 2
    local vanishingPointY = 300 -- Near the top of the screen

    -- Create a single column of rhombuses with perspective effect
    for row = 1, numRows do
        -- Calculate scale based on row (farther rows have larger scale)
        local scale = 1 + ((row - 1) * perspectiveScale)
        scale = math.min(scale, 1.5) -- Limit maximum scale to avoid excessive stretching

        -- Calculate size based on scale
        local width = baseWidth * scale
        local height = baseHeight * scale

        -- Calculate Y position based on row index to avoid overlap
        local offsetY = (row - 1) * rowSpacing

        -- Adjust X position to align rhombuses along the vanishing line
        local skewedX = vanishingPointX - ((scale - 1) * (width / 2))
        local skewedY = vanishingPointY + offsetY

        if row == 2 then
            skewedX = skewedX - 35
            skewedY = skewedY - 50
        end

        if row == 3 then
            skewedX = skewedX - 80
            skewedY = skewedY - 90
        end

        -- Create the Freeform rhombus
        local rhombus = Freeform.new({
            z = 1,
            color = {1, 0.8, 0}, -- Color for visibility
            borderColor = {0, 0, 0}, -- Black border
            borderThickness = 2,
            visible = true
        })

        rhombus:createRhombus(skewedX, skewedY, width, height, 6)

        -- Register the rhombus with a unique name
        local rhombusName = "rhombus_" .. row
        uiManager:registerElement("freeformScene", rhombusName, rhombus)

    end

    -- Setup the rendering pipeline
    self.pipeline = setupPipeline()
end

function freeformScene:draw()
    if not self.pipeline then
        print("Waiting for pipeline to draw")
        return
    end

    self.pipeline:run()
end

function freeformScene:outsideShaderDraw()
    -- This function is currently empty
end

function freeformScene:update(dt)
    -- Update the UI elements
    uiManager:update("freeformScene", dt)
end

function freeformScene:mousepressed(x, y, button)
    -- Handle mouse press events
    uiManager:mousepressed("freeformScene", x, y, button)
end

return freeformScene
