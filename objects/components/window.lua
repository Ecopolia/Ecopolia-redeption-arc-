-- Define the Window class
Window = setmetatable({}, {
    __index = UiElement
})
Window.__index = Window

function Window.new(css)
    local self = setmetatable(UiElement.new(css.x or 0, css.y or 0, css.w or 100, css.h or 50, css.z or 0), Window)
    self.borderThickness = css.borderThickness or 2
    self.title = css.title or ""
    self.font = css.font or love.graphics.newFont(12)
    self.visible = css.visible or true
    self.color = css.color or {1, 1, 1}
    self.borderColor = css.borderColor or {0, 0, 0}
    self.draggable = css.draggable or false
    self.borderRadius = css.borderRadius or 0
    self.dragging = false
    return self
end

function Window:toggle()
    self.visible = not self.visible
end

function Window:draw()
    if not self.visible then
        return
    end

    love.graphics.setFont(self.font)

    -- Set border color and draw the border rectangle
    love.graphics.setColor(self.borderColor)
    if self.borderRadius > 0 then
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.borderRadius)
    else
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end

    -- Set fill color and draw the window background
    love.graphics.setColor(self.color)
    if self.borderRadius > 0 then
        love.graphics.rectangle("fill", self.x + self.borderThickness, self.y + self.borderThickness,
            self.width - 2 * self.borderThickness, self.height - 2 * self.borderThickness, self.borderRadius)
    else
        love.graphics.rectangle("fill", self.x + self.borderThickness, self.y + self.borderThickness,
            self.width - 2 * self.borderThickness, self.height - 2 * self.borderThickness)
    end

    -- Draw title if available
    if self.title and self.title ~= "" then
        local titleWidth = self.font:getWidth(self.title)
        local titleX = self.x + (self.width - titleWidth) / 2
        local titleY = self.y + self.borderThickness / 2
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.title, titleX, titleY)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Window:update(dt)
    if not self.draggable then
        return
    end

    -- Handle dragging logic
    if love.mouse.isDown(1) and self:isMouseOver() then
        if not self.dragging then
            self.dragging = true
            self.dragOffsetX = love.mouse.getX() - self.x
            self.dragOffsetY = love.mouse.getY() - self.y
        end

        if self.dragging then
            self.x = love.mouse.getX() - self.dragOffsetX
            self.y = love.mouse.getY() - self.dragOffsetY
        end
    else
        self.dragging = false
    end
end

function Window:isMouseOver()
    local mx, my = love.mouse.getPosition()
    return mx > self.x and mx < self.x + self.width and my > self.y and my < self.y + self.height
end

return Window
