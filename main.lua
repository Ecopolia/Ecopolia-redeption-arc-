if (love.system.getOS() == 'OS X' ) and (jit.arch == 'arm64' or jit.arch == 'arm') then jit.off() end
i18n = require 'libs/i18n'
config = require 'config'

local SHADERS = {}

function HEX(hex)
  if #hex <= 6 then hex = hex.."FF" end
  local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
  local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
  return color
end

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

end


function love.update(dt)
  SHADERS.background:send("time", love.timer.getTime())
  SHADERS.background:send("spin_time", 0) -- Example value
  SHADERS.background:send("colour_1", HEX("374244")) -- Green
  SHADERS.background:send("colour_2", {1,1,0,1}) -- Lighter Green
  SHADERS.background:send("colour_3", HEX("374244")) -- Darker Green
  SHADERS.background:send("contrast", 1) -- Example value
  SHADERS.background:send("spin_amount", 1) -- Example value
end

function love.draw()
  -- Set the font and font size
  love.graphics.setFont(love.graphics.newFont(24))

  -- Get the dimensions of the window
  local windowWidth, windowHeight = love.graphics.getDimensions()

  -- Set the shader
  love.graphics.setShader(SHADERS.background)

  -- Draw a fullscreen rectangle
  love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

  -- Reset to default shader for other drawing operations
  love.graphics.setShader()

  -- Draw "ECOPOLIA" in the middle of the screen
  local text = "ECOPOLIA"
  local textWidth = love.graphics.getFont():getWidth(text)
  local textHeight = love.graphics.getFont():getHeight()
  local textX = windowWidth / 2 - textWidth / 2
  local textY = windowHeight / 2 - textHeight / 2
  love.graphics.print(text, textX, textY)

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