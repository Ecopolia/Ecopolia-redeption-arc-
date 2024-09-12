-- Define the Freeform class
Freeform = setmetatable({}, { __index = UiElement })
Freeform.__index = Freeform

function Freeform.new(css)
    local self = setmetatable(UiElement.new(css.x or 0, css.y or 0, css.w or 100, css.h or 50), Freeform)
    self.points = css.points or {
        {0, 0},
        {100, 0},
        {100, 50},
        {0, 50}
    }
    self.color = css.color or {1, 1, 1}
    self.borderColor = css.borderColor or {0, 0, 0}
    self.borderThickness = css.borderThickness or 2
    self.visible = css.visible or true
    return self
end

function Freeform:draw()
    if not self.visible then return end

    -- Set fill color and draw the shape
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self:flattenPoints(self.points))

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderThickness)
    love.graphics.polygon("line", self:flattenPoints(self.points))

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Freeform:flattenPoints(points)
    local flatPoints = {}
    for _, point in ipairs(points) do
        table.insert(flatPoints, point[1])
        table.insert(flatPoints, point[2])
    end
    return flatPoints
end

return Freeform
