local Scenery = {}

-- Split file into name and extension
local split = function(inputstr, sep)
    local t = {}
    for res in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, res) end
    return t[1], t[#t]
end

-- Automatically load scenes from the given directory
local autoLoad = function(directory)
    -- Get the files in the directory
    local files = love.filesystem.getDirectoryItems(directory)
    local scenes = {}

    for _, value in ipairs(files) do
        local file, ext = split(value, ".")

        -- Require scene
        if ext == file then
            local info = love.filesystem.getInfo(directory .. "/" .. file)

            -- Check if item is a directory
            if info and (info.type == "directory" or info.type == "symlink") then
                info = love.filesystem.getInfo(directory .. "/" .. file .. "/init.lua")

                -- Check for the init file
                if info and info.type == "file" then
                    scenes[file] = require(directory .. "." .. file)
                end
            end
        elseif ext == "lua" and file ~= "conf" and file ~= "main" then
            scenes[file] = require(directory .. "." .. file)
        end
    end

    return scenes
end

-- Iterate over the passed tables
local manualLoad = function(config)
    local scenes = {}
    local currentScene

    -- Loop through the parameters
    for _, value in ipairs(config) do
        -- Check if path is string
        assert(type(value.path) == "string", "Given path not a string.")

        -- Check if key is number or string
        assert(type(value.key) == "number" or type(value.key) == "string", "Given key not a number or string.")

        --Check for duplicate scene keys
        assert(not scenes[value.key], "Duplicate scene keys provided")

        scenes[value.key] = require(value.path)

        -- Check if default scene present
        if value.default then
            assert(not currentScene, "More than one default scene defined")
            currentScene = value.key
        end
    end

    -- If no default scene, set first scene as default
    if not currentScene then
        currentScene = config[1].key
    end

    return scenes, currentScene
end

local checkScenePresent = function(scene, sceneTable)
    local present = false

    for index, _ in pairs(sceneTable) do
        if index == scene then
            present = true
        end
    end

    return present
end

-- Transition functions
local function transitionIn(callback)
    G.TRANSITION = 0
    Timer.tween(G.TRANSITION_DURATION, G, {TRANSITION = 1}, 'in-out-cubic', function()
        G.TRANSITION = 1
        if callback then callback() end
    end)
end

local function transitionOut(callback)
    G.TRANSITION = 1
    Timer.tween(G.TRANSITION_DURATION, G, {TRANSITION = 0}, 'in-out-cubic', function()
        G.TRANSITION = 0
        if callback then callback() end
    end)
end

-- The base Scenery Class
Scenery.__index = Scenery

function Scenery.init(...)
    -- Set metatable to create a class
    local this = setmetatable({}, Scenery)

    -- Get all the parameters
    local config = { ... }

    -- Get scenes
    if config[1] == nil then
        error("No default scene supplied", 2)
    elseif type(config[1]) == "table" then
        this.scenes, this.currentscene = manualLoad(config)
    elseif type(config[1]) =="string" then
        this.scenes = autoLoad(config[2] or "scenes")
        assert(checkScenePresent(config[1], this.scenes), "No scene '" .. config[1] .. "' present")
        this.currentscene = config[1]
    else
        error("Unknown token '" .. config[1] .. "'", 2)
    end

    -- This function is available for all scene.
    function this.setScene(key, data)
        if this.currentscene == key then
            return -- Do nothing if the scene is already active
        end
        
        assert(this.scenes[key], "No such scene '" .. key .. "'")

        -- Call transitionOut and then transitionIn with proper callbacks
        transitionOut(function()
            if this.scenes[this.currentscene] and this.scenes[this.currentscene].unload then
                this.scenes[this.currentscene]:unload()
            end

            this.currentscene = key

            transitionIn(function()
                if this.scenes[this.currentscene].load then
                    this.scenes[this.currentscene]:load(data)
                end
            end)
        end)
    end

    -- Inject transition functions into each scene
    for _, value in pairs(this.scenes) do
        value["setScene"] = this.setScene
    end
    
    -- All the callbacks available in Love 11.4 as described on https://love2d.org/wiki/Category:Callbacks
    local loveCallbacks = { "load", "draw", "update", "outsideShaderDraw" } -- Except these three.
    for k in pairs(love.handlers) do
        table.insert(loveCallbacks, k)
    end

    -- Loop through the callbacks creating a function with same name on the base class
    for _, value in ipairs(loveCallbacks) do
        this[value] = function(self, ...)
            assert(type(self.scenes[self.currentscene]) == "table", "Scene '" .. self.currentscene .. "' not a valid scene.")

            -- Check if the function exists on the class
            if self.scenes[self.currentscene][value] then
                return self.scenes[self.currentscene][value](self.scenes[self.currentscene], ...)
            end
        end
    end

    -- Inject callbacks into a table. Examples:
    -- scenery:hook(love)
    -- scenery:hook(love, { 'load', 'update', 'draw' })
    function this.hook(self, t, keys)
        assert(type(t) == "table", "Given param is not a table")
        local registry = {}
        keys = keys or loveCallbacks
        for _, f in pairs(keys) do
            registry[f] = t[f] or function() end
            t[f] = function(...)
                registry[f](...)
                return self[f](self, ...)
            end
        end
    end

    return this
end

-- Return the initialising function
return Scenery.init
