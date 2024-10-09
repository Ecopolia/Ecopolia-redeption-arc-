-- Define the NpcElement class
NpcElement = setmetatable({}, { __index = UiElement })
NpcElement.__index = NpcElement

function NpcElement.new(config)
    local self = setmetatable(UiElement.new(config.x or 0, config.y or 0, config.w or 100, config.h or 100, config.z or 0), NpcElement)
    self.spritesheet = love.graphics.newImage(config.spritesheet or "assets/spritesheets/placeholder_npc.png")
    self.grid = anim8.newGrid(24, 24, self.spritesheet:getWidth(), self.spritesheet:getHeight())
    self.animations = {
        idle = anim8.newAnimation(self.grid('1-2', 1), 0.2),
        walk = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    }

    self.scale = config.scale or 2
    self.radius = config.radius or 100
    self.clickableRadius = config.clickableRadius or 50
    self.speed = config.speed or 60
    self.direction = 1
    self.target = nil
    self.moving = true
    self.hovered = false
    self.onClick = config.onClick or function() end
    self.color = {love.math.random(), love.math.random(), love.math.random(), 1}
    self.debug = config.debug or false
    self.mode = config.mode or "random-in-area"
    self.path = config.path or {}
    self.pathIndex = 1
    self.forward = true

    -- New variable for wait interval
    self.waitInterval = config.waitInterval or 0
    self.isWaiting = false

    -- Calculate the center of the NPC based on its width and height
    self.center = {x = config.x + config.w / 2, y = config.y + config.h / 2}

    -- Set initial target based on mode
    if (self.mode == "predefined-path" or self.mode == "predefined-roundtour") and #self.path > 0 then
        -- Set the initial position to the first point in the path
        self.position = {x = self.path[1].x, y = self.path[1].y}
        self.target = self.path[self.pathIndex] -- Set the target as the first point in the path
    else
        -- Default position when not using a predefined path
        self.position = {x = self.center.x, y = self.center.y}
    end

    return self
end



function NpcElement:draw()
    if self.debug then
        -- Draw area and clickable zone in debug mode
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.circle("line", self.center.x, self.center.y, self.radius)
        if self.hovered then
            love.graphics.setColor(0, 1, 0, 0.3)
            love.graphics.circle("fill", self.position.x, self.position.y, self.clickableRadius)
        else
            love.graphics.setColor(0, 1, 0, 0.1)
            love.graphics.circle("line", self.position.x, self.position.y, self.clickableRadius)
        end

        -- Draw predefined path if in 'predefined-path' or 'predefined-roundtour' mode
        if (self.mode == "predefined-path" or self.mode == "predefined-roundtour") and #self.path > 0 then
            love.graphics.setColor(0, 0, 1, 0.5) -- Line color for the path
            for i = 1, #self.path - 1 do
                love.graphics.line(self.path[i].x, self.path[i].y, self.path[i + 1].x, self.path[i + 1].y)
            end

            -- Only connect the last point back to the first in "predefined-roundtour" mode
            if self.mode == "predefined-roundtour" then
                love.graphics.line(self.path[#self.path].x, self.path[#self.path].y, self.path[1].x, self.path[1].y)
            end

            -- Draw the current target with a distinct color
            love.graphics.setColor(1, 0, 0, 0.8) -- Red for current target
            love.graphics.circle("fill", self.target.x, self.target.y, 5)
        end
    end

    -- Draw the NPC sprite
    love.graphics.setColor(self.color)
    local anim = self.isWaiting and self.animations.idle or self.animations.walk
    anim:draw(self.spritesheet, self.position.x, self.position.y, 0, self.scale * self.direction, self.scale, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
end

function NpcElement:update(dt)
    if self.moving and self.target and not self.isWaiting then -- Only move if not waiting
        local dx = self.target.x - self.position.x
        local dy = self.target.y - self.position.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < 2 then
            self:startWaiting() -- Start waiting when reaching the target
        else
            local dirX = dx / distance
            local dirY = dy / distance
            self.position.x = self.position.x + dirX * self.speed * dt
            self.position.y = self.position.y + dirY * self.speed * dt
            self.direction = dirX >= 0 and 1 or -1
            self.animations.walk:update(dt)
        end
    else
        self.animations.idle:update(dt)
    end

    -- Check for mouse hover
    local mx, my = love.mouse.getPosition()
    mx, my = push:toGame(mx, my)
    if mx and my then
        self.hovered = NpcElement.isInClickableZone(self, mx, my)
    end
end

function NpcElement:startWaiting()
    if self.waitInterval > 0 then
        self.isWaiting = true
        -- Schedule the action to move to the next target after the wait time
        Timer.after(self.waitInterval, function()
            self.isWaiting = false
            self:nextTarget() -- Move to the next target after waiting
        end)
    else
        self.isWaiting = false
        self:nextTarget() -- Move to the next target immediately if wait interval is 0
    end
end

function NpcElement:nextTarget()
    if self.mode == "random-in-area" then
        self:setRandomTarget()
    elseif self.mode == "predefined-path" then
        if self.forward then
            self.pathIndex = self.pathIndex + 1
            if self.pathIndex > #self.path then
                self.pathIndex = #self.path -- Stay at the last point if out of bounds
                self.forward = false
            end
        else
            self.pathIndex = self.pathIndex - 1
            if self.pathIndex < 1 then
                self.pathIndex = 1 -- Stay at the first point if out of bounds
                self.forward = true
            end
        end
        self.target = self.path[self.pathIndex] -- Set the target to the current path index
    elseif self.mode == "predefined-roundtour" then
        self.pathIndex = self.pathIndex + 1
        if self.pathIndex > #self.path then
            self.pathIndex = 1 -- Loop back to the first point
        end
        self.target = self.path[self.pathIndex]
    end
end

function NpcElement:isInClickableZone(x, y)
    local dx = x - self.position.x
    local dy = y - self.position.y
    return (dx * dx + dy * dy) <= (self.clickableRadius * self.clickableRadius)
end

function NpcElement:setRandomTarget()
    local angle = love.math.random() * (2 * math.pi)
    local r = love.math.random(0, self.radius)
    self.target = {
        x = self.center.x + math.cos(angle) * r,
        y = self.center.y + math.sin(angle) * r
    }
end

function NpcElement:mousepressed(x, y, button)
    if button == 1 and self.hovered then
        self.onClick()
    end
end

return NpcElement
