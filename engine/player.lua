Player = {}
Player.__index = Player

-- Fonction de création d'un nouveau joueur
function Player:new(x, y, speed, spriteSheet, grid, world)
    local instance = {
        grid = grid,
        x = x or 20, -- Utiliser les paramètres ou valeurs par défaut
        y = y or 20,
        speed = speed or 20,
        spriteSheet = spriteSheet,
        animations = {},
        currentAnimation = nil,
        world = world,
        colliders = {
            top = nil,
            bottom = nil,
            left = nil,
            right = nil
        },
        ecodex = [],
        isColliding = false,
        direction = "down"
    }

    -- Configuring the animations if grid is available
    if instance.grid ~= nil then
        instance.animations.up = anim8.newAnimation(instance.grid('1-9', 9), 0.2)
        instance.animations.left = anim8.newAnimation(instance.grid('1-9', 10), 0.2)
        instance.animations.idledown = anim8.newAnimation(instance.grid(1, 7), 0.1)
        instance.animations.right = anim8.newAnimation(instance.grid('1-9', 12), 0.2)
        instance.animations.down = anim8.newAnimation(instance.grid('1-9', 11), 0.2)
    end

    -- Creating colliders for each side of the player if the world is defined
    if instance.world ~= nil then
        local colliderSize = 16 -- Smaller size for individual side colliders
        local playerWidth, playerHeight = 64, 64

        -- Create four colliders: top, bottom, left, and right
        instance.colliders.top = instance.world:newCollider('Rectangle', {instance.x, instance.y - colliderSize, 32, 1})
        instance.colliders.bottom = instance.world:newCollider('Rectangle',
            {instance.x, instance.y + playerHeight, 32, 1})
        instance.colliders.left =
            instance.world:newCollider('Rectangle', {instance.x - colliderSize, instance.y, 1, 48})
        instance.colliders.right =
            instance.world:newCollider('Rectangle', {instance.x + playerWidth, instance.y, 1, 48})
    end

    setmetatable(instance, Player)
    return instance
end

function Player:addEcodexEntry(entry)
    if entry ~= nil then
        table.insert(self.ecodex, entry)
    else
        print("Invalid entry, cannot add to ecodex")
    end
end

function Player:update(dt)
    local isMoving = false
    self.isColliding, collisionSides = self:checkCollisions()

    -- Define scancodes for movement keys (layout-independent)
    local rightKey = love.keyboard.getKeyFromScancode("d")
    local leftKey = love.keyboard.getKeyFromScancode("a")
    local downKey = love.keyboard.getKeyFromScancode("s")
    local upKey = love.keyboard.getKeyFromScancode("w")

    -- Handling player movement and animation based on input
    if love.keyboard.isDown(rightKey) then
        self.direction = "right"
        if not collisionSides.right then -- Only move if not colliding on the right
            self.x = self.x + self.speed * dt
            self.anim = self.animations.right
            isMoving = true
        end
    end

    if love.keyboard.isDown(leftKey) then
        self.direction = "left"
        if not collisionSides.left then -- Only move if not colliding on the left
            self.x = self.x - self.speed * dt
            self.anim = self.animations.left
            isMoving = true
        end
    end

    if love.keyboard.isDown(downKey) then
        self.direction = "down"
        if not collisionSides.bottom then -- Only move if not colliding at the bottom
            self.y = self.y + self.speed * dt
            self.anim = self.animations.down
            isMoving = true
        end
    end

    if love.keyboard.isDown(upKey) then
        self.direction = "up"
        if not collisionSides.top then -- Only move if not colliding at the top
            self.y = self.y - self.speed * dt
            self.anim = self.animations.up
            isMoving = true
        end
    end

    if not isMoving and self.anim ~= nil then
        self.anim:gotoFrame(1)
    end

    -- Update colliders' positions based on player's position
    self:updateColliders()
end

-- Function to update collider positions based on player position
function Player:updateColliders()
    local colliderSize = 16
    local playerWidth, playerHeight = 64, 64

    -- Adjusting each collider's position based on the player's position
    self.colliders.top:setPosition(self.x + playerWidth / 2, self.y + 15)
    self.colliders.bottom:setPosition(self.x + playerWidth / 2, self.y + 64)
    self.colliders.left:setPosition(self.x + 8, self.y + 40)
    self.colliders.right:setPosition(self.x + 55, self.y + 40)
end

-- Function to check for collisions using the player's four colliders
function Player:checkCollisions()
    local collisionSides = {
        top = false,
        bottom = false,
        left = false,
        right = false
    }

    for side, collider in pairs(self.colliders) do
        local x1, y1, x2, y2 = collider:getBoundingBox()

        local colliders = {}

        self.world:queryBoundingBox(x1, y1, x2, y2, function(fixture)
            local otherCollider = fixture:getUserData()

            if otherCollider ~= collider then
                table.insert(colliders, otherCollider)
            end

            return true
        end)

        if #colliders > 0 then
            collisionSides[side] = true
        end
    end

    local isColliding = collisionSides.top or collisionSides.bottom or collisionSides.left or collisionSides.right
    return isColliding, collisionSides
end

-- Fonction pour dessiner le joueur
function Player:draw()
    if self.anim then
        -- Draw the current animation at the player's position
        self.anim:draw(self.spriteSheet, self.x, self.y)
    end
end

return Player
