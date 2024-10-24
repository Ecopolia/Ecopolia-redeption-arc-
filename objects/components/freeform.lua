Freeform = setmetatable({}, {
    __index = UiElement
})
Freeform.__index = Freeform

function Freeform.new(css)
    local self = setmetatable(UiElement.new(css.x or 0, css.y or 0, css.w or 100, css.h or 50, css.z or 0), Freeform)
    self.points = css.points or {{0, 0}, {100, 0}, {100, 50}, {0, 50}}
    self.color = css.color or {1, 1, 1}
    self.borderColor = css.borderColor or {0, 0, 0}
    self.borderThickness = css.borderThickness or 2
    self.visible = css.visible or true
    return self
end

function Freeform:draw()
    if not self.visible then
        return
    end

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

function Freeform:createRhombus(cx, cy, width, height, angle)
    local widthRadius = width / 2
    local heightRadius = height / 2

    -- Calculate the vertices before rotation
    local vertices = {{cx - widthRadius, cy}, -- Left vertex
    {cx, cy - heightRadius}, -- Top vertex
    {cx + widthRadius, cy}, -- Right vertex
    {cx, cy + heightRadius} -- Bottom vertex
    }

    -- Apply rotation
    local cosAngle = math.cos(angle)
    local sinAngle = math.sin(angle)

    local rotatedVertices = {}
    for i, vertex in ipairs(vertices) do
        local x = vertex[1] - cx
        local y = vertex[2] - cy

        -- Rotate the vertex
        local rotatedX = x * cosAngle - y * sinAngle + cx
        local rotatedY = x * sinAngle + y * cosAngle + cy

        table.insert(rotatedVertices, {rotatedX, rotatedY})
    end

    self.points = rotatedVertices
end

function Freeform:createTrapezium(cx, cy, widthLeft, widthRight, height, depth)
    local vertices = {{cx - widthLeft, cy}, {cx, cy - height}, {cx + widthRight, cy}, {cx, cy + depth}}
    self.points = vertices
end

function Freeform:createGem(cx, cy, widthTop, widthMiddle, height, depth)
    local widthTopRadius = widthTop / 2
    local widthMiddleRadius = widthMiddle / 2
    local vertices = {{cx - widthTopRadius, cy - height}, {cx + widthTopRadius, cy - height},
                      {cx + widthMiddleRadius, cy}, {cx, cy + depth}, {cx - widthMiddleRadius, cy}}
    self.points = vertices
end

function Freeform:createDiamond(cx, cy, width)
    local widthRadius = width / 2
    local depth = math.sqrt(math.pow(width, 2) - math.pow(widthRadius, 2)) / 2
    local height = depth / 2
    local topOffset = widthRadius / 3 * 2
    local vertices = {{cx - widthRadius, cy}, {cx - topOffset, cy - height}, {cx + topOffset, cy - height},
                      {cx + widthRadius, cy}, {cx, cy + depth}}
    self.points = vertices
end

return Freeform
