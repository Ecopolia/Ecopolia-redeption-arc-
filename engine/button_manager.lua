local ButtonManager = {}
ButtonManager.__index = ButtonManager

local scopedButtons = {}

function ButtonManager.registerButton(scopes, config)
    local button = {
        text = config.text or "Button",
        dsfull = config.dsfull or true,
        x = config.x or 0,
        y = config.y or 0,
        w = config.w or 100,
        h = config.h or 50,
        hovered = false,
        onClick = config.onClick or function() end,
        onHover = config.onHover or function() end,
        onUnhover = config.onUnhover or function() end,
        onLoad = config.onLoad or function() end,
        css = config.css or {},
        button_text = nil, -- Initialize button_text as nil
        anim8 = config.anim8 or false,
        image = config.image or nil
    }

    for _, scope in ipairs(scopes) do
        if not scopedButtons[scope] then
            scopedButtons[scope] = {}
        end
        table.insert(scopedButtons[scope], button)
    end
    button.onLoad(button)
end

function ButtonManager.drawButtons(scope)
    if not scopedButtons[scope] then return end

    for _, button in ipairs(scopedButtons[scope]) do
        local css = button.css

        -- Set background color
        love.graphics.setColor(button.hovered and (css.hoverBackgroundColor or {1, 1, 1}) or (css.backgroundColor or {0.8, 0.8, 0.8}))
        -- Draw button rectangle
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, css.borderRadius or 0)

        -- Draw border
        love.graphics.setColor(button.hovered and (css.hoverBorderColor or {1, 1, 1}) or (css.borderColor or {0, 0, 0}))
        love.graphics.setLineWidth(css.borderWidth or 1)
        love.graphics.rectangle("line", button.x, button.y, button.w, button.h, css.borderRadius or 0)

        -- Set text color and font
        love.graphics.setColor(button.hovered and (css.hoverTextColor or {0, 0, 0}) or (css.textColor or {0, 0, 0}))
        love.graphics.setFont(css.font or love.graphics.newFont(12))

        -- Initialize button_text if not already initialized
        if not button.button_text then
            button.button_text = Text.new("left", {
                color = css.textColor or {0.9, 0.9, 0.9, 0.95},
                shadow_color = {0.5, 0.5, 1, 0.4},
                font = css.font or love.graphics.newFont(12),
                keep_space_on_line_break = true,
            })
            button.button_text:send(button.text, 320, button.dsfull)
        end

        -- Update text to handle dynamic effects
        button.button_text:update(0)

        -- Strip tags from the text for width and height calculation
        local strippedText = stripTags(button.text)
        
        -- Get the width and height of the rendered text without tags
        local textWidth = love.graphics.getFont():getWidth(strippedText)
        local textHeight = love.graphics.getFont():getHeight(strippedText)

        -- Calculate text position
        local textX = button.x + (button.w - textWidth) / 2
        local textY = button.y + (button.h - textHeight) / 2

        -- Draw button_text with tags
        button.button_text:draw(textX, textY)

        -- draw anim8 animation if available
        if button.anim8 then
            button.anim8:draw(button.image, button.x, button.y, 0, button.w / button.anim8:getDimensions(), button.h / button.anim8:getDimensions(), 0, 0)
        end

        -- Reset color
        love.graphics.setColor(1, 1, 1)
    end
end

function ButtonManager.updateButtons(scope, dt)
    if not scopedButtons[scope] then return end
    local mx, my = love.mouse.getPosition()
    for _, button in ipairs(scopedButtons[scope]) do
        if button.button_text then
            button.button_text:update(dt)
        end
        local isHovered = mx >= button.x and mx <= button.x + button.w and my >= button.y and my <= button.y + button.h

        if isHovered and not button.hovered then
            button.hovered = true
            button.onHover(button)
        elseif not isHovered and button.hovered then
            button.hovered = false
            button.onUnhover(button)
        end
    end
end

function ButtonManager.mousepressed(x, y, button)
    if button == 1 then
        for scope, btns in pairs(scopedButtons) do
            for _, btn in ipairs(btns) do
                if btn.hovered then
                    btn.onClick()
                end
            end
        end
    end
end

return ButtonManager
