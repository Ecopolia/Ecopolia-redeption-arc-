-- Require necessary modules
require 'version'
require 'misc/commons'
require 'engine/object'

anim8 = require 'libs/anim8/anim8'
ripple = require 'libs/ripple'

local profile = require("engine/profile")
profile.start()

Inky = require("libs/inky")
local scene = Inky.scene()
local pointer = Inky.pointer(scene)

local SceneryInit = require("libs/scenery")
local scenery = SceneryInit("main_menu")

require 'objects/Game'

Text = require("libs/text")
Text.configure.function_command_enable(true)
ButtonManager = require("engine/button_manager")

Timer = require 'libs/hump/timer'

-- love.load is called once at the beginning of the game
function love.load()
    if version == 'dev-mode' then
        local os = love.system.getOS()
        if os ~= 'Linux' then
            love._openConsole()
        end
        love.window.setTitle("Ecopolia (redemption arc) - Dev Mode")
    else
        love.window.setTitle("Ecopolia (redemption arc) - " .. version)
    end
    love.window.setMode(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)
    scenery:load()
end

-- love.update is called continuously and is used to update the game state
-- dt is the time elapsed since the last update
function love.update(dt)
    local mx, my = love.mouse.getX(), love.mouse.getY()
    pointer:setPosition(mx, my)
    scenery:update(dt)
    G:updateTimers(dt)
    G:updateShaders(dt)
end

-- love.draw is called continuously and is used to render the game
function love.draw()
    if (G.ACTIVATE_SHADER) then
        scene:beginFrame()
        love.graphics.setCanvas(G.globalCanvas)
        scenery:draw()
        love.graphics.setCanvas()
        love.graphics.setShader()
        love.graphics.setShader(G.SHADERS['CRT'])
        love.graphics.draw(G.globalCanvas, 0, 0)
        love.graphics.setShader()
        scenery:outsideShaderDraw()
        scene:finishFrame()
    else
        scene:beginFrame()
        scenery:draw()
        scene:finishFrame()
    end

end

-- love.keypressed is called whenever a key is pressed
-- key is the key that was pressed
function love.keypressed(key)
    -- Add key press handling logic here
end

-- love.keyreleased is called whenever a key is released
-- key is the key that was released
function love.keyreleased(key)
    -- Add key release handling logic here
end

-- love.mousemoved is called whenever the mouse is moved
-- x, y are the new coordinates of the mouse
function love.mousemoved(x, y)
end

-- love.mousereleased is called whenever a mouse button is released
-- x, y are the coordinates of the mouse
-- button is the mouse button that was released
function love.mousereleased(x, y, button)
    if button == 1 then
        pointer:raise("release")
    end
end

function love.mousepressed(x, y, button)
    ButtonManager.mousepressed(x, y, button)
    scenery:mousepressed(x, y, button)
end

-- love.quit is called when the game is closed
function love.quit()
    profile.stop()
end