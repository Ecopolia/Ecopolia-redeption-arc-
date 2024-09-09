local intro = {}

local intro_canva = love.graphics.newCanvas(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)
local pxlCanvas = love.graphics.newCanvas(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)
local crtCanvas = love.graphics.newCanvas(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

local mouseMovedTimer = 0
local mouseInactivityDuration = 3

function intro:load(args)
    -- Load the video
    intro_vid = love.graphics.newVideo('assets/vids/intro.ogv')
    intro_vid:play()  -- Start playing the video

    skipButton = Button.new({
        text = "[shake=0.4][breathe=0.2]Skip[/shake][/breathe]",
        x = 1080,  -- Adjust position to bottom right
        y = 640,
        w = 180,
        h = 60,
        onClick = function()
            -- Define what happens when the SKIP button is clicked
            -- For example, skip the intro video or transition to another game state
            print("Skipping intro...")
            intro_vid:pause()
            playing = intro_vid:isPlaying( )
            print(playing)
            -- self.setScene('battleground')
        end,
        css = {
            backgroundColor = {0.5, 0.5, 0.5},  -- Grey background
            hoverBackgroundColor = {0.7, 0.7, 0.7},  -- Lighter grey on hover
            textColor = {1, 1, 1},  -- White text
            borderColor = {1, 1, 1},  -- White border
            font = G.Fonts.m6x11plus  -- Assuming this font is defined elsewhere
        }
    })
    skipButton.visible = false 

    uiManager:registerElement("intro", "skip", skipButton)
    
end

function intro:draw()
    -- Draw video to canvas without shaders first
    love.graphics.setCanvas(intro_canva)
    love.graphics.clear()

    
    if intro_vid then
        if intro_vid:isPlaying( ) then 
            love.graphics.draw(intro_vid, 0, -100, 0, 1.5, 2)
        end
    end

    

    love.graphics.setCanvas()
    -- Apply PXL shader to canvas content
    love.graphics.setCanvas(pxlCanvas)
    love.graphics.setShader(G.SHADERS['PXL'])
    love.graphics.draw(intro_canva, 0, 0)
    love.graphics.setShader() -- Reset shader to default
    uiManager:draw("intro")
    love.graphics.setCanvas()

    -- Apply CRT shader to PXL shader canvas content
    love.graphics.setCanvas(crtCanvas)
    
    love.graphics.setShader(G.SHADERS['CRT'])
    love.graphics.draw(pxlCanvas, 0, 0)
    love.graphics.setShader() -- Reset shader to default
    love.graphics.setCanvas()

    -- Draw the final output with CRT shader applied
    love.graphics.draw(crtCanvas, 0, 0)
end

function intro:update(dt)
    -- Update the button manager (if any UI elements are being managed)
    uiManager:update("intro", dt)

    -- Check if the video is still playing, and update accordingly
    if intro_vid and not intro_vid:isPlaying() then
        intro_vid:play()  -- Ensure the video keeps playing
    end

    mouseMovedTimer = mouseMovedTimer + dt
    if mouseMovedTimer > mouseInactivityDuration then
        skipButton.visible = false
    end
end

function intro:mousemoved(x, y)
    -- Reset the timer and show the Skip button when the mouse is moved
    if skipButton then
        mouseMovedTimer = 0
        skipButton.visible = true
    end
end

function intro:mousepressed(x, y, button)
    -- Handle mouse press events if necessary
end

function intro:keypressed(key)
    -- Handle key press events if necessary
end

return intro
