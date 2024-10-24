local intro = {}

local mouseMovedTimer = 0
local mouseInactivityDuration = 3

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    -- Add the video drawing stage without a shader
    pipeline:addStage(nil, function()
        if intro_vid:isPlaying() then
            love.graphics.draw(intro_vid, 0, -100, 0, 1.5, 2)
        end
    end)

    -- Add the PXL shader stage
    pipeline:addStage(G.SHADERS['PXL'], function()
        uiManager:draw("intro")
    end)

    -- Add the CRT shader stage
    pipeline:addStage(G.SHADERS['CRT'], function()
    end)

    return pipeline
end

function intro:load(args)
    -- Load the video
    intro_vid = love.graphics.newVideo('assets/vids/intro.ogv')
    intro_vid:play() -- Start playing the video

    self.skipButton = Button.new({
        text = "[shake=0.4][breathe=0.2]Skip[/shake][/breathe]",
        x = 1080,
        y = 640,
        w = 180,
        h = 60,
        onClick = function()
            -- Define what happens when the SKIP button is clicked
            -- For example, skip the intro video or transition to another game state
            print("Skipping intro...")
            if intro_vid then
                intro_vid = nil -- Release the video resource
            end
            self.setScene("battleground")
        end,
        css = {
            backgroundColor = {0.5, 0.5, 0.5}, -- Grey background
            hoverBackgroundColor = {0.7, 0.7, 0.7}, -- Lighter grey on hover
            textColor = {1, 1, 1}, -- White text
            borderColor = {1, 1, 1}, -- White border
            font = G.Fonts.m6x11plus -- Assuming this font is defined elsewhere
        }
    })
    self.skipButton.visible = false

    uiManager:registerElement("intro", "skip", self.skipButton)

    self.pipeline = setupPipeline()
end

function intro:draw()
    if intro_vid then
        self.pipeline:run()
    end
end

function intro:update(dt)
    -- Update the button manager (if any UI elements are being managed)
    uiManager:update("intro", dt)

    -- Check if the video is still playing, and update accordingly
    if intro_vid and not intro_vid:isPlaying() then
        intro_vid:play() -- Ensure the video keeps playing
    end

    mouseMovedTimer = mouseMovedTimer + dt
    if mouseMovedTimer > mouseInactivityDuration then
        self.skipButton.visible = false
    end
end

function intro:mousemoved(x, y)
    -- Reset the timer and show the Skip button when the mouse is moved
    if self.skipButton then
        mouseMovedTimer = 0
        self.skipButton.visible = true
    end
end

function intro:mousepressed(x, y, button)
    -- Handle mouse press events if necessary
end

function intro:keypressed(key)
    -- Handle key press events if necessary
end

return intro
