local Pipeline = require 'engine/render_pipeline'

describe('Pipeline', function()
    -- Test the Pipeline.new() function
    it('should initialize with correct width and height', function()
        local pipeline = Pipeline.new(800, 600)
        expect(pipeline.width).to.equal(800)
        expect(pipeline.height).to.equal(600)
        expect(#pipeline.stages).to.equal(0) -- No stages added yet
    end)

    -- Test the Pipeline:addStage() function
    it('should add a stage to the pipeline', function()
        local pipeline = Pipeline.new(800, 600)
        local dummyShader = nil
        local dummyDrawFunc = function() end
        pipeline:addStage(dummyShader, dummyDrawFunc)
        expect(#pipeline.stages).to.equal(1)
        expect(pipeline.stages[1].drawFunc).to.equal(dummyDrawFunc)
    end)

    -- Test the Pipeline:run() function
    it('should throw an error when run with no stages', function()
        local pipeline = Pipeline.new(800, 600)
        expect(function() pipeline:run() end).to.fail()
    end)

    -- Test running the pipeline with a stage
    it('should execute the drawing function and shaders correctly', function()
        local pipeline = Pipeline.new(800, 600)
        local drawCalled = false
        local dummyDrawFunc = function() drawCalled = true end
        pipeline:addStage(nil, dummyDrawFunc)
        
        -- Mock push library methods
        push = {
            start = function() end,
            finish = function() end
        }

        pipeline:run()
        expect(drawCalled).to.be.truthy()
    end)
end)
