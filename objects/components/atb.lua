ATB = setmetatable({}, { __index = UiElement })
ATB.__index = ATB

function ATB.new(css, characters)
    local self = setmetatable(UiElement.new(css.x or 0, css.y or 0, css.w or 100, css.h or 50), ATB)
    self.characters = characters
    self.maxTime = 10 -- Maximum time for the progress bar (adjust as needed)
    return self
end

function ATB:update(dt)
    for _, npc in ipairs(self.characters) do
        -- Update the progress of each character
        npc.progress = math.min(npc.progress + dt * npc.speed, self.maxTime)

        -- If progress reaches the end of the bar, trigger the action (e.g., cast spell)
        if npc.progress >= self.maxTime then
            npc:castSpell()
            npc.progress = 0 -- Reset progress after casting
        end
    end
end

function ATB:draw()
    -- Set color to grey for the background
    love.graphics.setColor(0.3, 0.3, 0.3)

    -- Draw the background rectangle
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Set color to white for the border
    love.graphics.setColor(1, 1, 1)

    -- Draw the border rectangle
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw a vertical bar for each NPC
    local npcBarWidth = 10  -- Width of each NPC's vertical bar
    local npcBarHeight = self.height  -- Height of the NPC bar (same as the ATB height)
    local barSpacing = 5   -- Spacing between bars
    local circleRadius = 30 -- Radius of the circles
    

    for i, npc in ipairs(self.characters) do
        -- Set NPC's color (assumed to be stored in npc.color)
        love.graphics.setColor(npc.color)

        if npc.group == 'ally' then
            outlineColor = {0.3, 0.7, 0.9} -- Blueish outline for allies
        else
            outlineColor = {0.9, 0.3, 0.3} -- Reddish outline for enemies
        end

        -- Calculate the position for each vertical bar
        local barX = self.x + (i - 1) * (npcBarWidth + barSpacing)  -- Spacing between bars
        local barY = self.y  -- Position at the top of the ATB bar

        -- Calculate the position of the bar based on npc.progress
        local progressX = self.x + (npc.progress / self.maxTime) * (self.width - npcBarWidth)

        -- Draw the vertical bar for the NPC
        love.graphics.rectangle("fill", progressX, barY, npcBarWidth, npcBarHeight)

        -- Draw the outline of the bar (optional)
        love.graphics.setColor(outlineColor)  -- Set color to white for the bar outline
        love.graphics.rectangle("line", progressX, barY, npcBarWidth, npcBarHeight)

        -- Draw a circle above the bar representing the character's position
        local circleX = progressX + npcBarWidth / 2 -- Center the circle above the bar
        local circleY

        if npc.group == 'ally' then
            circleY = self.y - circleRadius - 10 -- Circle above the bar for allies
        else
            circleY = self.y + self.height + circleRadius + 10 -- Circle below the bar for enemies
        end  
        
        -- Set the color for the circle
        love.graphics.setColor(npc.color)

        -- Draw the circle
        love.graphics.circle("fill", circleX, circleY, circleRadius)

        -- Draw the outline of the circle (optional)
        love.graphics.setColor(outlineColor) -- White for the circle outline
        love.graphics.circle("line", circleX, circleY, circleRadius)
    end

    -- Reset color to white
    love.graphics.setColor(1, 1, 1)
end



return ATB