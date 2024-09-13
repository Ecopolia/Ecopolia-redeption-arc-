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

    self.scopedElements[scope][name] = { element = element, z = element.z or 0 }
end

-- Draw all UI elements in a specific scope based on their Z-layer
function UiManager:draw(scope, z_from, z_to)
    if not self.scopedElements[scope] then return end

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
    if not self.scopedElements[scope] then return end

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

-- Remove a UI element from a specific scope
function UiManager:removeElement(scope, name)
    if self.scopedElements[scope] then
        self.scopedElements[scope][name] = nil
    end
end

return UiManager.new()
