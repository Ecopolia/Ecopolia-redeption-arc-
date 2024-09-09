local UiManager = {}
UiManager.__index = UiManager

-- Create a new UiManager
function UiManager.new()
    local self = setmetatable({}, UiManager)
    self.scopedElements = {} -- Table to store UI elements by scope
    return self
end

-- Register a new UI element for a specific scope
function UiManager:registerElement(scope, name, element)
    if not self.scopedElements[scope] then
        self.scopedElements[scope] = {}
    end
    self.scopedElements[scope][name] = element
end

-- Draw all UI elements in a specific scope
function UiManager:draw(scope)
    if not self.scopedElements[scope] then return end

    for _, element in pairs(self.scopedElements[scope]) do
        if element.visible then
            element:draw()
        end
    end
end

-- Update all UI elements in a specific scope
function UiManager:update(scope, dt)
    if not self.scopedElements[scope] then return end

    for _, element in pairs(self.scopedElements[scope]) do
        if element.update then
            element:update(dt)
        end
    end
end

-- Handle mouse presses
function UiManager:mousepressed(x, y, button)
    for scope, elements in pairs(self.scopedElements) do
        for name, element in pairs(elements) do
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
