local map = {}
local mapLoaded = false
local loadingCoroutine = nil

function map:load(args)
    -- Démarrer une coroutine pour charger la carte
    loadingCoroutine = coroutine.create(function()
        -- Simuler un délai de chargement (par exemple 2 secondes)
        love.timer.sleep(2)
        -- Charger la carte
        gamemap = sti('assets/maps/test.lua')
        -- Indiquer que la carte est chargée
        mapLoaded = true
    end)
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Activer le rendu pixelisé

    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")

    -- Créer une grille de sprites (64x128 pour chaque sprite)
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    -- Créer une instance du joueur avec position et vitesse initiales
    player = Player:new(400, 200, 20, spriteSheet, grid)
    player.anim = player.animations.down


end

function map:draw()
    -- Clear the screen with black color
    love.graphics.clear(0.1, 0.1, 0.1, 1)

    if not mapLoaded then
        -- Afficher l'écran de chargement
        love.graphics.print("Chargement de la carte...", 400, 300)
    else
        -- Afficher la carte une fois qu'elle est chargée
        if gamemap then
            gamemap:draw()
        end

        -- Afficher l'UI une fois que la carte est prête
        uiManager:draw("map")
    end
end

function map:update(dt)
    -- Vérifier si la coroutine de chargement est en cours et la relancer
    if loadingCoroutine and coroutine.status(loadingCoroutine) ~= "dead" then
        coroutine.resume(loadingCoroutine)
    end

    -- Logique supplémentaire pour l'update une fois que la carte est chargée
    if mapLoaded and gamemap then
        gamemap:update(dt)
    end
    if player then
        player:update(dt)

        -- Mettre à jour l'animation actuelle du joueur
        if player.anim then
            player.anim:update(dt)
        end
    end
end

return map
