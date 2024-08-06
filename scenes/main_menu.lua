local main_menu = {}

function main_menu:load()
    main_menu_name = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = G.Fonts.m6x11plus, keep_space_on_line_break=true,})
    main_menu_name:send("[shake=0.4][breathe=0.2]ECOPOLIA [blink]|[/blink][/shake][/breathe]", 320, false)

    ButtonManager.registerButton({'main_menu'}, {
        text = "[shake=0.4][breathe=0.2]Play[/shake][/breathe]",
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
            -- button.text = "[shake=0.4][breathe=0.2][blink]Go[/blink][/shake][/breathe]"
            -- button.button_text:send(button.text, 320, button.dsfull)
        end,
        onUnhover = function(button)
            -- button.text = "[shake=0.4][breathe=0.2]Play[/shake][/breathe]"
            -- button.button_text:send(button.text, 320, button.dsfull)
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
        text = "[shake=0.4][breathe=0.2]Quit[/shake][/breathe]",
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

    local file = io.open(G.ROOT_PATH .. "/version", "r")
    version_text = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = G.Fonts.default, keep_space_on_line_break=true,})
    version_text:send("Version: " .. version, 320, true)

    earth = love.graphics.newImage("assets/spritesheets/earth.png")
    local earth_grid = anim8.newGrid(100, 100, earth:getWidth(), earth:getHeight())
    earth_animation = anim8.newAnimation(earth_grid('1-50', '1-100'), 0.1)

    space_bg = love.graphics.newImage("assets/imgs/space_bg.png")
    
end

function main_menu:draw()

    love.graphics.draw(space_bg, 0, 0, 0, 1, 1)

    -- Draw the main menu name in the center of the screen
    main_menu_name:draw(10, 10)

    -- Draw the version text at the bottom right corner of the screen
    version_text:draw(G.WINDOW.WIDTH - 200 , G.WINDOW.HEIGHT - 50)

    ButtonManager.drawButtons('main_menu')

    -- resize animation to 3 times the size
    love.graphics.setDefaultFilter('nearest', 'nearest')
    earth_animation:draw(earth, 400, 100, 0, 5, 5)
    love.graphics.setDefaultFilter('linear', 'linear')
end

function main_menu:outsideShaderDraw()
end

function main_menu:update(dt)
    main_menu_name:update(dt)
    ButtonManager.updateButtons('main_menu', dt)
    earth_animation:update(dt)
end

function main_menu:mousepressed(x, y, button)
    ButtonManager.mousepressed('main_menu', x, y, button)
end

return main_menu