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

local debug = false

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
    local spriteSheet = nil
    local animation = nil
    local playtime = "00:00:00"
    local zone = "Unknown"

    -- Check if there’s save data to populate
    if saveData then
        text = "Save Slot " .. slot
        if saveData.sprite then
            spriteSheet = love.graphics.newImage(saveData.sprite)
            local grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
            animation = anim8.newAnimation(grid('1-9', 11), 0.2)
        end
        playtime = formatPlaytime(saveData.playtime)
        zone = saveData.zone
    end

    local saveSlotButton = Button.new({
        text = text,
        x = x,
        y = y,
        w = 800,
        h = 100,
        onClick = function()
            G:setCurrentSlot(slot)
            menu_theme:stop(G.TRANSITION_DURATION)
            main_menu.setScene('map', { slot = slot })
            uiManager:hideScope('main_menu')
            if saveData ~= nil then
                G:setPlaytime(slot, saveData.playtime)
            end
        end,
        css = {
            backgroundColor = {0.5, 0.5, 0.7},
            hoverBackgroundColor = {0.5, 0.5, 0.9},
            textColor = {1, 1, 1},
            borderColor = {1, 1, 1},
            font = love.graphics.newFont(16),
            textX = 10,
            textY = 10
        },
        update = function(self, dt)
            -- Update animation for this specific slot, if it exists
            if animation then
                animation:update(dt)
            end
        end,
        draw = function(self)
            -- Draw the animation for this specific slot, if it exists
            if animation then
                animation:draw(spriteSheet, self.x + self.width - 74, self.y + 10, 0, 0.5, 0.5)
            end
            love.graphics.print("Playtime: " .. playtime, self.x + 10, self.y + self.height - 30)
            love.graphics.print("Zone: " .. zone, self.x + self.width - 200, self.y + self.height - 30)
        end
    })

    local deleteButton = Button.new({
        text = "X",
        x = x + 800,
        y = y,
        w = 25,
        h = 25,
        onClick = function()
            uiManager:freezeElement('main_menu', 'BackButton')
            for i = 1, 3 do
                local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot'..i)
                if saveSlotButton then
                    uiManager:freezeElement('main_menu', 'saveSlot'..i)
                end
                uiManager:removeElement('main_menu', 'deleteButton' .. i)
            end
            -- Show or register the confirmation window and buttons
            local confirmationWindow = uiManager:getElement('main_menu', 'confirmation_window')
            if not confirmationWindow then
                confirmationWindow = Window.new({
                    x = love.graphics.getWidth() / 2 - 150,
                    y = love.graphics.getHeight() / 2 - 40,
                    w = 300,
                    h = 100,
                    z = 9,
                    title = "Confirm Delete",
                    draggable = false,
                    visible = true,
                    borderColor = {0, 0, 0},
                    color = {1, 1, 1}
                })
                uiManager:registerElement('main_menu', 'confirmation_window', confirmationWindow)
            else
                uiManager:showElement('main_menu', 'confirmation_window')
            end
    
            local confirmButton = uiManager:getElement('main_menu', 'confirm_button')
            if not confirmButton then
                confirmButton = Button.new({
                    text = "Confirm",
                    x = confirmationWindow.x + 50,
                    y = confirmationWindow.y + 40,
                    w = 80,
                    h = 30,
                    z = 10,
                    onClick = function()
                        -- Delete the save data and update the UI
                        save_and_load.delete(slot)
                        playtime = "00:00:00"
                        zone = "Unknown"
                        animation = nil
                        local button = uiManager:getElement('main_menu', 'saveSlot'..slot)
                        button:setText('Empty Slot')
                        uiManager:removeElement('main_menu', 'deleteButton'..slot)
    
                        -- Hide confirmation window after deletion
                        uiManager:hideElement('main_menu', 'confirmation_window')
                        uiManager:hideElement('main_menu', 'cancel_button')
                        uiManager:hideElement('main_menu', 'confirm_button')

                        for i = 1, 3 do
                            local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot' .. i)
                            if saveSlotButton then
                                uiManager:unfreezeElement('main_menu', 'saveSlot' .. i)
                            end
                            uiManager:showElement('main_menu', 'deleteButton' .. i)
                        end
                        uiManager:unfreezeElement('main_menu', 'BackButton')
                    end,
                    css = {
                        backgroundColor = {0.3, 0.7, 0.3},
                        hoverBackgroundColor = {0.5, 1, 0.5},
                        textColor = {1, 1, 1},
                        borderColor = {1, 1, 1}
                    }
                })
                uiManager:registerElement('main_menu', 'confirm_button', confirmButton)
            else
                uiManager:showElement('main_menu', 'confirm_button')
            end
    
            local cancelButton = uiManager:getElement('main_menu', 'cancel_button')
            if not cancelButton then
                cancelButton = Button.new({
                    text = "Cancel",
                    x = confirmationWindow.x + 170,
                    y = confirmationWindow.y + 40,
                    w = 80,
                    h = 30,
                    z = 10,
                    onClick = function()
                        for i = 1, 3 do
                            local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot' .. i)
                            if saveSlotButton then
                                uiManager:unfreezeElement('main_menu', 'saveSlot' .. i)
                            end
                            local deleteButton = uiManager:getElement('main_menu', 'deleteButton' .. i)
                            if deleteButton then
                                print(deleteButton.freeze, deleteButton.visible)
                                -- deleteButton.freeze, deleteButton.visible = false , true // for an obscure reason even manupulating the values directly will halt the uiManager for now on we will be recreating the button when user come back to the save window
                                print(deleteButton.freeze, deleteButton.visible)
                            end
                        end
                        -- Hide the confirmation window and buttons
                        uiManager:hideElement('main_menu', 'confirmation_window')
                        uiManager:hideElement('main_menu', 'cancel_button')
                        uiManager:hideElement('main_menu', 'confirm_button')
                        uiManager:unfreezeElement('main_menu', 'BackButton')
                    end,
                    css = {
                        backgroundColor = {0.8, 0.3, 0.3},
                        hoverBackgroundColor = {1, 0.5, 0.5},
                        textColor = {1, 1, 1},
                        borderColor = {1, 1, 1}
                    }
                })
                uiManager:registerElement('main_menu', 'cancel_button', cancelButton)
            else
                uiManager:showElement('main_menu', 'cancel_button')
            end
        end,
        css = {
            backgroundColor = {0.8, 0, 0},
            hoverBackgroundColor = {1, 0, 0},
            textColor = {1, 1, 1},
            borderColor = {1, 1, 1},
        },
    })

    local backButton = Button.new({
        text = "[shake=0.4][breathe=0.2]Back[/shake][/breathe]",
        x = 100,
        y = G.WINDOW.HEIGHT - 100,
        w = 200,
        h = 60,
        onClick = function()
            for i = 1, 3 do
                -- Register save slot buttons
                uiManager:removeElement("main_menu", "saveSlot" .. i)
                uiManager:removeElement("main_menu", "deleteButton" .. i)
                
            end
            uiManager:hideElement('main_menu', 'BackButton')
            uiManager:showElement("main_menu", "play")
            uiManager:showElement("main_menu", "quit")
            uiManager:showElement("main_menu", "map")
        end,
        css = {
            backgroundColor = {0.5, 0, 0},
            hoverBackgroundColor = {1, 0, 0},
            textColor = {1, 1, 1},
            borderColor = {1, 1, 1},
            font = G.Fonts.m6x11plus
        }
    })
    uiManager:registerElement('main_menu', 'BackButton', backButton)
    uiManager:hideElement('main_menu', 'BackButton')

    return saveSlotButton, deleteButton
