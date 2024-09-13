-- Card class
Card = setmetatable({}, { __index = UiElement })
Card.__index = Card

-- Create a new draggable card
function Card.new(x, y, z, image)
    local self = setmetatable(UiElement.new(x, y, 39, 66, z), Card)
    self.image = image
    self.dragging = false
    self.offsetX = 0
    self.offsetY = 0

    print(self.image)
    return self
end

-- Handle mouse press for dragging
function Card:mousepressed(mx, my, button)
    if button == 1 and self:isHovered(mx, my) then
        self.dragging = true
        self.offsetX = mx - self.x
        self.offsetY = my - self.y
    end
end

-- Handle mouse release to stop dragging
function Card:mousereleased(mx, my, button)
    if button == 1 then
        self.dragging = false
    end
end

-- Check if the mouse is over the card
function Card:isHovered(mx, my)
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

-- Update the card position when dragging
function Card:update(dt)

end

-- Draw the card
function Card:draw()
    if self.visible then
        love.graphics.draw(self.image, self.x, self.y, 0, self.width / self.image:getWidth(), self.height / self.image:getHeight())
    end
end

return Card