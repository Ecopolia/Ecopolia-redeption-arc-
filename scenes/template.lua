local template = {}

function template:load(args)

end

function template:draw()
    -- Clear the screen with black color
    love.graphics.clear(0.1, 0.1, 0.1, 1)
    uiManager:draw("template")
    ButtonManager.drawButtons('template')
end

function template:outsideShaderDraw()
    -- This function is currently empty
    
end

function template:update(dt)
    -- Update the button manager
    uiManager:update("template", dt)
    ButtonManager.updateButtons('template', dt)
    
end

function template:mousepressed(x, y, button)
    -- Handle mouse press events for buttons
    ButtonManager.mousepressed('template', x, y, button)
end

return template