Game = Object:extend()

--Class Methods
function Game:init()
    G = self
    self:set_globals()
    print('Game object initialized')
end

function Game:set_globals()
    self.globalCanvas = love.graphics.newCanvas()
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
        m6x11plus = love.graphics.newFont("resources/fonts/m6x11plus.ttf", 72)
    }

    self.ACTIVATE_SHADER = true
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
end

function Game:updateTimers(dt)
    self.TIMERS.REAL = self.TIMERS.REAL + dt
    self.TIMERS.REAL_SHADER = self.TIMERS.REAL
    self.TIMERS.UPTIME = self.TIMERS.UPTIME + dt
    self.real_dt = dt
end


G = Game()