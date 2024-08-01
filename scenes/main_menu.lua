local main_menu = {}

function main_menu:load()
    main_menu_name = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = G.Fonts.m6x11plus, keep_space_on_line_break=true,})
    main_menu_name:send("[bold]E[/bold]COPOLIA|", 320, false)
end

function main_menu:draw()
    -- Set the background color to grey and draw a rectangle covering the entire screen
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Set the color to red and draw the triangle
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon('fill', 100, 100, 200, 100, 150, 150)

    -- Draw the main menu name in the center of the screen
    main_menu_name:draw(10, 10)
end

function main_menu:update(dt)
    main_menu_name:update(dt)
end

return main_menu