local intro = {}

function intro:load(args)
   
end

function intro:draw()

end

function intro:outsideShaderDraw()

end

function intro:update(dt)
    -- Update the button manager
    uiManager:update("intro", dt)
    ButtonManager.updateButtons('intro', dt)

end

function intro:mousepressed(x, y, button)

end

function intro:keypressed(key)

end

return intro