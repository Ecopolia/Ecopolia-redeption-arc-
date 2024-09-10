Pipeline = {}
Pipeline.__index = Pipeline

function Pipeline.new(width, height)
    local self = setmetatable({}, Pipeline)
    self.width = width
    self.height = height
    self.stages = {}
    print('Pipeline init')
    return self
end

function Pipeline:addStage(shader, drawFunc)
    if not drawFunc then
        error("drawFunc is required for a pipeline stage")
    end
    
    local stage = {
        canvas = love.graphics.newCanvas(self.width, self.height),
        shader = shader,
        drawFunc = drawFunc
    }
    
    table.insert(self.stages, stage)
    print("Stage added. Total stages: " .. #self.stages)
end


function Pipeline:run()
    if #self.stages == 0 then
        error("Pipeline has no stages to run")
    end
    
    -- Iterate over all stages and apply them
    for i, stage in ipairs(self.stages) do
        -- Set the canvas for this stage
        love.graphics.setCanvas(stage.canvas)
        love.graphics.clear()
        
        -- Apply shader if it exists
        if stage.shader then
            love.graphics.setShader(stage.shader)
        end

        -- Execute the drawing function
        stage.drawFunc()

        -- Reset the shader
        love.graphics.setShader()

        -- Unset the canvas if this is the last stage
        if i == #self.stages then
            love.graphics.setCanvas()
        end
    end

    -- Draw the final result from the last stage's canvas
    local finalCanvas = self.stages[#self.stages].canvas
    if finalCanvas then
        love.graphics.draw(finalCanvas, 0, 0)
    else
        error("Final stage's canvas is nil")
    end
end

return Pipeline