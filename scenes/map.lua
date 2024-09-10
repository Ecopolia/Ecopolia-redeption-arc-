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
end

return map
