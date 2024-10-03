local NPCManager = {}
NPCManager.__index = NPCManager

local npcs = {}

-- Utility function to generate random movement direction
local function getRandomDirection()
    local directions = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
    return directions[math.random(1, #directions)]
end

-- NPC Class
local NPC = {}
NPC.__index = NPC

-- NPC constructor with scene scope and nametag
function NPC.new(name, x, y, spriteSheet, animationGrid, scene, movementType, path)
    local self = setmetatable({}, NPC)
    self.name = name -- Unique NPC name
    self.scene = scene -- Scene where the NPC exists
    self.x = x
    self.y = y
    self.speed = 60 -- NPC movement speed
    self.movementType = movementType -- "random" or "path"
    self.path = path or {}
    self.pathIndex = 1

    -- Animation setup using anim8
    self.grid = animationGrid
    self.animations = {
        idle = anim8.newAnimation(self.grid('1-1', 1), 0.1),
        walk = anim8.newAnimation(self.grid('1-4', 1), 0.1)
    }
    self.currentAnimation = self.animations.idle -- Start with idle animation
    self.spriteSheet = spriteSheet -- spritesheet for animations

    self.interactable = true -- Flag to allow interaction
    return self
end

-- NPC movement update
function NPC:update(dt, world)
    if self.movementType == "random" then
        self:moveRandomly(dt, world)
    elseif self.movementType == "path" and self.path then
        self:followPath(dt, world)
    end

    -- Update the current animation
    self.currentAnimation:update(dt)
end

-- Random movement logic
function NPC:moveRandomly(dt, world)
    local direction = getRandomDirection()
    local newX = self.x + direction[1] * self.speed * dt
    local newY = self.y + direction[2] * self.speed * dt

    -- Check collisions
    if not world:hasCollision(newX, newY) then
        self.x = newX
        self.y = newY
        self.currentAnimation = self.animations.walk -- Switch to walk animation
    else
        self.currentAnimation = self.animations.idle -- If blocked, idle
    end
end

-- Path-following movement logic
function NPC:followPath(dt, world)
    if self.path[self.pathIndex] then
        local target = self.path[self.pathIndex]
        local dx, dy = target.x - self.x, target.y - self.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist > 0 then
            self.x = self.x + (dx / dist) * self.speed * dt
            self.y = self.y + (dy / dist) * self.speed * dt
            self.currentAnimation = self.animations.walk -- Walking animation
        end

        -- Check if the NPC reached the target point
        if dist < 5 then
            self.pathIndex = self.pathIndex + 1
            if self.pathIndex > #self.path then
                self.pathIndex = 1 -- Loop back to the beginning of the path
            end
        end
    end
end

-- Drawing the NPC with its nametag
function NPC:draw()
    self.currentAnimation:draw(self.spriteSheet, self.x, self.y)

    -- Draw nametag above the NPC
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.name, self.x - 10, self.y - 15, 64, "center")
end

-- Interaction when clicked
function NPC:interact()
    print("Interacting with NPC: " .. self.name .. " in scene: " .. self.scene)
    -- Add interaction logic here (dialogue, quests, etc.)
end

-- Check if the NPC was clicked by the player
function NPC:wasClicked(x, y)
    local width, height = self.grid.frameWidth, self.grid.frameHeight
    return x >= self.x and x <= self.x + width and y >= self.y and y <= self.y + height
end

-- NPCManager factory: add a new NPC to the manager
function NPCManager:addNPC(name, x, y, spriteSheet, animationGrid, scene, movementType, path)
    local npc = NPC.new(name, x, y, spriteSheet, animationGrid, scene, movementType, path)
    table.insert(npcs, npc)
end

-- Update all NPCs in the current scene
function NPCManager:update(dt, world, currentScene)
    for _, npc in ipairs(npcs) do
        if npc.scene == currentScene then
            npc:update(dt, world)
        end
    end
end

-- Draw all NPCs in the current scene
function NPCManager:draw(currentScene)
    for _, npc in ipairs(npcs) do
        if npc.scene == currentScene then
            npc:draw()
        end
    end
end

-- Handle interactions (check if NPC is clicked) in the current scene
function NPCManager:handleClick(x, y, currentScene)
    for _, npc in ipairs(npcs) do
        if npc.scene == currentScene and npc:wasClicked(x, y) and npc.interactable then
            npc:interact()
        end
    end
end

-- Find NPC by name
function NPCManager:getNPCByName(name)
    for _, npc in ipairs(npcs) do
        if npc.name == name then
            return npc
        end
    end
    return nil
end

return NPCManager
