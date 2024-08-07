UiElement = {}
UiElement.__index = UiElement

-- Create a new UI element
function UiElement.new(x, y, width, height)
    local self = setmetatable({}, UiElement)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.visible = true
    return self
end

-- Draw the UI element
function UiElement:draw()
    -- Override this in subclasses
end

-- Update the UI element
function UiElement:update(dt)
    -- Override this in subclasses if needed
end

return UiElement