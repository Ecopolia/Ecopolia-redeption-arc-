Game = Object:extend()

--Class Methods
function Game:init()
    G = self
    self:set_globals()
end

function Game:start_up()

    self:init_window()

    self.SHADERS = {}
    local shader_files = love.filesystem.getDirectoryItems("ressources/shaders")
    for k, filename in ipairs(shader_files) do
        local extension = string.sub(filename, -3)
        if extension == '.fs' then
            local shader_name = string.sub(filename, 1, -4)
            self.SHADERS[shader_name] = love.graphics.newShader("ressources/shaders/"..filename)
        end
    end
    self:set_render_settings()
    self.E_MANAGER = EventManager()
    self.SPEEDFACTOR = 1
    self:splash_screen()
    
end

function Game:init_game_object()
    -- should reset the game variables if you need

end

function Game:init_window(reset)
    --Initialize the window
    self.ROOM_PADDING_H= 0.7
    self.ROOM_PADDING_W = 1
    self.WINDOWTRANS = {
        x = 0, y = 0,
        w = self.TILE_W+2*self.ROOM_PADDING_W, 
        h = self.TILE_H+2*self.ROOM_PADDING_H
    }
    self.window_prev = {
        orig_scale = self.TILESCALE,
        w=self.WINDOWTRANS.w*self.TILESIZE*self.TILESCALE,
        h=self.WINDOWTRANS.h*self.TILESIZE*self.TILESCALE,
        orig_ratio = self.WINDOWTRANS.w*self.TILESIZE*self.TILESCALE/(self.WINDOWTRANS.h*self.TILESIZE*self.TILESCALE)}
    G.SETTINGS.QUEUED_CHANGE = G.SETTINGS.QUEUED_CHANGE or {}
    G.SETTINGS.QUEUED_CHANGE.screenmode = G.SETTINGS.WINDOW.screenmode
    
    -- G.FUNCS.apply_window_changes(true) TODO:implement this function
end

function Game:set_render_settings()
    self.SETTINGS.GRAPHICS.texture_scaling = self.SETTINGS.GRAPHICS.texture_scaling or 2

    --Set fiter to linear interpolation and nearest, best for pixel art
    love.graphics.setDefaultFilter(
        self.SETTINGS.GRAPHICS.texture_scaling == 1 and 'nearest' or 'linear',
        self.SETTINGS.GRAPHICS.texture_scaling == 1 and 'nearest' or 'linear', 1)

    love.graphics.setLineStyle("rough")

    --spritesheets
    self.animation_atli = {}

    self.asset_atli = {
        {name = 'none', path = "ressources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/none.png",px=1,py=1, type = 'none'},
        {name = 'icons', path = "ressources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/icons.png",px=66,py=66},  
        {name = 'gamepad_ui', path = "ressources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/gamepad_ui.png",px=32,py=32},
    }
    self.asset_images = {}

    --Load in all atli defined above
    for i=1, #self.animation_atli do
        self.ANIMATION_ATLAS[self.animation_atli[i].name] = {}
        self.ANIMATION_ATLAS[self.animation_atli[i].name].name = self.animation_atli[i].name
        self.ANIMATION_ATLAS[self.animation_atli[i].name].image = love.graphics.newImage(self.animation_atli[i].path, {mipmaps = true, dpiscale = self.SETTINGS.GRAPHICS.texture_scaling})
        self.ANIMATION_ATLAS[self.animation_atli[i].name].px = self.animation_atli[i].px
        self.ANIMATION_ATLAS[self.animation_atli[i].name].py = self.animation_atli[i].py
        self.ANIMATION_ATLAS[self.animation_atli[i].name].frames = self.animation_atli[i].frames
    end

    for i=1, #self.asset_atli do
        self.ASSET_ATLAS[self.asset_atli[i].name] = {}
        self.ASSET_ATLAS[self.asset_atli[i].name].name = self.asset_atli[i].name
        self.ASSET_ATLAS[self.asset_atli[i].name].image = love.graphics.newImage(self.asset_atli[i].path, {mipmaps = true, dpiscale = self.SETTINGS.GRAPHICS.texture_scaling})
        self.ASSET_ATLAS[self.asset_atli[i].name].type = self.asset_atli[i].type
        self.ASSET_ATLAS[self.asset_atli[i].name].px = self.asset_atli[i].px
        self.ASSET_ATLAS[self.asset_atli[i].name].py = self.asset_atli[i].py
    end
    for i=1, #self.asset_images do
        self.ASSET_ATLAS[self.asset_images[i].name] = {}
        self.ASSET_ATLAS[self.asset_images[i].name].name = self.asset_images[i].name
        self.ASSET_ATLAS[self.asset_images[i].name].image = love.graphics.newImage(self.asset_images[i].path, {mipmaps = true, dpiscale = 1})
        self.ASSET_ATLAS[self.asset_images[i].name].type = self.asset_images[i].type
        self.ASSET_ATLAS[self.asset_images[i].name].px = self.asset_images[i].px
        self.ASSET_ATLAS[self.asset_images[i].name].py = self.asset_images[i].py
    end

    for _, v in pairs(G.I.SPRITE) do
        v:reset()
    end
