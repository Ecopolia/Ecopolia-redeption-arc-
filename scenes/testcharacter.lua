testcharacter = {}


local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        if player then
            player:draw()
        end
    end)

    -- Add the CRT shader stage
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end


function testcharacter:load()
    anim8 = require 'libs/anim8' -- Charger la bibliothèque anim8
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Activer le rendu pixelisé

    -- Créer une instance du joueur avec position et vitesse initiales
    player = Player:new(400, 200, 20)

    -- Charger la feuille de sprites pour les animations
    player.spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")

    -- Créer une grille de sprites (64x128 pour chaque sprite)
    player.grid = anim8.newGrid(64, 64, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    -- Définir les animations (ex : 3 frames pour "down" sur la 1ère ligne)
    player.animations = {}
    player.animations.up = anim8.newAnimation(player.grid('1-9', 9), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-9', 10), 0.2)
    player.animations.idledown = anim8.newAnimation(player.grid(1, 7), 0.1)
    player.animations.right = anim8.newAnimation(player.grid('1-9', 12), 0.2)
    player.animations.down = anim8.newAnimation(player.grid('1-9', 11), 0.2) -- 0.1 sec par frame

    -- Activer l'animation par défaut
    player.anim = player.animations.down

    player.currentAnimation = player.animations.down
    player.idleAnimation = player.animations.idledown

    -- Setup the rendering pipeline
    self.pipeline = setupPipeline()
end

function testcharacter:update(dt)
    if player then
        player:update(dt)

        -- Mettre à jour l'animation actuelle du joueur
        if player.anim then
            player.anim:update(dt)
        end
    end
end

function testcharacter:draw()
    if not self.pipeline then
        print("Waiting for pipeline to draw")
        return
    end
    self.pipeline:run()
end

return testcharacter