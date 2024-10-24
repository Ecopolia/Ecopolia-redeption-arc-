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
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Activer le rendu pixelisé

    -- Créer une instance du joueur avec position et vitesse initiales
    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")

    -- Créer une grille de sprites (64x128 pour chaque sprite)
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    -- Créer une instance du joueur avec position et vitesse initiales
    player = Player:new(485, 170, 100, spriteSheet, grid)

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
