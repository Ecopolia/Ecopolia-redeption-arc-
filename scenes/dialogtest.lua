local dialogtest = {}

local myDialogue

function dialogtest:load(args)
    
    myDialogue = LoveDialogue.play("dialogs/exampleDialogue.ld", {fadeInDuration = 0, fadeOutDuration = 0,enableFadeIn = false, enableFadeOut = false})
   
end

function dialogtest:draw()
    -- Clear the screen with grey color
    love.graphics.clear(0.5, 0.5, 0.5, 1)

    uiManager:draw("dialogtest")

    if myDialogue then
        myDialogue:draw()
    end
end

function dialogtest:outsideShaderDraw()
    -- This function is currently empty
    
end

function dialogtest:update(dt)
    -- Update the button manager
    uiManager:update("dialogtest", dt)
    if myDialogue then
        myDialogue:update(dt)
    end
    
end

function dialogtest:mousepressed(x, y, button)
    -- Handle mouse press events for buttons
end

function dialogtest:keypressed(key)
    if myDialogue then
        myDialogue:keypressed(key)
    end
end

return dialogtest