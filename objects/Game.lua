Game = Object:extend()

--Class Methods
function Game:init()
    G = self
    self:set_globals()
    print('Game object initialized')
end

function Game:set_globals()
    self.WINDOW = {
        WIDTH = 1280,
        HEIGHT = 720
    }

    self.globalCanvas = love.graphics.newCanvas(self.WINDOW.WIDTH, self.WINDOW.HEIGHT)
    self.canvasPixelHeight = self.globalCanvas:getPixelHeight()
    self.TILESIZE = 20
    self.TILESCALE = 3.65
    self.SETTINGS = {
        GRAPHICS = {
            texture_scaling = 2,
            shadows = 'On',
            crt = 70,
            bloom = 1
        }
    }
    self.TIMERS = {
        TOTAL=0,
        REAL_SHADER = 0,
        BACKGROUND = 0,
        REAL = 0,
        UPTIME = 0,
    }

    self.SHADERS = {}
    local shader_files = love.filesystem.getDirectoryItems("resources/shaders")
    for k, filename in ipairs(shader_files) do
        local extension = string.sub(filename, -3)
        if extension == '.fs' then
            local shader_name = string.sub(filename, 1, -4)
            self.SHADERS[shader_name] = love.graphics.newShader("resources/shaders/"..filename)
        end
    end

    self.Fonts = {
        default = love.graphics.newFont(16),
        m6x11plus = love.graphics.newFont("resources/fonts/m6x11plus.ttf", 72),
        m6x11plus_medium = love.graphics.newFont("resources/fonts/m6x11plus.ttf", 24)
    }

    self.ACTIVATE_SHADER = true
    
    self.ROOT_PATH = love.filesystem.getSource()

    self.TRANSITION = 0
    self.TRANSITION_DURATION = 2

    self.METAL_BUTTONS_ICONS_IMAGE = love.graphics.newImage("assets/spritesheets/buttons/metal_buttons_icons.png")
    self.METAL_BUTTONS_ICONS_GRID = anim8.newGrid(32, 32, self.METAL_BUTTONS_ICONS_IMAGE:getWidth(), self.METAL_BUTTONS_ICONS_IMAGE:getHeight())

    self.METAL_BUTTONS_ICONS_ANIMATIONS ={
        settings = anim8.newAnimation(self.METAL_BUTTONS_ICONS_GRID('10-12', 2), 0.1, 'pauseAtStart'),
        music = anim8.newAnimation(self.METAL_BUTTONS_ICONS_GRID('7-9', 8), 0.1, 'pauseAtStart'),
        close = anim8.newAnimation(self.METAL_BUTTONS_ICONS_GRID('7-9', 4), 0.1, 'pauseAtStart'),
    }

    self.UiAtlas = love.graphics.newImage("assets/spritesheets/ui.png")
    self.UiAtlasGrid = anim8.newGrid(32, 32, self.UiAtlas:getWidth(), self.UiAtlas:getHeight())

    self.UiAtlas_Animation = {
        blueTopLeftCorner = anim8.newAnimation(self.UiAtlasGrid(2, 2), 0.1, 'pauseAtStart'),
        blueTop = anim8.newAnimation(self.UiAtlasGrid(3, 2), 0.1, 'pauseAtStart'),
        blueTopRightCorner = anim8.newAnimation(self.UiAtlasGrid(4, 2), 0.1, 'pauseAtStart'),
        blueLeft = anim8.newAnimation(self.UiAtlasGrid(2, 3), 0.1, 'pauseAtStart'),
        blueMiddle = anim8.newAnimation(self.UiAtlasGrid(3, 3), 0.1, 'pauseAtStart'),
        blueRight = anim8.newAnimation(self.UiAtlasGrid(4, 3), 0.1, 'pauseAtStart'),
        blueBottomLeftCorner = anim8.newAnimation(self.UiAtlasGrid(2, 4), 0.1, 'pauseAtStart'),
        blueBottom = anim8.newAnimation(self.UiAtlasGrid(3, 4), 0.1, 'pauseAtStart'),
        blueBottomRightCorner = anim8.newAnimation(self.UiAtlasGrid(4, 4), 0.1, 'pauseAtStart'),

        titleWithBottomDropShadowLeftCorner = anim8.newAnimation(self.UiAtlasGrid(14, 4), 0.1, 'pauseAtStart'),
        titleWithBottomDropShadowMiddle = anim8.newAnimation(self.UiAtlasGrid(15, 4), 0.1, 'pauseAtStart'),
        titleWithBottomDropShadowRightCorner = anim8.newAnimation(self.UiAtlasGrid(16, 4), 0.1, 'pauseAtStart'),
    }

