local save_and_load = {}

local bitser = require 'libs/bitser'

local savefile = "savefile.dat"

-- Function to save a collection of objects
function save_and_load.save(data_collection)
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
function save_and_load.load()
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

-- Function to create monsters from data
function save_and_load.createMonstersFromData(data)
    local player = G:createMonster("CROW", data.player.x, data.player.y)
    local monsters = {}

    for i, monster_data in ipairs(data.party_members) do
        local monster = G:createMonster("CROW", monster_data.x, monster_data.y)
        table.insert(monsters, monster)
    end

    return player, monsters
end

return save_and_load