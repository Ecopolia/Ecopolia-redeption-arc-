local battleground = {}
bg = love.graphics.newImage("assets/imgs/battlegrounds/Battleground4.png")

local myDialogue

function battleground:load(args)

    battle_theme_source = love.audio.newSource('assets/sounds/space_music/battle.wav', 'static')
    battle_theme = ripple.newSound(battle_theme_source, {
        volume = 0.3,
        loop = true
    })
    battle_theme:play()
    myDialogue = LoveDialogue.play("dialogs/test.ld", {
        enableFadeIn = false,
        enableFadeOut = false,
        fadeInDuration = 0,
        fadeOutDuration = 0
    })

end

function battleground:draw()
    -- Clear the screen with black color
    love.graphics.clear(0, 0, 0, 1)

    -- Draw the background
    -- resize down the bg to G.WINDOW.WIDTH and G.WINDOW.HEIGHT

    love.graphics.draw(bg, 0, 0, 0, G.WINDOW.WIDTH / bg:getWidth(), G.WINDOW.HEIGHT / bg:getHeight())

    -- Draw G.MONSTERS.CROW.animations.idle
    G.MONSTERS.CROW.animations.idle:draw(G.MONSTERS.CROW.images.idle, 800, 200, 0, 7, 7, 0, 0)
    -- flip the image

    uiManager:draw("battleground")

    if myDialogue then
        myDialogue:draw()
    end
end

function battleground:outsideShaderDraw()
    -- This function is currently empty

end

function battleground:update(dt)
    -- Update the button manager
    uiManager:update("battleground", dt)
    if myDialogue then
        myDialogue:update(dt)
    end

end

function battleground:mousepressed(x, y, button)
    -- Handle mouse press events for buttons
end

function battleground:keypressed(key)
    if myDialogue then
        myDialogue:keypressed(key)
    end
end

return battleground
