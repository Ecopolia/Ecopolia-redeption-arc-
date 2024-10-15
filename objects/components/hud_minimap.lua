Minimap = setmetatable({}, { __index = UiElement })
Minimap.__index = Minimap

-- Create a new Minimap (inherits from UiElement)
function Minimap.new(css)
    local self = setmetatable(UiElement.new(css.x or 20, css.y or 20, css.radius * 2 or 200, css.radius * 2 or 200, css.z or 0), Minimap)
    self.radius = css.radius or 100
    self.scale = css.scale or 0.1  -- Adjust scale for zooming
    self.borderThickness = css.borderThickness or 2
    self.borderColor = css.borderColor or {0, 0, 0}
    self.mapColor = css.mapColor or {1, 1, 1}
    self.visible = css.visible or true

    -- Load the minimap image (replace with your PNG path)
    self.mapImage = love.graphics.newImage('assets/maps/MainMap.png')

    -- Store the player object reference
    self._player = css.player
    
    return self
end

-- Toggle the visibility of the minimap
function Minimap:toggle()
    self.visible = not self.visible
end

-- Function to draw the minimap
function Minimap:draw()
    if not self.visible then return end

    -- Draw the circular border for the minimap
    love.graphics.setColor(self.borderColor)
    love.graphics.circle("line", self.x + self.radius, self.y + self.radius, self.radius, 64)

    -- Draw the minimap background (if needed)
    love.graphics.setColor(self.mapColor)
    love.graphics.circle("fill", self.x + self.radius, self.y + self.radius, self.radius - self.borderThickness, 64)

    -- Clip the minimap image within a circle using stencil
    love.graphics.stencil(function()
        love.graphics.circle("fill", self.x + self.radius, self.y + self.radius, self.radius - self.borderThickness, 64)
    end, "replace", 1)

    love.graphics.setStencilTest("greater", 0)

    -- Draw the minimap image
    if self.mapImage then
        love.graphics.setColor(1, 1, 1) -- Reset to default color
        
        -- Calculate the scaled position for centering the image
        local scaledWidth = self.mapImage:getWidth() * self.scale
        local scaledHeight = self.mapImage:getHeight() * self.scale
        
        -- Calculate the offset for the player position
        local playerMinimapX = (self._player.x * self.scale) - (scaledWidth / 2) + self.radius
        local playerMinimapY = (self._player.y * self.scale) - (scaledHeight / 2) + self.radius
        
        -- Draw the minimap image at the calculated position
        love.graphics.draw(self.mapImage, 
            self.x + self.radius - playerMinimapX, 
            self.y + self.radius - playerMinimapY,
            0, 
            self.scale, 
            self.scale)
    end

    -- Reset stencil test
    love.graphics.setStencilTest()

    -- Draw the player's position as a red dot on the minimap
    if self._player then
        love.graphics.setColor(1, 0, 0)  -- Red color for the player dot
        
        -- Draw the player dot at the center of the minimap
        love.graphics.circle("fill", self.x + self.radius, self.y + self.radius, 5)  -- Draw the player dot at center
    end

    -- Reset color to default
    love.graphics.setColor(1, 1, 1)
end

-- Update method (optional, can be left empty)
function Minimap:update(dt)
    -- Update logic if needed (e.g., the minimap's internal map)
end

return Minimap
