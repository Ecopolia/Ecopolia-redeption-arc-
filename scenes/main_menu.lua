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
local mainMenuCanvas = love.graphics.newCanvas(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

local save_and_load = require 'engine/save_and_load'

local function setupMainMenuPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    -- Stage 1: Draw the background and static elements (no shader)
    pipeline:addStage(nil, function()
        -- Draw the space background
        love.graphics.draw(space_bg, 0, 0, 0, 1, 1)

        -- Draw the main menu name in the center of the screen
        main_menu_name:draw(10, 10)

        -- Draw the version text at the bottom right corner
        version_text:draw(G.WINDOW.WIDTH - 200, G.WINDOW.HEIGHT - 50)

        -- Draw stars animations
        for _, starData in ipairs(stars) do
            starData.animation:draw(star, starData.x, starData.y, 0, 0.5, 0.5, 16, 16)
        end

        -- Draw falling star animation if applicable
        if falling_star_timer <= 1 then
            falling_star_animation:draw(falling_star, 1000, 200, 0, 1, 1, 64, 64)
        end
    end)

    -- Stage 2: Apply resizing and draw earth animation (no shader)
    pipeline:addStage(nil, function()
        -- Resize earth animation to 3 times the size
        love.graphics.setDefaultFilter('nearest', 'nearest')
        earth_animation:draw(earth, 400, 100, 0, earth_zoom, earth_zoom)
        love.graphics.setDefaultFilter('linear', 'linear')
    end)

    -- Stage 3: Draw UI elements (no shader)
    pipeline:addStage(nil, function()
        -- Draw the UI elements for the main menu
        uiManager:draw("main_menu")
    end)

    -- Stage 4: Apply CRT shader
    pipeline:addStage(G.SHADERS['TRN'], function()
        -- The pipeline will automatically handle canvas switching, so you just draw
    end)

    return pipeline
end

local function createSaveSlotButton(slot, x, y)
    local saveData = save_and_load.load(slot)
    local text = "Empty Slot"
    local sprite = nil
    local playtime = "00:00:00"
    local zone = "Unknown"

    if saveData then
        text = "Save Slot " .. slot
        if saveData.sprite then
            spriteSheet = love.graphics.newImage(saveData.sprite) -- Load the sprite sheet from the file path
            grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
            animation = anim8.newAnimation(grid('1-9', 11), 0.2) -- Create a walking down animation
        end

        playtime = formatPlaytime(saveData.playtime)
        zone = saveData.zone
    end

    return Button.new({
        text = text,
        x = x,
        y = y,
        w = 800,
        h = 100,
        onClick = function()
            G:setCurrentSlot(slot)
            main_menu.setScene('map', {
                slot = slot
            })
            G:setPlaytime(slot, saveData.playtime)
        end,
        css = {
            backgroundColor = {0.5, 0.5, 0.5},
            hoverBackgroundColor = {0.7, 0.7, 0.7},
            textColor = {1, 1, 1},
            borderColor = {1, 1, 1},
            font = love.graphics.newFont(16),
            textX = 10,
            textY = 10
        },
        update = function(self, dt)
            if animation then
                animation:update(dt) -- Update the animation
            end
        end,
        draw = function(self)
            if animation then
                animation:draw(spriteSheet, self.x + self.width - 74, self.y + 10, 0, 0.5, 0.5) -- Top-right
            end
            love.graphics.print("Playtime: " .. playtime, self.x + 10, self.y + self.height - 30) -- Bottom-left
            love.graphics.print("Zone: " .. zone, self.x + self.width - 200, self.y + self.height - 30) -- Bottom-right
        end
    })
end

function main_menu:load()
    ManualtransitionIn() -- i do this cause it is the first scene
    main_menu_name = Text.new("left", {
        color = {0.9, 0.9, 0.9, 0.95},
        shadow_color = {0.5, 0.5, 1, 0.4},
        font = G.Fonts.m6x11plus,
        keep_space_on_line_break = true
    })
    main_menu_name:send("[shake=0.4][breathe=0.2]ECOPOLIA [blink]|[/blink][/shake][/breathe]", 320, false)
    menu_theme_source = love.audio.newSource('assets/sounds/space_music/meet-the-princess.wav', 'static')
    menu_theme = ripple.newSound(menu_theme_source, {
        volume = 0.3,
        loop = true
    })
    -- due to a little hack the song was already playing but paused on newSource so we resume it if we want to play it
    menu_theme:resume()

    SettingsWindow = Window.new({
        x = G.WINDOW.WIDTH / 2 - 200,
        y = G.WINDOW.HEIGHT / 2 - 250,
        w = 400,
        h = 500,
        z = 10,
        borderThickness = 32,
        title = "Settings",
        uiAtlas = G.UiAtlas_Animation,
        font = G.Fonts.m6x11plus_medium,
        visible = false,
        color = {0.5, 0.5, 0.9}
    })
    uiManager:registerElement("main_menu", "SettingsWindow", SettingsWindow)

    local play = Button.new({
        text = "[shake=0.4][breathe=0.2]Play[/shake][/breathe]",
        dsfull = false,
        x = 100,
        y = G.WINDOW.HEIGHT - 200,
        w = 200,
        h = 60,
        onClick = function()
            menu_theme:stop(G.TRANSITION_DURATION)
            uiManager:hideElement("main_menu", "play")
            uiManager:hideElement("main_menu", "quit")
            uiManager:hideElement("main_menu", "map")

            -- Create save slot buttons
            local saveSlot1 = createSaveSlotButton(1, 300, 200)
            local saveSlot2 = createSaveSlotButton(2, 300, 300)
            local saveSlot3 = createSaveSlotButton(3, 300, 400)

            -- Register save slot buttons
            uiManager:registerElement("main_menu", "saveSlot1", saveSlot1)
            uiManager:registerElement("main_menu", "saveSlot2", saveSlot2)
            uiManager:registerElement("main_menu", "saveSlot3", saveSlot3)
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

    local quit = Button.new({
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

    local settings = Button.new({
        text = "",
        x = G.WINDOW.WIDTH - 100,
        y = 10,
        w = 64,
        h = 64,
        onClick = function()
            G.METAL_BUTTONS_ICONS_ANIMATIONS.settings:gotoFrame(3)
            Timer.after(0.3, function()
                SettingsWindow:toggle()
                G.METAL_BUTTONS_ICONS_ANIMATIONS.settings:gotoFrame(1)
            end)
        end,
        onHover = function(button)
            G.METAL_BUTTONS_ICONS_ANIMATIONS.settings:gotoFrame(2)
        end,
        onUnhover = function(button)
            G.METAL_BUTTONS_ICONS_ANIMATIONS.settings:gotoFrame(1)
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

    local music = Button.new({
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
        onHover = function(button)
            if G.METAL_BUTTONS_ICONS_ANIMATIONS.music:getCurrentFrame() == 3 then

            else
                G.METAL_BUTTONS_ICONS_ANIMATIONS.music:gotoFrame(2)
            end
        end,
        onUnhover = function(button)
            if G.METAL_BUTTONS_ICONS_ANIMATIONS.music:getCurrentFrame() == 3 then

            else
                G.METAL_BUTTONS_ICONS_ANIMATIONS.music:gotoFrame(1)
            end
        end,
        onLoad = function(button)
            if menu_theme:isPlaying() then

            else
                Timer.after(1, function()
                    G.METAL_BUTTONS_ICONS_ANIMATIONS.music:gotoFrame(3)
                end)

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

    local map = Button.new({
        text = "[shake=0.4][breathe=0.2]Map Dev[/shake][/breathe]",
        dsfull = false,
        x = 500,
        y = G.WINDOW.HEIGHT - 150,
        w = 200,
        h = 60,
        onClick = function()
            menu_theme:stop(G.TRANSITION_DURATION)
            uiManager:hideElement("main_menu", "play")
            uiManager:hideElement("main_menu", "quit")
            uiManager:hideElement("main_menu", "map")

            -- Create save slot buttons
            local saveSlot1 = createSaveSlotButton(1, 300, 200)
            local saveSlot2 = createSaveSlotButton(2, 300, 300)
            local saveSlot3 = createSaveSlotButton(3, 300, 400)

            -- Register save slot buttons
            uiManager:registerElement("main_menu", "saveSlot1", saveSlot1)
            uiManager:registerElement("main_menu", "saveSlot2", saveSlot2)
            uiManager:registerElement("main_menu", "saveSlot3", saveSlot3)
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

    local file = io.open(G.ROOT_PATH .. "/version", "r")
    version_text = Text.new("left", {
        color = {0.9, 0.9, 0.9, 0.95},
        shadow_color = {0.5, 0.5, 1, 0.4},
        font = G.Fonts.default,
        keep_space_on_line_break = true
    })
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
        table.insert(stars, {
            x = x,
            y = y,
            animation = animation
        })
    end

    falling_star = love.graphics.newImage("assets/spritesheets/falling_star.png")
    local falling_star_grid = anim8.newGrid(128, 128, falling_star:getWidth(), falling_star:getHeight())
    falling_star_animation = anim8.newAnimation(falling_star_grid('1-9', 1), 0.125)

    uiManager:registerElement("main_menu", "play", play)
    uiManager:registerElement("main_menu", "quit", quit)
    uiManager:registerElement("main_menu", "settings", settings)
    uiManager:registerElement("main_menu", "music", music)
    -- uiManager:registerElement("main_menu", "map", map)

    self.pipeline = setupMainMenuPipeline()
end

function main_menu:draw()
    if self.pipeline then
        self.pipeline:run()
    end
end

function main_menu:update(dt)
    main_menu_name:update(dt)
    uiManager:update("main_menu", dt)
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
end

return main_menu
