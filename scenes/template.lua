local template = {}

function template:load(args)

    ButtonManager.registerButton({'template'}, {
        text = "",
        x = G.WINDOW.WIDTH - 100,
        y = 10,
        w = 64,
        h = 64,
        onClick = function()
            G.METAL_BUTTONS_ICONS_ANIMATIONS.settings:resume()
            myWindow:toggle()
        end,
        css = {
            backgroundColor = {0, 0, 0, 0},
            hoverBackgroundColor = {0, 0, 0, 0},
            hoverBorderColor = {0, 0, 0, 0},
            textColor = {0, 0, 0, 0},
            font = G.Fonts.m6x11plus
        },
        anim8 = G.METAL_BUTTONS_ICONS_ANIMATIONS.settings,
        image = G.METAL_BUTTONS_ICONS_IMAGE
    })



    local windowConfig = {
        x = G.WINDOW.WIDTH / 2 - 200,
        y = G.WINDOW.HEIGHT / 2 - 250,
        w = 400,
        h = 500,
        borderThickness = 32,
        title = "Settings",
        uiAtlas = G.UiAtlas_Animation,
        font = G.Fonts.m6x11plus_medium,
        visible = true
    }
    myWindow = Window.new(windowConfig)

    -- Register the window with the UiManager in a specific scope
    uiManager:registerElement("template", "myWindow", myWindow)
    myWindow:toggle()
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