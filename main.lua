if (love.system.getOS() == 'OS X' ) and (jit.arch == 'arm64' or jit.arch == 'arm') then jit.off() end
i18n = require 'libs/i18n'
config = require 'config'
HEX = require 'systems/HEX'


require 'engine/object'
require 'engine/event'
require 'engine/node'
require 'engine/moveable'
require 'engine/sprite'
require 'game'
require 'globals'
require 'helper_garbage'


-- local SHADERS = {}

-- Initialize tables

Text = require 'libs/text'

function love.load()
  if config.devMode then
    love._openConsole()
  end
  G:start_up()

  -- -- Set the title of the window
  -- love.window.setTitle("EcoPolia (redemption arc)")
  -- love.graphics.setLineStyle("rough")
  
  -- -- Get the base directory of the project
  -- local baseDir = love.filesystem.getSource()

  -- -- Construct the relative paths
  -- local enPath = baseDir .. '/i18n/en.lua'
  -- local frPath = baseDir .. '/i18n/fr.lua'
  -- local soundPath = baseDir .. '/assets/sounds/main_grassland.mp3'

  -- -- Load the language files
  -- i18n.loadFile(enPath)
  -- i18n.loadFile(frPath)

  -- i18n.setLocale('fr')
  sceneCanvas = love.graphics.newCanvas()

  -- loads fonts
  Fonts = {
    default = love.graphics.newFont(16),
    m6x11plus = love.graphics.newFont("ressources/fonts/m6x11plus.ttf", 72)
  }
  -- Enable Advanced Scripting with the [function=lua code] command.
  Text.configure.function_command_enable(true)

  Text.configure.font_table("Fonts")



  text_dev_mode = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = Fonts.default, keep_space_on_line_break=true})
  text_dev_mode:send("dev mode", 320-80, true)

  canvasPixelHeight = sceneCanvas:getPixelHeight()

end

function love.update(dt)
  -- -- Update shader parameters dynamically
  -- SHADERS.background:send("time", love.timer.getTime())
  -- SHADERS.background:send("spin_time", G.TIMERS.BACKGROUND) -- Now using the dynamically calculated value
  -- SHADERS.background:send("colour_1", HEX:HEX("374244")) -- Assuming HEX function is correctly defined
  -- SHADERS.background:send("colour_2", {1, 1, 0, 1}) -- Lighter Green
  -- SHADERS.background:send("colour_3", HEX:HEX("374244")) -- Assuming HEX function is correctly defined
  -- SHADERS.background:send("contrast", 1) -- Example value
  -- SHADERS.background:send("spin_amount", G.ARGS.spin.amount) -- Now using the dynamically calculated value

  -- -- update splash shader
  G.SHADERS['splash']:send('time', G.SANDBOX.vort_time)
  G.SHADERS['splash']:send('vort_speed', G.SANDBOX.vort_speed + 0.4)
  G.SHADERS['splash']:send('colour_1', G.C[G.SANDBOX.col_op[1]])
  G.SHADERS['splash']:send('colour_2', G.C[G.SANDBOX.col_op[2]])
  G.SHADERS['splash']:send('mid_flash', G.SANDBOX.mid_flash)
  G.SHADERS['splash']:send('vort_offset', 0)

  G.SHADERS['CRT']:send('distortion_fac', {1.0 + 0.07*G.SETTINGS.GRAPHICS.crt/100, 1.0 + 0.1*G.SETTINGS.GRAPHICS.crt/100})
  G.SHADERS['CRT']:send('scale_fac', {1.0 - 0.008*G.SETTINGS.GRAPHICS.crt/100, 1.0 - 0.008*G.SETTINGS.GRAPHICS.crt/100})
  G.SHADERS['CRT']:send('feather_fac', 0.01)
  G.SHADERS['CRT']:send('bloom_fac', G.SETTINGS.GRAPHICS.bloom - 1)
  G.SHADERS['CRT']:send('time', 400 + G.TIMERS.REAL)
  G.SHADERS['CRT']:send('noise_fac', 0.001*G.SETTINGS.GRAPHICS.crt/100)
  G.SHADERS['CRT']:send('crt_intensity', 0.16*G.SETTINGS.GRAPHICS.crt/100)
  G.SHADERS['CRT']:send('glitch_intensity', 1)
  G.SHADERS['CRT']:send('scanlines', canvasPixelHeight*0.75/1)
  G.SHADERS['CRT']:send('screen_scale', G.TILESCALE*G.TILESIZE)
  G.SHADERS['CRT']:send('hovering', 1)

  G.SANDBOX.vort_time = G.SANDBOX.vort_time + dt

  if G.text_ecopolia then G.text_ecopolia:update(dt) end
  timer_checkpoint(nil, 'update', true)
  G:update(dt)
end

function love.draw()
  timer_checkpoint(nil, 'draw', true)
  -- Set the canvas to draw off-screen
  love.graphics.setCanvas(sceneCanvas)
  love.graphics.clear()

  -- Apply background shader and draw the scene
  -- love.graphics.setShader(SHADERS.background)
  love.graphics.setShader(G.SHADERS['splash'])
  local windowWidth, windowHeight = love.graphics.getDimensions()
  love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

  -- Reset shader and canvas to draw to the screen
  love.graphics.setShader()
  love.graphics.setCanvas()

  

  -- Apply CRT shader and draw the canvas to the screen
  love.graphics.setShader(G.SHADERS['CRT'])
  love.graphics.draw(sceneCanvas, 0, 0)

  -- Reset shader after drawing
  love.graphics.setShader()

  -- Draw "ECOPOLIA" in the middle of the screen
  if G.text_ecopolia then
    G.text_ecopolia:draw(windowWidth / 2 - love.graphics.getFont():getWidth("ECOPOLIA") / 2, windowHeight / 2 - love.graphics.getFont():getHeight() / 2)
  end
  if config.devMode then
    -- Draw "dev mode" banner in the top left corner
    text_dev_mode:draw(10, 10)
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
