local save_and_load = {}

local bitser = require 'libs/bitser'

local function getSaveFileName(slot)
    return "savefile_slot" .. tostring(slot) .. ".dat"
end

-- Function to save a collection of objects
function save_and_load.save(player, slot, playtime, zone)
    local savefile = getSaveFileName(slot)
    local data_collection = {
        x = player.x,
        y = player.y,
        speed = player.speed,
        health = player.health,
        sprite = "assets/spritesheets/character/maincharacter.png",
        playtime = playtime or 0,
        zone = zone or "Unknown"
    }

    local binary_data = bitser.dumps(data_collection)
    local file = io.open(savefile, "wb")

    if file then
        file:write(binary_data)
        file:close()

        print("Data saved to " .. savefile)
    else
        print("Failed to open file for writing")
    end
end

-- Function to load a collection of objects
function save_and_load.load(slot)
    local savefile = getSaveFileName(slot)
    local file = io.open(savefile, "rb")

    if file then
        local binary_data = file:read("*all")
        file:close()

        local data_collection = bitser.loads(binary_data)
        print("Data loaded from " .. savefile)

        return data_collection
    else
        print("Failed to open file for reading")
        return nil
    end
end

return save_and_load