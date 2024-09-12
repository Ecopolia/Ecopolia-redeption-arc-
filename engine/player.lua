Player = {}
Player.__index = Player

-- Fonction de création d'un nouveau joueur
function Player:new(x, y, speed)
    local instance = {
        x = x or 400,  -- Utiliser les paramètres ou valeurs par défaut
        y = y or 200,
        speed = speed or 2,
        spriteSheet = nil,
        animations = {},
        currentAnimation = nil
    }
    setmetatable(instance, Player)
    return instance
end

-- Fonction de mise à jour du joueur
function Player:update(dt)
    if love.keyboard.isDown("d") then
        self.x = self.x + self.speed * dt
        -- self.currentAnimation = self.animations.down -- Changer l'animation si nécessaire
    end

    if love.keyboard.isDown("q") then
        self.x = self.x - self.speed * dt
        -- self.currentAnimation = self.animations.down -- Changer l'animation si nécessaire
    end

    if love.keyboard.isDown("s") then
        self.y = self.y + self.speed * dt
        self.currentAnimation = self.animations.down -- Exemple : assigner l'animation "down"
    end

    if love.keyboard.isDown("z") then
        self.y = self.y - self.speed * dt
        -- self.currentAnimation = self.animations.up -- Changer l'animation si nécessaire
    end
end

-- Fonction pour dessiner le joueur
function Player:draw()
    if self.currentAnimation then
        -- Dessiner l'animation actuelle à la position du joueur
        self.currentAnimation:draw(self.spriteSheet, self.x, self.y)
    end
end

return Player
