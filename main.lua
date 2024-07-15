if (love.system.getOS() == 'OS X' ) and (jit.arch == 'arm64' or jit.arch == 'arm') then jit.off() end
i18n = require 'libs/i18n'
config = require 'config'
require 'engine/text'


local SHADERS = {}

-- Initialize tables
G = require 'globals'
HEX = require 'systems/HEX'

function love.load()
  love.window.setTitle("EcoPolia (redemption arc)")
  
  -- Get the base directory of the project
  local baseDir = love.filesystem.getSource()

  -- Construct the relative paths
  local enPath = baseDir .. '/i18n/en.lua'
  local frPath = baseDir .. '/i18n/fr.lua'
  local soundPath = baseDir .. '/assets/sounds/main_grassland.mp3'

  -- Load the language files
  i18n.loadFile(enPath)
  i18n.loadFile(frPath)

  i18n.setLocale('fr')

  --Load all shaders from resources
  SHADERS.background = love.graphics.newShader("ressources/shaders/background.fs")
  SHADERS.CRT = love.graphics.newShader("ressources/shaders/CRT.fs")
  SHADERS.splash = love.graphics.newShader("ressources/shaders/splash.fs")
  sceneCanvas = love.graphics.newCanvas()
end

function love.update(dt)
  -- Calculate _dt based on the condition provided
  local _dt = G.ARGS.spin.amount > G.ARGS.spin.eased and dt*2. or 0.3*dt
  local delta = G.ARGS.spin.real - G.ARGS.spin.eased
  if math.abs(delta) > _dt then delta = delta * _dt / math.abs(delta) end
  G.ARGS.spin.eased = G.ARGS.spin.eased + delta
  G.ARGS.spin.amount = _dt * (G.ARGS.spin.eased) + (1 - _dt) * G.ARGS.spin.amount
  G.TIMERS.BACKGROUND = G.TIMERS.BACKGROUND - 60 * (G.ARGS.spin.eased - G.ARGS.spin.amount) * _dt

  -- Update shader parameters dynamically
  SHADERS.background:send("time", love.timer.getTime())
  SHADERS.background:send("spin_time", G.TIMERS.BACKGROUND) -- Now using the dynamically calculated value
  SHADERS.background:send("colour_1", HEX:HEX("374244")) -- Assuming HEX function is correctly defined
  SHADERS.background:send("colour_2", {1, 1, 0, 1}) -- Lighter Green
  SHADERS.background:send("colour_3", HEX:HEX("374244")) -- Assuming HEX function is correctly defined
  SHADERS.background:send("contrast", 1) -- Example value
  SHADERS.background:send("spin_amount", G.ARGS.spin.amount) -- Now using the dynamically calculated value
end

function love.draw()
  -- Set the font and font size
  love.graphics.setFont(love.graphics.newFont(24))

  -- Set the canvas to draw off-screen
  love.graphics.setCanvas(sceneCanvas)
  love.graphics.clear()

  -- update splash shader
  SHADERS.splash:send('time', G.SANDBOX.vort_time)
  SHADERS.splash:send('vort_speed', G.SANDBOX.vort_speed + 0.4)
  SHADERS.splash:send('colour_1', G.C[G.SANDBOX.col_op[1]])
  SHADERS.splash:send('colour_2', G.C[G.SANDBOX.col_op[2]])
  SHADERS.splash:send('mid_flash', G.SANDBOX.mid_flash)
  SHADERS.splash:send('vort_offset', 0)

  -- Apply background shader and draw the scene
   love.graphics.setShader(SHADERS.background)
  -- love.graphics.setShader(SHADERS.splash)
  local windowWidth, windowHeight = love.graphics.getDimensions()
  love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

  -- Reset shader and canvas to draw to the screen
  love.graphics.setShader()
  love.graphics.setCanvas()

  canvasPixelHeight = sceneCanvas:getPixelHeight()

  -- Update CRT shader parameters
  -- Assuming G.SETTINGS, G.TIMERS, and other necessary variables are already updated
  SHADERS.CRT:send('distortion_fac', {1.0 + 0.07*G.SETTINGS.GRAPHICS.crt/100, 1.0 + 0.1*G.SETTINGS.GRAPHICS.crt/100})
  SHADERS.CRT:send('scale_fac', {1.0 - 0.008*G.SETTINGS.GRAPHICS.crt/100, 1.0 - 0.008*G.SETTINGS.GRAPHICS.crt/100})
  SHADERS.CRT:send('feather_fac', 0.01)
  SHADERS.CRT:send('bloom_fac', G.SETTINGS.GRAPHICS.bloom - 1)
  SHADERS.CRT:send('time', 400 + G.TIMERS.REAL)
  SHADERS.CRT:send('noise_fac', 0.001*G.SETTINGS.GRAPHICS.crt/100)
  SHADERS.CRT:send('crt_intensity', 0.16*G.SETTINGS.GRAPHICS.crt/100)
  SHADERS.CRT:send('glitch_intensity', 0)
  SHADERS.CRT:send('scanlines', canvasPixelHeight*0.75/1)
  SHADERS.CRT:send('screen_scale', G.TILESCALE*G.TILESIZE)
  SHADERS.CRT:send('hovering', 1)
  -- Apply CRT shader and draw the canvas to the screen
  love.graphics.setShader(SHADERS['CRT'])
  love.graphics.draw(sceneCanvas, 0, 0)

  -- Reset shader after drawing
  love.graphics.setShader()

  -- Draw "ECOPOLIA" in the middle of the screen
  -- local textWidth = love.graphics.getFont():getWidth(text)
  -- local textHeight = love.graphics.getFont():getHeight()
  -- local textX = windowWidth / 2 - textWidth / 2
  -- local textY = windowHeight / 2 - textHeight / 2
  -- love.graphics.print(text, textX, textY)
  -- DynaText({string = text, colours = {G.C.WHITE},shadow = true, rotate = true, float = true, bump = true, scale = 0.9, spacing = 1, pop_in = 4.5})
  local text = DynaText({
    string = "ECOPOLIA",
    font = love.graphics.newFont(24),
    scale = 1,
    colours = {1, 1, 1, 1},
    X = 100,
    Y = 200
  })
  text:draw()
  if config.devMode then
    -- Draw "dev mode" banner in the top left corner
    local devModeText = "dev mode"
    local devModeTextWidth = love.graphics.getFont():getWidth(devModeText)
    local devModeTextHeight = love.graphics.getFont():getHeight()
    local devModeTextX = 10
    local devModeTextY = 10
    love.graphics.print(devModeText, devModeTextX, devModeTextY)
  end
end

function love.keypressed(key)
  -- grid.keysPressed[key] = true
end

function love.keyreleased(key)
  -- grid.keysPressed[key] = false

end
function love.mousemoved(x, y)
  -- grid:updateMousePosition(x, y)
end