end

function Game:prep_stage(new_stage, new_state, new_game_obj)

    if new_game_obj then self.GAME = self:init_game_object() end
    self.STAGE = new_stage or self.STAGES.MAIN_MENU
    self.STATE = new_state or self.STATES.MENU
    self.STATE_COMPLETE = false
    self.SETTINGS.paused = false

    self.ROOM = Node{T={
        x = self.ROOM_PADDING_W,
        y = self.ROOM_PADDING_H,
        w = self.TILE_W,
        h = self.TILE_H}
    }
    self.ROOM.jiggle = 0
    self.ROOM.states.drag.can = false
    self.ROOM:set_container(self.ROOM)

    self.ROOM_ATTACH = Moveable{T={
        x = 0,
        y = 0,
        w = self.TILE_W,
        h = self.TILE_H}
    }
    self.ROOM_ATTACH.states.drag.can = false
    self.ROOM_ATTACH:set_container(self.ROOM)
end

function Game:splash_screen()
    G.text_ecopolia = nil
    self:prep_stage(G.STAGES.MAIN_MENU, G.STATES.SPLASH, true)
    self.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            print("Event 1 triggered!")
            G.TIMERS.TOTAL = 0
            G.TIMERS.REAL = 0
            --Prep the splash screen shaders for both the background(colour swirl) and the foreground(white flash), starting at black
            G.SPLASH_BACK = Sprite(-30, -13, G.ROOM.T.w+60, G.ROOM.T.h+22, G.ASSET_ATLAS["none"], {x = 2, y = 0})
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL'},
                    {name = 'vort_speed', val = 1},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'DARK_GREEN'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'LIGHT_GREEN'},
                    {name = 'mid_flash', val = G.SANDBOX.mid_flash},
                    {name = 'vort_offset', val = 0},
                }}})
            G.SPLASH_BACK:set_alignment({
                major = G.ROOM_ATTACH,
                type = 'cm',
                offset = {x=0,y=0}
            }) 

        return true
    end)
    }))

    self.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            print("Event 2 triggered!")
            G.text_ecopolia = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = Fonts.m6x11plus, keep_space_on_line_break=true,})
            G.text_ecopolia:send("[shake=3][breathe=3]ECOPOLIA [blink]|[/blink][/breathe][/shake]", 320, false)
        return true
    end)
    }))
end

