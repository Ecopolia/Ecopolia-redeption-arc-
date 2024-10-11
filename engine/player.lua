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
        isColliding = false
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
    self.isColliding = self:Colliding()
    if love.keyboard.isDown("d") then
        if self.isColliding == false then
            self.position.x = self.position.x + self.speed * dt
            self.anim = self.animations.right -- Changer l'animation si nécessaire
            isMoving = true
        else
            self.position.x = self.position.x - 2
        end
    end

    if love.keyboard.isDown("q") then
        if self.isColliding == false then
            self.position.x = self.position.x - self.speed * dt
            self.anim = self.animations.left -- Changer l'animation si nécessaire
            isMoving = true
        else
            self.position.x = self.position.x + 2
        end
    end

    if love.keyboard.isDown("s") then
        if self.isColliding == false then  
            self.position.y = self.position.y + self.speed * dt
            self.anim = self.animations.down -- Exemple : assigner l'animation "down"
            isMoving = true
        else
            self.position.y = self.position.y - 2
        end
    end

    if love.keyboard.isDown("z") then
        if self.isColliding == false then
            self.position.y = self.position.y - self.speed * dt
            self.anim = self.animations.up -- Changer l'animation si nécessaire
            isMoving = true
        else
            self.position.y = self.position.y + 2
        end
    end
    if isMoving == false and self.anim ~= nil then
        self.anim:gotoFrame(1) 
    end
    self.collider:setPosition(self.position.x + 32, self.position.y + 32)
end
function Player:Colliding()
    
    local colliders = self.world:queryCircleArea(self.position.x + 32, self.position.y + 32, 16)
    for _, collider in ipairs(colliders) do
        if collider ~= self.collider then
            return true
        end
    end
    return false
end
-- Fonction pour dessiner le joueur
function Player:draw()
    if self.anim then
        -- Dessiner l'animation actuelle à la position du joueur
        self.anim:draw(self.spriteSheet, self.position.x, self.position.y, nil, 1)
    end
end

return Player
