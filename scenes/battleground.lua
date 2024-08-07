local battleground = {}
bg = love.graphics.newImage("assets/imgs/battlegrounds/Battleground4.png")

function battleground:load(args)
    
    battle_theme_source = love.audio.newSource('assets/sounds/space_music/battle.wav', 'static')
    battle_theme = ripple.newSound(battle_theme_source, {
        volume = 0.3,
        loop = true
    })
    battle_theme:play()
end

function battleground:draw()
    -- Clear the screen with black color
    love.graphics.clear(0, 0, 0, 1)

    -- Draw the background
    -- resize down the bg to G.WINDOW.WIDTH and G.WINDOW.HEIGHT

    love.graphics.draw(bg, 0, 0, 0, G.WINDOW.WIDTH / bg:getWidth(), G.WINDOW.HEIGHT / bg:getHeight())

    uiManager:draw("battleground")
    ButtonManager.drawButtons('battleground')
end

function battleground:outsideShaderDraw()
    -- This function is currently empty
    
end

function battleground:update(dt)
    -- Update the button manager
    uiManager:update("battleground", dt)
    ButtonManager.updateButtons('battleground', dt)
    
end

function battleground:mousepressed(x, y, button)
    -- Handle mouse press events for buttons
    ButtonManager.mousepressed('battleground', x, y, button)
end

return battleground