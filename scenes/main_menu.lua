local main_menu = {}

local stars = {}
local numStars = 20
local falling_star_timer = 0
local falling_star_interval = 20

-- Animation control variables
local earth_spin_speed = 0.1
local earth_zoom = 5
local transitioning = false
local transition_timer = 0
local transition_duration = 2

function main_menu:load()
    ManualtransitionIn() -- i do this cause it is the first scene
    main_menu_name = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = G.Fonts.m6x11plus, keep_space_on_line_break=true,})
    main_menu_name:send("[shake=0.4][breathe=0.2]ECOPOLIA [blink]|[/blink][/shake][/breathe]", 320, false)

    SettingsWindow = Window.new({
        x = G.WINDOW.WIDTH / 2 - 200,
        y = G.WINDOW.HEIGHT / 2 - 250,
        w = 400,
        h = 500,
        borderThickness = 32,
        title = "Settings",
        uiAtlas = G.UiAtlas_Animation,
        font = G.Fonts.m6x11plus_medium,
        visible = false
    })
    uiManager:registerElement("main_menu", "SettingsWindow", SettingsWindow)

    ButtonManager.registerButton({'main_menu'}, {
        text = "[shake=0.4][breathe=0.2]Play[/shake][/breathe]",
        dsfull = false,
        x = 100,
        y = G.WINDOW.HEIGHT - 200,
        w = 200,
        h = 60,
        onClick = function()
            -- transitionOut()
            -- Timer.after(2, function()
            --     transitionIn()
            -- end)
            -- stop the music
            menu_theme:stop(G.TRANSITION_DURATION)
            self.setScene('template')
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
        y = G.WINDOW.HEIGHT - 100,
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

    ButtonManager.registerButton({'main_menu'}, {
        text = "",
        x = G.WINDOW.WIDTH - 100,
        y = 10,
        w = 64,
        h = 64,
        onClick = function()
            G.METAL_BUTTONS_ICONS_ANIMATIONS.settings:resume()
            SettingsWindow:toggle()
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

    ButtonManager.registerButton({'main_menu'}, {
        text = "",
        x = G.WINDOW.WIDTH - 160,
        y = 10,
        w = 64,
        h = 64,
        onClick = function()
            menu_theme:toggle()
            if G.METAL_BUTTONS_ICONS_ANIMATIONS.music:getCurrentFrame() == 3 then
                G.METAL_BUTTONS_ICONS_ANIMATIONS.music:gotoFrame(1)
            else
                G.METAL_BUTTONS_ICONS_ANIMATIONS.music:gotoFrame(3)
            end
        end,
        css = {
            backgroundColor = {0, 0, 0, 0},
            hoverBackgroundColor = {0, 0, 0, 0},
            hoverBorderColor = {0, 0, 0, 0},
            textColor = {0, 0, 0, 0},
            font = G.Fonts.m6x11plus
        },
        anim8 = G.METAL_BUTTONS_ICONS_ANIMATIONS.music,
        image = G.METAL_BUTTONS_ICONS_IMAGE
    })

    local file = io.open(G.ROOT_PATH .. "/version", "r")
    version_text = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = G.Fonts.default, keep_space_on_line_break=true,})
    version_text:send("Version: " .. version, 320, true)

    earth = love.graphics.newImage("assets/spritesheets/earth.png")
    earth_grid = anim8.newGrid(100, 100, earth:getWidth(), earth:getHeight())
    earth_animation = anim8.newAnimation(earth_grid('1-50', '1-100'), earth_spin_speed)

    space_bg = love.graphics.newImage("assets/imgs/space_bg.png")

    star = love.graphics.newImage("assets/spritesheets/star.png")
    
    -- Create a grid for the animation frames
    local star_grid = anim8.newGrid(32, 32, star:getWidth(), star:getHeight())
    
    -- Generate random positions for the stars and create individual animations
    for i = 1, numStars do
        local x = math.random(0, love.graphics.getWidth())
        local y = math.random(0, love.graphics.getHeight())
        local frameDuration = math.random(30, 50) / 100 -- Random frame duration between 0.1 and 0.2 seconds
        local animation = anim8.newAnimation(star_grid('1-4', 1), frameDuration)
        table.insert(stars, {x = x, y = y, animation = animation})
    end

    falling_star = love.graphics.newImage("assets/spritesheets/falling_star.png")
    local falling_star_grid = anim8.newGrid(128, 128, falling_star:getWidth(), falling_star:getHeight())
    falling_star_animation = anim8.newAnimation(falling_star_grid('1-9', 1), 0.125)

    menu_theme_source = love.audio.newSource('assets/sounds/space_music/meet-the-princess.wav', 'static')
    menu_theme = ripple.newSound(menu_theme_source, {
        volume = 0.3,
        loop = true
    })
    menu_theme:play()

end

function main_menu:draw()
    love.graphics.draw(space_bg, 0, 0, 0, 1, 1)

    -- Draw the main menu name in the center of the screen
    main_menu_name:draw(10, 10)

    -- Draw the version text at the bottom right corner of the screen
    version_text:draw(G.WINDOW.WIDTH - 200 , G.WINDOW.HEIGHT - 50)

    ButtonManager.drawButtons('main_menu')

    for _, starData in ipairs(stars) do
        starData.animation:draw(star, starData.x, starData.y, 0, 0.5, 0.5, 16, 16)
    end

    -- Draw the falling star if the timer is within the interval
    if falling_star_timer <= 1 then
        falling_star_animation:draw(falling_star, 1000, 200, 0, 1, 1, 64, 64)
    end

    -- resize animation to 3 times the size
    love.graphics.setDefaultFilter('nearest', 'nearest')
    earth_animation:draw(earth, 400, 100, 0, earth_zoom, earth_zoom)
    love.graphics.setDefaultFilter('linear', 'linear')

    uiManager:draw("main_menu")

end

function main_menu:outsideShaderDraw()
end

function main_menu:update(dt)
    main_menu_name:update(dt)
    ButtonManager.updateButtons('main_menu', dt)
    earth_animation:update(dt)

    -- Update each star's animation
    for _, starData in ipairs(stars) do
        starData.animation:update(dt)
    end

    -- Update the falling star animation and timer
    falling_star_animation:update(dt)
    falling_star_timer = falling_star_timer + dt
    if falling_star_timer >= falling_star_interval then
        falling_star_timer = 0
    end

    menu_theme:update(dt)
end

function main_menu:mousepressed(x, y, button)
    ButtonManager.mousepressed('main_menu', x, y, button)
end

return main_menu