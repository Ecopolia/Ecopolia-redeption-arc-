local map = {}
local mapLoaded = false
local loadingCoroutine = nil
local gamemap = nil
local camera = nil
local zoomFactor = 40
local mapscale = 0.5

function map:load(args)
    -- Démarrer une coroutine pour charger la carte
    loadingCoroutine = coroutine.create(function()
        -- Simuler un délai de chargement (par exemple 2 secondes)
        love.timer.sleep(2)
        -- Charger la carte
        gamemap = sti('assets/maps/MainMap.lua')

        -- Créer la caméra et la centrer sur une position initiale
        camera = Camera(0, 0)
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
        -- Appliquer la transformation de la caméra avec zoom
        camera:zoomTo(zoomFactor)
        camera:attach()

        -- Calcul des limites visibles
        local screen_width = love.graphics.getWidth() / zoomFactor
        local screen_height = love.graphics.getHeight() / zoomFactor

        local cam_x, cam_y = camera:position()

        -- Ajuster les limites à partir du centre de la caméra
        local start_x = math.floor((cam_x - screen_width / 2) / gamemap.tilewidth)
        local start_y = math.floor((cam_y - screen_height / 2) / gamemap.tileheight)
        local end_x = math.ceil((cam_x + screen_width / 2) / gamemap.tilewidth)
        local end_y = math.ceil((cam_y + screen_height / 2) / gamemap.tileheight)
        -- Dessiner uniquement la partie visible de la carte
        if gamemap then
            gamemap:draw(start_x, start_y, end_x, end_y)
        end

        -- Détacher la caméra après le dessin de la carte
        camera:detach()

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
        -- Mettre à jour la carte (par exemple, si elle contient des éléments interactifs ou de la physique)
        gamemap:update(dt)

    end
end

-- -- Gestion du zoom avec la molette de la souris
-- function love.wheelmoved(x, y)
--     if y < 0 then
--         -- DéZoomer
--         zoomFactor = zoomFactor * 1.1
--     elseif y > 0 then
--         -- Zoomer
--         zoomFactor = zoomFactor * 0.9
--     end

--     if(zoomFactor > 40) then
--         zoomFactor = 40
--     end

--     if(zoomFactor < 1) then
--         zoomFactor = 1
--     end

--     print(zoomFactor)
-- end

return map
