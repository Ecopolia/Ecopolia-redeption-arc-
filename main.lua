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

uiManager = require("engine/ui_manager")

UiElement = require("objects/ui_element")
Window = require('objects/components/window')
Button = require('objects/components/button')

local SceneryInit = require("libs/scenery")
local scenery = SceneryInit("main_menu")

LoveDialogue = require "libs/LoveDialogue"

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
    G:update(dt)
end

function love.draw()
    scene:beginFrame()
    scenery:draw()
    scene:finishFrame()
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
    scenery:mousepressed(x, y, button)
end

-- love.quit is called when the game is closed
function love.quit()
    profile.stop()
end