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
    self.center = {x = config.x + config.w / 2, y = config.y + config.h / 2}
    self.position = {x = self.center.x, y = self.center.y}
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

    NpcElement.setRandomTarget(self)

    return self
end

function NpcElement:draw()
    love.graphics.setColor(1, 1, 1, 0.1)
    love.graphics.circle("line", self.center.x, self.center.y, self.radius)
    if self.hovered then
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.circle("fill", self.position.x, self.position.y, self.clickableRadius)
    else
        love.graphics.setColor(0, 1, 0, 0.1)
        love.graphics.circle("line", self.position.x, self.position.y, self.clickableRadius)
    end
    love.graphics.setColor(self.color)
    local anim = self.moving and self.animations.walk or self.animations.idle
    anim:draw(self.spritesheet, self.position.x, self.position.y, 0, self.scale * self.direction, self.scale, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
end

function NpcElement:update(dt)
    if self.moving and self.target then
        local dx = self.target.x - self.position.x
        local dy = self.target.y - self.position.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < 2 then
            NpcElement.setRandomTarget(self)
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

    local mx, my = love.mouse.getPosition()
    mx, my = push:toGame(mx, my)
    if mx and my then
        self.hovered = NpcElement.isInClickableZone(self, mx, my)
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