end



function main_menu:load(args)
    ManualtransitionIn() -- i do this cause it is the first scene

    if args and args.from == 'map' then
        for i = 1, 3 do
            local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot'..i)
            if saveSlotButton then
                uiManager:hideElement('main_menu', 'saveSlot'..i)
            end
            uiManager:hideElement('main_menu', 'deleteButton'..i)
        end
        uiManager:hideElement('main_menu', 'BackButton')
    end


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
        borderThickness = 0,
        title = "The Team",
        uiAtlas = G.UiAtlas_Animation,
        font = G.Fonts.m6x11plus_medium,
        visible = false,
        color = {0.5, 0.5, 0.9}
    })
    uiManager:registerElement("main_menu", "SettingsWindow", SettingsWindow)
    uiManager:hideElement("main_menu", "SettingsWindow")
    local play = Button.new({
        text = "[shake=0.4][breathe=0.2]Play[/shake][/breathe]",
        dsfull = false,
        x = 100,
        y = G.WINDOW.HEIGHT - 200,
        w = 200,
        h = 60,
        onClick = function()
            uiManager:hideElement("main_menu", "play")
            uiManager:hideElement("main_menu", "quit")
            uiManager:hideElement("main_menu", "map")
           
            -- Create save slots and delete buttons
            for i = 1, 3 do
                local saveSlot, deleteButton = createSaveSlotButton(i, 300, 200 + (i - 1) * 100)  -- Adjust the Y position for each slot
        
                -- Register save slot buttons
                uiManager:registerElement("main_menu", "saveSlot" .. i, saveSlot)
                
                -- Register delete buttons only if the save slot is not empty
                if saveSlot.text ~= "Empty Slot" then
                    uiManager:registerElement("main_menu", "deleteButton" .. i, deleteButton)
                end
            end
            uiManager:showElement('main_menu', 'BackButton')
        
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
            SettingsWindow:toggle()
            G.METAL_BUTTONS_ICONS_ANIMATIONS.list:gotoFrame(3)
            Timer.after(0.3, function()
                
                G.METAL_BUTTONS_ICONS_ANIMATIONS.list:gotoFrame(1)
            end)
            local sw = uiManager:getElement("main_menu", "SettingsWindow")
            if sw.visible == true then
                for i = 1, 3 do
                    local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot'..i)
                    if saveSlotButton then
                        uiManager:freezeElement('main_menu', 'saveSlot'..i)
                    end
                    uiManager:freezeElement('main_menu', 'deleteButton'..i)
                end
                uiManager:freezeElement('main_menu', 'cancel_button')
                uiManager:freezeElement('main_menu', 'confirm_button')
            else 
                for i = 1, 3 do
                    local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot'..i)
                    if saveSlotButton then
                        uiManager:unfreezeElement('main_menu', 'saveSlot'..i)
                    end
                    uiManager:unfreezeElement('main_menu', 'deleteButton'..i)
                end
                local cb = uiManager:getElement('main_menu', 'cancel_button')
                if cb ~= nil and cb.visible == true then
                    for i = 1, 3 do
                        local saveSlotButton = uiManager:getElement('main_menu', 'saveSlot'..i)
                        if saveSlotButton then
                            uiManager:freezeElement('main_menu', 'saveSlot'..i)
                        end
                        uiManager:freezeElement('main_menu', 'deleteButton'..i)
                    end
                
                end
                uiManager:unfreezeElement('main_menu', 'cancel_button')
                uiManager:unfreezeElement('main_menu', 'confirm_button')
            end
            
        end,
        onHover = function(button)
            G.METAL_BUTTONS_ICONS_ANIMATIONS.list:gotoFrame(2)
        end,
        onUnhover = function(button)
            G.METAL_BUTTONS_ICONS_ANIMATIONS.list:gotoFrame(1)
        end,
        css = {
            backgroundColor = {0, 0, 0, 0},
            hoverBackgroundColor = {0, 0, 0, 0},
            hoverBorderColor = {0, 0, 0, 0},
            textColor = {0, 0, 0, 0},
            font = G.Fonts.m6x11plus
        },
        anim8 = G.METAL_BUTTONS_ICONS_ANIMATIONS.list,
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

    fpsGraph = debugGraph:new('fps', 20, 60, 50, 30, 0.5, 'fps', love.graphics.newFont(16))
    memGraph = debugGraph:new('mem', 20, 80, 50, 30, 0.5, 'mem', love.graphics.newFont(16))
    dtGraph = debugGraph:new('custom', 20, 100, 50, 30, 0.5, 'custom', love.graphics.newFont(16))

    self.pipeline = setupMainMenuPipeline()
end

function main_menu:draw()
    if self.pipeline then
        self.pipeline:run()
    end

    if version == 'dev-mode' and debug == true then
        -- Draw graphs
        fpsGraph:draw()
        memGraph:draw()
        dtGraph:draw()
    end

    if SettingsWindow.visible then
        local nameX = SettingsWindow.x + 20  -- Add padding from left
        local nameY = SettingsWindow.y + 40  -- Start a bit below the top of the window
        local lineHeight = 30  -- Space between names
    
        love.graphics.print("Paul", nameX, nameY)
        love.graphics.print("Thomas", nameX, nameY + lineHeight)
        love.graphics.print("Nassim", nameX, nameY + lineHeight * 2)
        love.graphics.print("Abdelquodousse", nameX, nameY + lineHeight * 3)
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
    fpsGraph:update(dt)
    memGraph:update(dt)
    dtGraph:update(dt, math.floor(dt * 1000))
    dtGraph.label = 'DT: ' .. math.round(dt, 4)
    menu_theme:update(dt)
end

function main_menu:mousepressed(x, y, button)
end

function main_menu:keypressed(key)
    if key == 'x' then
        local play = uiManager:getElement('main_menu', 'play')
        play:setText('FFFF')
    end
    if key == 'f3' then
        debug = not debug
    end

end

return main_menu
