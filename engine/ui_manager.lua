local UiManager = {}
UiManager.__index = UiManager

-- Create a new UiManager
function UiManager.new()
    local self = setmetatable({}, UiManager)
    self.scopedElements = {} -- Table to store UI elements by scope
    self.layerManager = deep:new() -- Initialize the deep system for Z-layer management
    return self
end

-- Register a new UI element for a specific scope and Z-layer
function UiManager:registerElement(scope, name, element, z)
    if not self.scopedElements[scope] then
        self.scopedElements[scope] = {}
    end

    self.scopedElements[scope][name] = {
        element = element,
        z = element.z or 0
    }
end

-- Draw all UI elements in a specific scope based on their Z-layer
function UiManager:draw(scope, z_from, z_to)
    if not self.scopedElements[scope] then
        return
    end

    for _, data in pairs(self.scopedElements[scope]) do
        local element = data.element
        local z = data.z
        self.layerManager:queue(z, function()
            if element.visible then
                element:draw()
            end
        end)
    end

    if z_from and z_to then
        self.layerManager:restrict(z_from, z_to)
    end

    self.layerManager:draw()
end

-- Update all UI elements in a specific scope
function UiManager:update(scope, dt)
    if not self.scopedElements[scope] then
        return
    end

    for _, data in pairs(self.scopedElements[scope]) do
        local element = data.element
        if element.update then
            element:update(dt)
        end
    end
end

-- Handle mouse presses
function UiManager:mousepressed(x, y, button)
    for scope, elements in pairs(self.scopedElements) do
        for name, data in pairs(elements) do
            local element = data.element
            if element.mousepressed then
                element:mousepressed(x, y, button)
            end
        end
    end
end

-- Retrieve a UI element from a specific scope by name
function UiManager:getElement(scope, name)
    if self.scopedElements[scope] then
        return self.scopedElements[scope][name] and self.scopedElements[scope][name].element
    end
    return nil
end

-- Remove a UI element from a specific scope
function UiManager:removeElement(scope, name)
    if self.scopedElements[scope] then
        self.scopedElements[scope][name] = nil
    end
end

function UiManager:hideElement(scope, name)
    if self.scopedElements[scope] and self.scopedElements[scope][name] then
        self.scopedElements[scope][name].element.visible = false
        self.scopedElements[scope][name].element.freeze = true
    end
end

function UiManager:showElement(scope, name)
    if self.scopedElements[scope] and self.scopedElements[scope][name] then
        self.scopedElements[scope][name].element.visible = true
        self.scopedElements[scope][name].element.freeze = false
    end
end

function UiManager:freezeElement(scope, name)
    if self.scopedElements[scope] and self.scopedElements[scope][name] then
        self.scopedElements[scope][name].element.freeze = true
    end
end

function UiManager:unfreezeElement(scope, name)
    if self.scopedElements[scope] and self.scopedElements[scope][name] then
        self.scopedElements[scope][name].element.freeze = false
    end
end

function UiManager:freezeScope(scope)
    if not self.scopedElements[scope] then
        return
    end

    for _, data in pairs(self.scopedElements[scope]) do
        data.element.freeze = true
    end
end

function UiManager:hideScope(scope)
    if not self.scopedElements[scope] then
        return
    end

    for _, data in pairs(self.scopedElements[scope]) do
        data.element.freeze = true
        data.element.visible = false
    end
end

-- Find a UI element by a pattern in a specific scope
function UiManager:findElement(scope, pattern)
    -- Check if the scope exists
    if not self.scopedElements[scope] then
        return nil
    end

    -- Iterate through elements in the scope to find a match
    for name, data in pairs(self.scopedElements[scope]) do
        if name:match(pattern) then
            return data.element -- Return the element if the pattern matches
        end
    end

    -- Return nil if no element matches the pattern
    return nil
end

function UiManager:findElements(scope, pattern)
    local matchedElements = {}

    -- Check if the scope exists
    if not self.scopedElements[scope] then
        return matchedElements
    end

    -- Iterate through elements in the scope to find matches
    for name, data in pairs(self.scopedElements[scope]) do
        if name:match(pattern) then
            table.insert(matchedElements, data.element) -- Add the matched element to the list
        end
    end

    return matchedElements
end

return UiManager.new()
