Player = {}
Player.__index = Player

-- Fonction de création d'un nouveau joueur
function Player:new(x, y, speed, spriteSheet, grid)
    local instance = {
        grid = grid,
        x = x or 20,  -- Utiliser les paramètres ou valeurs par défaut
        y = y or 20,
        speed = speed or 20,
        spriteSheet = spriteSheet,
        animations = {},
        currentAnimation = nil,
        world = world,
        collider = nil,
        center = nil,
        position = nil,
        isColliding = false,
        direction = "down"
    }
    
    if instance.grid ~= nil then
        instance.animations.up = anim8.newAnimation(instance.grid('1-9', 9), 0.2)
        instance.animations.left = anim8.newAnimation(instance.grid('1-9', 10), 0.2)
        instance.animations.idledown = anim8.newAnimation(instance.grid(1, 7), 0.1)
        instance.animations.right = anim8.newAnimation(instance.grid('1-9', 12), 0.2)
        instance.animations.down = anim8.newAnimation(instance.grid('1-9', 11), 0.2)
    end
    
    if instance.world ~= nil then 
        instance.center = {x = instance.x + 64/2, y = instance.y + 64/2}
        instance.position = {x = instance.center.x, y = instance.center.y}
        instance.collider = instance.world:newCollider('Rectangle', {instance.position.x, instance.position.y, 64, 64})
    end
    setmetatable(instance, Player)
    return instance
end

-- Fonction de mise à jour du joueur
function Player:update(dt)
    local isMoving = false
    self.isColliding, collisionSide = self:Colliding()

    -- Check movement directions based on collisions
    if love.keyboard.isDown("d") then
        self.direction = "right" -- Set the direction to right
        if self.isColliding == false or collisionSide ~= "right" then
            self.position.x = self.position.x + self.speed * dt
            self.anim = self.animations.right
            isMoving = true
        else
            -- Prevent movement to the right
        end
    end

    if love.keyboard.isDown("q") then
        self.direction = "left" -- Set the direction to left
        if self.isColliding == false or collisionSide ~= "left" then
            self.position.x = self.position.x - self.speed * dt
            self.anim = self.animations.left
            isMoving = true
        else
            -- Prevent movement to the left
        end
    end

    if love.keyboard.isDown("s") then
        self.direction = "down" -- Set the direction to down
        if self.isColliding == false or collisionSide ~= "down" then  
            self.position.y = self.position.y + self.speed * dt
            self.anim = self.animations.down
            isMoving = true
        else
            -- Prevent movement downward
        end
    end

    if love.keyboard.isDown("z") then
        self.direction = "up" -- Set the direction to up
        if self.isColliding == false or collisionSide ~= "up" then
            self.position.y = self.position.y - self.speed * dt
            self.anim = self.animations.up
            isMoving = true
        else
            -- Prevent movement upward
        end
    end

    if isMoving == false and self.anim ~= nil then
        self.anim:gotoFrame(1) 
    end
    
    -- Update collider position
    self.collider:setPosition(self.position.x + 32, self.position.y + 32)
end

-- Fonction pour détecter les collisions
function Player:Colliding()
    local x, y = self.position.x, self.position.y
    local vertices = {
        x, y,
        x + 64, y,
        x + 64, y + 64,
        x, y + 64
    }
    
    local colliders = self.world:queryPolygonArea(vertices)
    
    for _, collider in ipairs(colliders) do
        if collider ~= self.collider then

            local collX, collY = collider:getX(), collider:getY()
            
            if collX > x + 64 then
                return true, "right"
            elseif collX < x then
                return true, "left"
            elseif collY > y + 64 then
                return true, "down"
            elseif collY < y then
                return true, "up"
            end
        end
    end
    return false, nil -- No collision
end


-- Fonction pour dessiner le joueur
function Player:draw()
    if self.anim then
        -- Dessiner l'animation actuelle à la position du joueur
        self.anim:draw(self.spriteSheet, self.position.x, self.position.y, nil, 1)
    end
end

return Player
