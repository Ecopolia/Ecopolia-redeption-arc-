Player = {}
Player.__index = Player

-- Fonction de création d'un nouveau joueur
function Player:new(x, y, speed,spriteSheet,grid)
    local instance = {
        grid= nil,
        x = x or 400,  -- Utiliser les paramètres ou valeurs par défaut
        y = y or 200,
        speed = speed or 20,
        spriteSheet = nil,
        animations = {},
        currentAnimation = nil,
    }
    if instance.grid ~= nil then
        instance.animations.up = anim8.newAnimation(instance.grid('1-9', 9), 0.2)
        instance.animations.left = anim8.newAnimation(instance.grid('1-9', 10), 0.2)
        instance.animations.idledown = anim8.newAnimation(instance.grid(1, 7), 0.1)
        instance.animations.right = anim8.newAnimation(instance.grid('1-9', 12), 0.2)
        instance.animations.down = anim8.newAnimation(instance.grid('1-9', 11), 0.2)
    end
    setmetatable(instance, Player)
    return instance
end

-- Fonction de mise à jour du joueur
function Player:update(dt)
    local isMoving = false

    if love.keyboard.isDown("d") then
        self.x = self.x + self.speed * dt
        self.anim = self.animations.right -- Changer l'animation si nécessaire
        isMoving = true
    end

    if love.keyboard.isDown("q") then
        self.x = self.x - self.speed * dt
        self.anim = self.animations.left -- Changer l'animation si nécessaire
        isMoving = true
    end

    if love.keyboard.isDown("s") then
        self.y = self.y + self.speed * dt
        self.anim = self.animations.down -- Exemple : assigner l'animation "down"
        isMoving = true
    end

    if love.keyboard.isDown("z") then
        self.y = self.y - self.speed * dt
        self.anim = self.animations.up -- Changer l'animation si nécessaire
        isMoving = true
    end
    if isMoving == false and self.anim ~= nil then
        self.anim:gotoFrame(1) 
    end
end

-- Fonction pour dessiner le joueur
function Player:draw()
    if self.anim then
        -- Dessiner l'animation actuelle à la position du joueur
        self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2)
    end
end

return Player
