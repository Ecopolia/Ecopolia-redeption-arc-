local save_scene = {}
local save_and_load = require 'engine/save_and_load'

local loaded_data = save_and_load.load()
local player, monsters

if loaded_data ~= nil then
    player, monsters = save_and_load.createMonstersFromData(loaded_data)
else
    player = G:createMonster("CROW", 800, 200)
    monsters = {G:createMonster("CROW", 100, 200)}
end
save_data = {
    player = player,
    party_members = {monsters},   
}

function save_scene:load()

end

function save_scene:draw()
    -- Clear the screen with black color
    love.graphics.clear(0, 0, 0, 1)

    -- Draw the background
    love.graphics.draw(bg, 0, 0, 0, G.WINDOW.WIDTH / bg:getWidth(), G.WINDOW.HEIGHT / bg:getHeight())

    if player then
        G.MONSTERS.CROW.animations.idle:draw(G.MONSTERS.CROW.images.idle, player.x, player.y, 0, 7, 7, 0, 0)
    end
    for _, monster in ipairs(monsters) do
        G.MONSTERS.CROW.animations.idle:draw(G.MONSTERS.CROW.images.idle, monster.x, monster.y, 0, 7, 7, 0, 0)
    end

    uiManager:draw("save_scene")
end

-- Temporary function to handle mouse press events before we have a proper moving engine
function save_scene:update(dt)
    if love.keyboard.isDown("t") then
        save_and_load.save(save_data)
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + 1
    end
    if love.keyboard.isDown("z") then
        player.y = player.y - 1
    end
    if love.keyboard.isDown("q") then
        player.x = player.x - 1
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + 1
    end

end

return save_scene   