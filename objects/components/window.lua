-- Define the Window class
Window = setmetatable({}, { __index = UiElement })
Window.__index = Window

function Window.new(css)
    local self = setmetatable(UiElement.new(css.x or 0, css.y or 0, css.w or 100, css.h or 50), Window)
    self.uiAtlas = css.uiAtlas or {}
    self.borderThickness = css.borderThickness or 32
    self.title = css.title or ""
    self.font = css.font or love.graphics.newFont(12)
    self.visible = css.visible or false
    self.color = css.color or {1, 1, 1}
    return self
end

function Window:toggle()
    self.visible = not self.visible
end

function Window:draw()
    if not self.visible then
        return
    end

    local anims = self.uiAtlas
    love.graphics.setFont(self.font)

    -- Set the color of the window
    love.graphics.setColor(self.color)

    -- Draw corners
    anims.blueTopLeftCorner:draw(G.UiAtlas, self.x, self.y)
    anims.blueTopRightCorner:draw(G.UiAtlas, self.x + self.width - self.borderThickness, self.y)
    anims.blueBottomLeftCorner:draw(G.UiAtlas, self.x, self.y + self.height - self.borderThickness)
    anims.blueBottomRightCorner:draw(G.UiAtlas, self.x + self.width - self.borderThickness, self.y + self.height - self.borderThickness)

    -- Draw top and bottom edges
    for i = 0, (self.width / self.borderThickness) - 1 do
        anims.blueTop:draw(G.UiAtlas, self.x + i * self.borderThickness, self.y)
        anims.blueBottom:draw(G.UiAtlas, self.x + i * self.borderThickness, self.y + self.height - self.borderThickness)
    end

    -- Draw left and right edges
    for i = 0, (self.height / self.borderThickness) - 1 do
        anims.blueLeft:draw(G.UiAtlas, self.x, self.y + i * self.borderThickness)
        anims.blueRight:draw(G.UiAtlas, self.x + self.width - self.borderThickness, self.y + i * self.borderThickness)
    end

    -- Draw the middle part of the window
    for i = 1, (self.width / self.borderThickness) - 1 do
        for j = 1, (self.height / self.borderThickness) - 1 do
            anims.blueMiddle:draw(G.UiAtlas, self.x + i * self.borderThickness, self.y + j * self.borderThickness)
        end
    end

    -- reset color
    love.graphics.setColor(1, 1, 1)

    -- Draw title background if title is provided
    if self.title and self.title ~= "" then
        local titleWidth = self.font:getWidth(self.title)
        local titleHeight = self.font:getHeight(self.title)

        -- Title background dimensions with padding
        local paddingMultiplier = 0.8
        local titleBackgroundPaddingWidth = titleWidth * paddingMultiplier
        local titleBackgroundPaddingHeight = titleHeight * paddingMultiplier
        local bgWidth = titleWidth + 2 * titleBackgroundPaddingWidth
        local bgHeight = titleHeight + 2 * titleBackgroundPaddingHeight

        -- Title position
        local titleX = self.x + (self.width - titleWidth) / 2
        local titleY = self.y + self.borderThickness - titleBackgroundPaddingHeight -- Position title background inside the window

        -- Draw title background animations
        -- Left corner
        anims.titleWithBottomDropShadowLeftCorner:draw(G.UiAtlas, titleX - titleBackgroundPaddingWidth, titleY - titleBackgroundPaddingHeight, 0, 1, bgHeight / 32)

        -- Middle
        local middleSpriteWidth = 32 -- Width of the middle sprite
        local middleSpritesNeeded = math.ceil((bgWidth - 64) / middleSpriteWidth) -- 64 is the combined width of the left and right corners
        for i = 0, middleSpritesNeeded - 1 do
            anims.titleWithBottomDropShadowMiddle:draw(G.UiAtlas, titleX - titleBackgroundPaddingWidth + 32 + i * middleSpriteWidth, titleY - titleBackgroundPaddingHeight, 0, 1, bgHeight / 32)
        end

        -- Right corner
        anims.titleWithBottomDropShadowRightCorner:draw(G.UiAtlas, titleX + bgWidth - titleBackgroundPaddingWidth - 32, titleY - titleBackgroundPaddingHeight, 0, 1, bgHeight / 32)

        -- Draw the title text in the middle top of the background
        local textX = titleX
        local textY = titleY + (titleBackgroundPaddingHeight / 2) - (titleHeight / 2)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.title, textX, textY)
        love.graphics.setColor(1, 1, 1)
    end
end

function Window:isMouseOver()
    local mx, my = love.mouse.getPosition()
    mx, my = push:toGame(mx, my) 
    if mx and my then
        return mx > self.x and mx < self.x + self.width and my > self.y and my < self.y + self.height

    end
end

return Window
