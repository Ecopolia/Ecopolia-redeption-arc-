-- Require necessary modules
require 'version'
require 'misc/commons'
require 'engine/object'

Pipeline = require 'engine/render_pipeline'

anim8 = require 'libs/anim8'
ripple = require 'libs/ripple'

local profile = require("engine/profile")
profile.start()

Inky = require("libs/inky")
local scene = Inky.scene()
local pointer = Inky.pointer(scene)

require 'objects/Game'
Timer = require 'libs/hump/timer'

Text = require("libs/text")
Text.configure.function_command_enable(true)
deep = require 'libs/deep'
uiManager = require("engine/ui_manager")

UiElement = require("objects/ui_element")
Window = require('objects/components/window')
Button = require('objects/components/button')
Freeform = require('objects/components/freeform')

local SceneryInit = require("libs/scenery")
local scenery = SceneryInit("template")

LoveDialogue = require "libs/LoveDialogue"

sti = require 'libs/sti'



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
    local FSWidth, FSHeight = love.window.getDesktopDimensions()
    push:setupScreen(G.WINDOW.WIDTH, G.WINDOW.HEIGHT, FSWidth, FSHeight, {fullscreen = false , resizable = true})
    scenery:load()
end

-- love.update is called continuously and is used to update the game state
-- dt is the time elapsed since the last update
function love.update(dt)
    scenery:update(dt)
    G:update(dt)
end

function love.draw()
    scenery:draw()
end

-- love.keypressed is called whenever a key is pressed
-- key is the key that was pressed
function love.keypressed(key)
    -- Add key press handling logic here
    scenery:keypressed(key)
end

-- love.keyreleased is called whenever a key is released
-- key is the key that was released
function love.keyreleased(key)
    -- Add key release handling logic here
end

-- love.mousemoved is called whenever the mouse is moved
-- x, y are the new coordinates of the mouse
function love.mousemoved(x, y)
    x, y = push:toReal(x, y)
    scenery:mousemoved(x,y)
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
    uiManager:mousepressed(x, y, button)
    -- scenery:mousepressed(x, y, button)
end

function love.resize(w, h)
    return push:resize(w, h)
end

-- love.quit is called when the game is closed
function love.quit()
    profile.stop()
end