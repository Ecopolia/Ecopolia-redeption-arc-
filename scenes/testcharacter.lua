local Player = require("player")

function love.load()
    anim8 = require 'libs/anim8' -- Charger la bibliothèque anim8
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Activer le rendu pixelisé

    -- Créer une instance du joueur avec position et vitesse initiales
    player = Player:new(400, 200, 2)

    -- Charger la feuille de sprites pour les animations
    player.spriteSheet = love.graphics.newImage("spritessheets/character/maincharacter.png")

    -- Créer une grille de sprites (64x128 pour chaque sprite)
    player.grid = anim8.newGrid(64, 128, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    -- Définir les animations (ex : 3 frames pour "down" sur la 1ère ligne)
    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-8', 6), 0.1) -- 0.1 sec par frame

    -- Activer l'animation par défaut
    player.currentAnimation = player.animations.down
end

function love.update(dt)
    -- Mettre à jour l'état du joueur
    player:update(dt)

    -- Mettre à jour l'animation actuelle du joueur
    if player.currentAnimation then
        player.currentAnimation:update(dt)
    end
end

function love.draw()
    -- Dessiner le joueur avec son animation actuelle
    player:draw()
end
