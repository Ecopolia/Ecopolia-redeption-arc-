-- Libraries
deep = require 'libs/deep'
anim8 = require 'libs/anim8'
ripple = require 'libs/ripple'
Timer = require 'libs/hump/timer'
Text = require("libs/text")
sti = require 'libs/sti'
push = require "libs/push"
debugGraph = require 'libs/debugGraph'
bump = require 'libs/bump'
bf = require("libs/breezefield")
Camera = require("libs/hump/camera")
json = require 'libs/json'
ldtk = require 'libs/ldtk'

-- Require necessary modules
require 'version'
require 'misc/commons'
require 'engine/object'
require 'objects/Game'

-- Configuration
Text.configure.function_command_enable(true)

-- Rendering pipeline
Pipeline = require 'engine/render_pipeline'

-- UI and UI components
uiManager = require("engine/ui_manager")
UiElement = require("objects/ui_element")
Window = require('objects/components/window')
Button = require('objects/components/button')
Freeform = require('objects/components/freeform')
Card = require('objects/components/card')
NpcElement = require('objects/components/npc')

-- LoveDialogue for handling dialogue
LoveDialogue = require "libs/LoveDialogue"

-- Profile for performance analysis
local profile = require("engine/profile")
profile.start()

-- Scenery initialization
local SceneryInit = require("libs/scenery")
local scenery = SceneryInit("npc_test")


-- love.load is called once at the beginning of the game
function love.load()
    -- Set window title based on version
    if version == 'dev-mode' then
        local os = love.system.getOS()
        if os ~= 'Linux' then
            love._openConsole()
        end
        love.window.setTitle("Ecopolia (redemption arc) - Dev Mode")
    else
        love.window.setTitle("Ecopolia (redemption arc) - " .. version)
    end

    -- Setup screen resolution
    local FSWidth, FSHeight = love.window.getDesktopDimensions()
    push:setupScreen(G.WINDOW.WIDTH, G.WINDOW.HEIGHT, FSWidth, FSHeight, {fullscreen = false, resizable = true})

    -- Load scenery
    scenery:load()
end

-- love.update is called continuously and is used to update the game state
function love.update(dt)
    scenery:update(dt)
    G:update(dt)
end

-- love.draw is called to render everything
function love.draw()
    scenery:draw()
end

-- love.keypressed is called whenever a key is pressed
function love.keypressed(key)
    scenery:keypressed(key)
end

-- love.keyreleased is called whenever a key is released
function love.keyreleased(key)
    -- Add key release handling logic here (if needed)
end

-- love.mousemoved is called whenever the mouse is moved
function love.mousemoved(x, y)
    x, y = push:toReal(x, y)
    scenery:mousemoved(x, y)
end

-- love.mousepressed is called when a mouse button is pressed
function love.mousepressed(x, y, button)
    uiManager:mousepressed(x, y, button)
    -- scenery:mousepressed(x, y, button)
end

-- love.mousereleased is called when a mouse button is released
function love.mousereleased(x, y, button)

end

-- love.resize is called when the window is resized
function love.resize(w, h)
    return push:resize(w, h)
end

-- love.quit is called when the game is closed
function love.quit()
    profile.report()
    profile.stop()
end