end

function Game:updateShaders(dt)
    self.SHADERS['CRT']:send('distortion_fac', {
        1.0 + 0.07 * self.SETTINGS.GRAPHICS.crt / 100,
        1.0 + 0.1 * self.SETTINGS.GRAPHICS.crt / 100
    })
    self.SHADERS['CRT']:send('scale_fac', {
        1.0 - 0.008 * self.SETTINGS.GRAPHICS.crt / 100,
        1.0 - 0.008 * self.SETTINGS.GRAPHICS.crt / 100
    })
    self.SHADERS['CRT']:send('feather_fac', 0.01)
    self.SHADERS['CRT']:send('bloom_fac', self.SETTINGS.GRAPHICS.bloom - 1)
    self.SHADERS['CRT']:send('time', 400 + self.TIMERS.REAL)
    self.SHADERS['CRT']:send('noise_fac', 0.001 * self.SETTINGS.GRAPHICS.crt / 100)
    self.SHADERS['CRT']:send('crt_intensity', 0.16 * self.SETTINGS.GRAPHICS.crt / 100)
    self.SHADERS['CRT']:send('glitch_intensity', 1)
    self.SHADERS['CRT']:send('scanlines', self.canvasPixelHeight * 0.75 / 1)
    self.SHADERS['CRT']:send('screen_scale', self.TILESCALE * self.TILESIZE)
    self.SHADERS['CRT']:send('hovering', 1)

    self.SHADERS['CRT']:send('transition_amount', G.TRANSITION)

    self.SHADERS['watercolor']:send('scale_fac', {
        1.0 - 0.008 * self.SETTINGS.GRAPHICS.crt / 100,
        1.0 - 0.008 * self.SETTINGS.GRAPHICS.crt / 100
    })
    self.SHADERS['watercolor']:send('noise_fac', 0.001 * self.SETTINGS.GRAPHICS.crt / 100)
    
    -- This uniform controls the radius of the transition effect
    self.SHADERS['watercolor']:send('transition_amount', G.TRANSITION)

    self.SHADERS['toon']:send('scale_fac', {
        1.0 - 0.008 * self.SETTINGS.GRAPHICS.crt / 100,
        1.0 - 0.008 * self.SETTINGS.GRAPHICS.crt / 100
    })
    self.SHADERS['toon']:send('edge_threshold', 1.8)  -- Adjust this value to control edge detection sensitivity
    
    -- This uniform controls the radius of the transition effect
    self.SHADERS['toon']:send('transition_amount', G.TRANSITION)
end

function Game:updateTimers(dt)
    self.TIMERS.REAL = self.TIMERS.REAL + dt
    self.TIMERS.REAL_SHADER = self.TIMERS.REAL
    self.TIMERS.UPTIME = self.TIMERS.UPTIME + dt
    self.real_dt = dt
    Timer.update(dt)
end

function Game:updateAnimation(dt)
    for _, animation in pairs(self.METAL_BUTTONS_ICONS_ANIMATIONS) do
        animation:update(dt)
    end
end

function Game:update(dt)
    self:updateAnimation(dt)
    self:updateTimers(dt)
    self:updateShaders(dt)
end

G = Game()