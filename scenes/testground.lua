local testground = {}

function testground:load()

    
end

function testground:draw()
    -- Set the background color to grey and draw a rectangle covering the entire screen
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

end

function testground:outsideShaderDraw()
    ButtonManager.drawButtons('testground')
end

function testground:update(dt)
    ButtonManager.updateButtons('testground', dt)
end

function testground:mousepressed(x, y, button)
    ButtonManager.mousepressed('testground', x, y, button)
end

return testground