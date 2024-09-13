-- Define the Button class
Button = setmetatable({}, { __index = UiElement })
Button.__index = Button

function Button.new(config)
    local self = setmetatable(UiElement.new(config.x or 0, config.y or 0, config.w or 100, config.h or 50, config.z or 0), Button)
    self.text = config.text or "Button"
    self.dsfull = config.dsfull or true
    self.hovered = false
    self.onClick = config.onClick or function() end
    self.onHover = config.onHover or function() end
    self.onUnhover = config.onUnhover or function() end
    self.onLoad = config.onLoad or function() end
    self.css = config.css or {}
    self.button_text = nil
    self.anim8 = config.anim8 or false
    self.image = config.image or nil

    -- Initialize button_text
    self.button_text = Text.new("left", {
        color = self.css.textColor or {0.9, 0.9, 0.9, 0.95},
        shadow_color = {0.5, 0.5, 1, 0.4},
        font = self.css.font or love.graphics.newFont(12),
        keep_space_on_line_break = true,
    })
    self.button_text:send(self.text, 320, self.dsfull)

    self.onLoad(self)

    return self
end

function Button:draw()
    -- Set background color
    love.graphics.setColor(self.hovered and (self.css.hoverBackgroundColor or {1, 1, 1}) or (self.css.backgroundColor or {0.8, 0.8, 0.8}))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.css.borderRadius or 0)

    -- Draw border
    love.graphics.setColor(self.hovered and (self.css.hoverBorderColor or {1, 1, 1}) or (self.css.borderColor or {0, 0, 0}))
    love.graphics.setLineWidth(self.css.borderWidth or 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.css.borderRadius or 0)

    -- Set text color and font
    love.graphics.setColor(self.hovered and (self.css.hoverTextColor or {0, 0, 0}) or (self.css.textColor or {0, 0, 0}))
    love.graphics.setFont(self.css.font or love.graphics.newFont(12))

    -- Update text
    self.button_text:update(0)

    -- Strip tags from the text for width and height calculation
    local strippedText = stripTags(self.text)
    
    -- Get the width and height of the rendered text without tags
    local textWidth = love.graphics.getFont():getWidth(strippedText)
    local textHeight = love.graphics.getFont():getHeight(strippedText)

    -- Calculate text position
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2

    -- Draw button_text with tags
    self.button_text:draw(textX, textY)

    -- Draw anim8 animation if available
    if self.anim8 then
        self.anim8:draw(self.image, self.x, self.y, 0, self.width / self.anim8:getDimensions(), self.height / self.anim8:getDimensions(), 0, 0)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    local isHovered = mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height

    if isHovered and not self.hovered then
        self.hovered = true
        self.onHover(self)
    elseif not isHovered and self.hovered then
        self.hovered = false
        self.onUnhover(self)
    end

    if self.button_text then
        self.button_text:update(dt)
    end
end

function Button:mousepressed(x, y, button)
    if button == 1 and self.hovered then
        self.onClick()
    end
end

return Button
