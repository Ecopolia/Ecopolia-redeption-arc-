local main_menu = {}

function main_menu:load()
    main_menu_name = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = G.Fonts.m6x11plus, keep_space_on_line_break=true,})
    main_menu_name:send("[bold]E[/bold]COPOLIA|", 320, false)

    ButtonManager.registerButton({'main_menu'}, {
        text = "Play",
        dsfull = false,
        x = 100,
        y = 100,
        w = 200,
        h = 60,
        onClick = function()
            print("Play button clicked")
            self.setScene("testground")
        end,
        onHover = function(button)
            button.text = "Go"
            button.button_text:send(button.text, 320, button.dsfull)
        end,
        onUnhover = function(button)
            button.text = "Play"
            button.button_text:send(button.text, 320, button.dsfull)
        end,
        css = {
            backgroundColor = {0, 0.5, 0},
            hoverBackgroundColor = {0, 1, 0},
            textColor = {1, 1, 1},
            hoverTextColor = {0, 0, 0},
            borderColor = {1, 1, 1},
            borderRadius = 10,
            font = G.Fonts.m6x11plus
        }
    })

    ButtonManager.registerButton({'main_menu', 'testground'}, {
        text = "Quit",
        x = 100,
        y = 200,
        w = 200,
        h = 60,
        onClick = function()
            love.event.quit()
        end,
        css = {
            backgroundColor = {0.5, 0, 0},
            hoverBackgroundColor = {1, 0, 0},
            textColor = {1, 1, 1},
            borderColor = {1, 1, 1},
            font = G.Fonts.m6x11plus
        }
    })
end

function main_menu:draw()
    -- Set the background color to grey and draw a rectangle covering the entire screen
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    size =  100 -- Default size if not specified
    x = 500
    y = 200
    -- Calculate radii
    local outerRadius = size / 2
    local middleRadius = outerRadius * 0.7
    local innerRadius = outerRadius * 0.3

    -- Center coordinates for the circles
    local centerX = x + outerRadius
    local centerY = y + outerRadius

    -- Set the color to black for the logo parts
    love.graphics.setColor(0, 0, 0)

    -- Draw the outer circle
    love.graphics.circle("fill", centerX, centerY, outerRadius)

    -- Draw the middle circle (cutout)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", centerX, centerY, middleRadius)

    -- Draw the inner circle (black)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", centerX, centerY, innerRadius)

    -- Draw the vertical rectangle at the top
    love.graphics.rectangle("fill", centerX - outerRadius * 0.1, y, outerRadius * 0.2, outerRadius * 0.6)

    -- Draw the three rectangles at the bottom
    local rectWidth = outerRadius * 0.2
    local rectHeight = outerRadius * 0.6
    local bottomY = y + size - rectHeight

    -- Left rectangle
    love.graphics.rectangle("fill", centerX - outerRadius * 0.9, bottomY, rectWidth, rectHeight)

    -- Middle rectangle
    love.graphics.rectangle("fill", centerX - rectWidth / 2, bottomY, rectWidth, rectHeight)

    -- Right rectangle
    love.graphics.rectangle("fill", centerX + outerRadius * 0.7, bottomY, rectWidth, rectHeight)

    -- Draw the main menu name in the center of the screen
    main_menu_name:draw(10, 10)
end

function main_menu:outsideShaderDraw()
    ButtonManager.drawButtons('main_menu')
end

function main_menu:update(dt)
    main_menu_name:update(dt)
    ButtonManager.updateButtons('main_menu', dt)
end

function main_menu:mousepressed(x, y, button)
    ButtonManager.mousepressed('main_menu', x, y, button)
end

return main_menu