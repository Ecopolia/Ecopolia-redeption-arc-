-- play_button.lua
local function playButtonClick()
    print("Play button clicked!")
    -- Add your logic to start the game here
end

return Inky.defineElement(function(self)
    self.props.hovered = false

    self:onPointer("release", function()
        playButtonClick()
    end)

    self:onPointerEnter(function()
        self.props.hovered = true
    end)

    self:onPointerExit(function()
        self.props.hovered = false
    end)

    return function(_, x, y, w, h, bounding)
        local windowWidth, windowHeight = love.graphics.getDimensions()
        -- Draw the "ECOPOLIA" text
        local ecopoliaX = windowWidth / 2 - love.graphics.getFont():getWidth("ECOPOLIA") / 2
        local ecopoliaY = windowHeight / 2 - love.graphics.getFont():getHeight() / 2


        -- Draw the "Play" button text under the "ECOPOLIA" text
        local playTextY = ecopoliaY + love.graphics.getFont():getHeight() + 30 -- 30 pixels below "ECOPOLIA" text
        local playTextX = x + (w / 2) - (love.graphics.getFont():getWidth("Play") / 2)

        text_play = Text.new("left", { color = {0.9,0.9,0.9,0.95}, shadow_color = {0.5,0.5,1,0.4}, font = Fonts.m6x11plus, keep_space_on_line_break=true,})

        if self.props.hovered then
            love.graphics.setColor(1, 1, 0) -- Yellow color for hover
            text_play:send("[color=#00ff00]Play[/color]", 320, true)
            text_play:draw(playTextX, playTextY)
        else
            love.graphics.setColor(1, 1, 1) -- White color for normal
            text_play:send("Play", 320, true)
            text_play:draw(playTextX, playTextY)
        end

        if (bounding) then
            love.graphics.rectangle("line", x, y, w, h)
        end
        love.graphics.setColor(1, 1, 1) -- Reset to default color
    end
end)
