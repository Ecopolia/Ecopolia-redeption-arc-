local save_and_load = {}

local bitser = require 'libs/bitser'

local savefile = "savefile.dat"

-- Function to save a collection of objects
function save_and_load.save(player)
    local data_collection = {
        x = player.position.x,
        y = player.position.y,
        speed = player.speed,
        health = player.health,
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
function save_and_load.load()
    local file = io.open(savefile, "rb")

    if file then
        local binary_data = file:read("*all")
        file:close()

        local data_collection = bitser.loads(binary_data)
        print("Data loaded from " .. savefile)
        printTable(data_collection)  -- Print the loaded data collection
        return data_collection
    else
        print("Failed to open file for reading")
        return nil
    end
end

return save_and_load