function Game:update(dt)
    nuGC(nil, nil, true)

    G.MAJORS = 0
    G.MINORS = 0

    G.FRAMES.MOVE = G.FRAMES.MOVE + 1
    timer_checkpoint('start->discovery', 'update')

    update_canvas_juice(dt)
    timer_checkpoint('canvas and juice', 'update')
    --Smooth out the dts to avoid any big jumps
    self.TIMERS.REAL = self.TIMERS.REAL + dt
    self.TIMERS.REAL_SHADER = G.SETTINGS.reduced_motion and 300 or self.TIMERS.REAL
    self.TIMERS.UPTIME = self.TIMERS.UPTIME + dt
    self.TIMERS.BACKGROUND = self.TIMERS.BACKGROUND + dt*(G.ARGS.spin and G.ARGS.spin.amount or 0)
    self.real_dt = dt

    if self.real_dt > 0.05 then print('LONG DT @ '..math.floor(G.TIMERS.REAL)..': '..self.real_dt) end
    if not G.fbf or G.new_frame then
        G.new_frame = false

    -- set_alerts()
    -- timer_checkpoint('alerts', 'update')

    if G.SETTINGS.paused then dt = 0 end

        if G.STATE ~= G.ACC_state then G.ACC = 0 end
        G.ACC_state = G.STATE

        if (G.STATE == G.STATES.HAND_PLAYED) or (G.STATE == G.STATES.NEW_ROUND) then 
            G.ACC = math.min((G.ACC or 0) + dt*0.2*self.SETTINGS.GAMESPEED, 16)
        else
            G.ACC = 0
        end

        self.SPEEDFACTOR = (G.STAGE == G.STAGES.RUN and not G.SETTINGS.paused and not G.screenwipe) and self.SETTINGS.GAMESPEED or 1
        self.SPEEDFACTOR = self.SPEEDFACTOR + math.max(0, math.abs(G.ACC) - 2)

        self.TIMERS.TOTAL = self.TIMERS.TOTAL + dt*(self.SPEEDFACTOR)
        
        self.E_MANAGER:update(self.real_dt)
        timer_checkpoint('e_manager', 'update')

    
        if self.STATE == self.STATES.GAME_OVER then
            -- self:update_game_over(dt)
        end

        if self.STATE == self.STATES.MENU then
            self:update_menu(dt)
        end
        timer_checkpoint('states', 'update')


        --move and update all other moveables
        G.exp_times.xy = math.exp(-50*self.real_dt)
        G.exp_times.scale = math.exp(-60*self.real_dt)
        G.exp_times.r = math.exp(-190*self.real_dt)
        
        local move_dt = math.min(1/20, self.real_dt)

        G.exp_times.max_vel = 70*move_dt
        
        for k, v in pairs(self.MOVEABLES) do
            if v.FRAME.MOVE < G.FRAMES.MOVE then v:move(move_dt) end
        end
        timer_checkpoint('move', 'update')
        
        for k, v in pairs(self.MOVEABLES) do
            v:update(dt*self.SPEEDFACTOR)
            v.states.collide.is = false
        end
        timer_checkpoint('update', 'update')
    end
    
end

function Game:draw()
    timer_checkpoint(nil, 'draw', true)
    -- Set the canvas to draw off-screen
    love.graphics.setCanvas(sceneCanvas)
    love.graphics.clear()

    -- Apply background shader and draw the scene
    -- love.graphics.setShader(SHADERS.background)
    -- love.graphics.setShader(G.SHADERS['splash'])

    local windowWidth, windowHeight = love.graphics.getDimensions()
    -- love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

    -- Reset shader and canvas to draw to the screen
    love.graphics.setShader()
    love.graphics.setCanvas()

    -- Apply CRT shader and draw the canvas to the screen
    love.graphics.setShader(G.SHADERS['CRT'])

    love.graphics.draw(sceneCanvas, 0, 0)

    -- Reset shader after drawing
    -- love.graphics.setShader()

    -- Draw "ECOPOLIA" in the middle of the screen
    if G.text_ecopolia then
        G.text_ecopolia:draw(windowWidth / 2 -
                                 love.graphics.getFont():getWidth("ECOPOLIA") /
                                 2, windowHeight / 2 -
                                 love.graphics.getFont():getHeight() / 2)
    end
    if config.devMode then
        -- Draw "dev mode" banner in the top left corner
        text_dev_mode:draw(10, 10)
    end

end


