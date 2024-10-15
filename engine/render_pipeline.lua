Pipeline = {}
Pipeline.__index = Pipeline

function Pipeline.new(width, height)
    local self = setmetatable({}, Pipeline)
    self.width = width
    self.height = height
    self.stages = {}
    return self
end

function Pipeline:addStage(shader, drawFunc, stageWidth, stageHeight)
    if not drawFunc then
        error("drawFunc is required for a pipeline stage")
    end

    -- Use custom stage dimensions if provided, otherwise default to pipeline width/height
    local canvasWidth = stageWidth or self.width
    local canvasHeight = stageHeight or self.height
    
    local stage = {
        canvas = love.graphics.newCanvas(canvasWidth, canvasHeight),
        shader = shader,
        drawFunc = drawFunc
    }
    
    table.insert(self.stages, stage)
end


function Pipeline:run()
    if #self.stages == 0 then
        error("Pipeline has no stages to run")
    end

    -- Iterate over all stages and apply them
    for i, stage in ipairs(self.stages) do
        -- Set the canvas for this stage with stencil support
        love.graphics.setCanvas({stage.canvas, stencil = true})
        love.graphics.clear()  -- Clear canvas before drawing

        -- Apply shader if it exists
        if stage.shader then
            love.graphics.setShader(stage.shader)
        end

        -- Draw the previous stage's canvas if it exists
        if i > 1 then
            love.graphics.draw(self.stages[i - 1].canvas, 0, 0)
        end

        -- Execute the drawing function for this stage
        stage.drawFunc()

        -- Reset the shader
        love.graphics.setShader()

        -- Reset the canvas after drawing, preserving stencil buffer
        love.graphics.setCanvas()
    end

    -- Start push for resolution handling
    push:start()

    -- Draw the final result from the last stage's canvas using push scaling
    local finalCanvas = self.stages[#self.stages].canvas
    if finalCanvas then
        love.graphics.draw(finalCanvas, 0, 0)
    else
        error("Final stage's canvas is nil")
    end

    -- End the push pipeline (this applies resolution scaling and renders to screen)
    push:finish()
end

return Pipeline
