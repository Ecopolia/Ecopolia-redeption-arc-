i18n = require 'libs/i18n'


function love.load()
  love.window.setTitle("LuaPolia (redemption arc)")
  
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

end


function love.update(dt)

end

function love.draw()

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