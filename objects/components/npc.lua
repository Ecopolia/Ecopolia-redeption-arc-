-- Define the NpcElement class
NpcElement = setmetatable({}, { __index = UiElement })
NpcElement.__index = NpcElement

function NpcElement.new(config)
    local self = setmetatable(UiElement.new(config.x or 0, config.y or 0, config.w or 100, config.h or 100, config.z or 0), NpcElement)
    self.id = config.id or uuid()
    self.spritesheet = love.graphics.newImage(config.spritesheet or "assets/spritesheets/placeholder_npc.png")
    self.grid = anim8.newGrid(25, 25, self.spritesheet:getWidth(), self.spritesheet:getHeight())
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
    self.color = config.color or {love.math.random(), love.math.random(), love.math.random(), 1}
    self.debug = config.debug or false
    self.mode = config.mode or "random-in-area"
    self.path = config.path or {}
    self.pathIndex = 1
    self.forward = true
    self.questids = config.questids or {}

    self._world = config.world
    self.camera = config.camera

    self.waitInterval = config.waitInterval or 0
    self.isWaiting = false

    self.center = {x = config.x + config.w / 2, y = config.y + config.h / 2}

    self.hitzoneWidth = 24
    self.hitzoneHeight = 36

    self.position = {x = self.center.x, y = self.center.y}
    if self.mode == "predefined-path" or self.mode == "predefined-roundtour" then
        self.position.x = self.path[1].x
        self.position.y = self.path[1].y
    else
        self.position = {x = self.center.x, y = self.center.y}
    end

    self.collider = config.world:newCollider('Rectangle', {self.position.x, self.position.y, self.hitzoneWidth , self.hitzoneHeight})

    self:nextTarget()

    return self
end


function NpcElement:draw()
    if self.debug then
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.circle("line", self.center.x, self.center.y, self.radius)
        if self.hovered then
            love.graphics.setColor(0, 1, 0, 0.3)
            love.graphics.circle("fill", self.position.x, self.position.y, self.clickableRadius)
        else
            love.graphics.setColor(0, 1, 0, 0.1)
            love.graphics.circle("line", self.position.x, self.position.y, self.clickableRadius)
        end

        if (self.mode == "predefined-path" or self.mode == "predefined-roundtour") and #self.path > 0 then
            love.graphics.setColor(0, 0, 1, 0.5)
            for i = 1, #self.path - 1 do
                love.graphics.line(self.path[i].x, self.path[i].y, self.path[i + 1].x, self.path[i + 1].y)
            end

            if self.mode == "predefined-roundtour" then
                love.graphics.line(self.path[#self.path].x, self.path[#self.path].y, self.path[1].x, self.path[1].y)
            end

            love.graphics.setColor(1, 0, 0, 0.8)
            love.graphics.circle("fill", self.target.x, self.target.y, 5)
        end

        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("line", self.position.x - self.hitzoneWidth / 2, self.position.y - self.hitzoneHeight / 2, self.hitzoneWidth, self.hitzoneHeight)
    end

    love.graphics.setColor(self.color)
    local anim = self.isWaiting and self.animations.idle or self.animations.walk
    anim:draw(self.spritesheet, self.position.x, self.position.y, 0, self.scale * self.direction, self.scale, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
end

function NpcElement:update(dt)
    if self.moving and self.target and not self.isWaiting then
        local dx = self.target.x - self.position.x
        local dy = self.target.y - self.position.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < 2 then
            self:startWaiting()
        else
            local dirX = dx / distance
            local dirY = dy / distance

            local newX = self.position.x + dirX * self.speed * dt
            local newY = self.position.y + dirY * self.speed * dt

            self.collider:setPosition(newX, newY)

            local colliders = self._world:queryCircleArea(newX, newY, self.hitzoneWidth / 2)
            local isColliding = false
            
            for _, collider in ipairs(colliders) do
                if collider ~= self.collider then
                    isColliding = true
                    break
                end
            end

            if not isColliding then
                self.position.x = newX
                self.position.y = newY
                self.direction = dirX >= 0 and 1 or -1
                self.animations.walk:update(dt)
            else
                self:nextTarget()
            end
        end
    else
        self.animations.idle:update(dt)
    end

    if self.camera ~= nil then
        local mx, my = self.camera:worldCoords(love.mouse.getPosition())
        self.hovered = self:isInClickableZone(mx, my)
    end

end

function NpcElement:isColliding()

    local colliders = self._world:queryCircleArea(self.position.x, self.position.y, self.hitzoneWidth / 2)
    for _, collider in ipairs(colliders) do
        if collider ~= self.collider then
            return true
        end
    end
    return false
end

function NpcElement:isInCollisionZone(collider)
    local colliderX, colliderY = collider:getPosition()
    local distance = math.sqrt((self.position.x - colliderX)^2 + (self.position.y - colliderY)^2)
    return distance < (self.hitzoneWidth / 2 + collider:getRadius())
end

function NpcElement:startWaiting()
    if self.waitInterval > 0 then
        self.isWaiting = true
        Timer.after(self.waitInterval, function()
            self.isWaiting = false
            self:nextTarget()
        end)
    else
        self.isWaiting = false
        self:nextTarget()
    end
end

function NpcElement:nextTarget()
    local attemptedTargets = {}

    while true do
        if self.mode == "random-in-area" then
            self:setRandomTarget()
        elseif self.mode == "predefined-path" then
            if self.forward then
                self.pathIndex = self.pathIndex + 1
                if self.pathIndex > #self.path then
                    self.pathIndex = #self.path
                    self.forward = false
                end
            else
                self.pathIndex = self.pathIndex - 1
                if self.pathIndex < 1 then
                    self.pathIndex = 1
                    self.forward = true
                end
            end
            self.target = self.path[self.pathIndex]
        elseif self.mode == "predefined-roundtour" then
            self.pathIndex = self.pathIndex + 1
            if self.pathIndex > #self.path then
                self.pathIndex = 1
            end
            self.target = self.path[self.pathIndex]
        end

        local targetOffsetX = self.target.x - self.position.x
        local targetOffsetY = self.target.y - self.position.y
        
        if not self:isColliding(targetOffsetX, targetOffsetY, 0) then
            break
        else
            for angleOffset = -math.pi / 4, math.pi / 4, math.pi / 16 do
                local newAngle = math.atan2(targetOffsetY, targetOffsetX) + angleOffset
                local r = 50
                local newX = self.position.x + math.cos(newAngle) * r
                local newY = self.position.y + math.sin(newAngle) * r

                self.target = { x = newX, y = newY }

                if not self:isColliding(newX - self.position.x, newY - self.position.y, 0) then
                    print("New target found at: ", newX, newY) -- Debug output
                    return
                end
            end
            
            table.insert(attemptedTargets, {x = self.target.x, y = self.target.y})
            if #attemptedTargets >= 10 then
                print("No valid target found after 10 attempts, staying at current position.")
                break
            end
        end
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

function NpcElement:getDirection()
    if self.target then
        local dx = self.target.x - self.position.x
        local dy = self.target.y - self.position.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance > 0 then
            return dx / distance, dy / distance
        end
    end

    return 0, 0
end

return NpcElement
