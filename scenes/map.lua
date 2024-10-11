local map = {}
local mapLoaded = false
local loadingCoroutine = nil
local gamemap = nil
local cam = camera()
local zoomFactor = 40
local mapscale = 0.5

screenWidth = G.WINDOW.WIDTH
screenHeight = G.WINDOW.HEIGHT

local function setupMapPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)
    -- Stage 1: Clear the screen and handle the loading screen
    pipeline:addStage(nil, function()
        love.graphics.clear(0.1, 0.1, 0.1, 1)
        if not mapLoaded then
            love.graphics.print("Chargement de la carte...", 400, 300)
        end
    end)
    
    -- Stage 2: Apply the camera transformation and draw the map
    pipeline:addStage(nil, function()
        if mapLoaded and gamemap then
            gamemap:draw()
        end
    end)

    -- Stage 3: Draw the UI layer on top of the map
    pipeline:addStage(nil, function()
        if mapLoaded then
            if player then
                player:draw()
                world:draw()
            end
        end
    end)
    return pipeline
end

function map:load(args)
    -- Initialize the map loading coroutine
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Activer le rendu pixelisé
    
    loadingCoroutine = coroutine.create(function()
        -- Simulate loading delay
        love.timer.sleep(2)
        -- Load the map
        gamemap = sti('assets/maps/MainMap.lua')

        mapLoaded = true
    end)
    world = bf.newWorld(0, 90.81, true)
    world:newCollider('Rectangle',{600, 200, 50, 50})
    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")

    -- Créer une grille de sprites (64x128 pour chaque sprite)
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    -- Créer une instance du joueur avec position et vitesse initiales
    player = Player:new(700, 300, 100, spriteSheet, grid, world)
    player.anim = player.animations.down

    cam:lookAt(player.x, player.y)
    -- Setup the render pipeline
    self.pipeline = setupMapPipeline()
end

function map:draw()
    if self.pipeline then
        -- Run the pipeline for the map rendering
        self.pipeline:run()
    end
end

function map:update(dt)

    if player then
        player:update(dt)

        -- Mettre à jour l'animation actuelle du joueur
        if player.anim then
            player.anim:update(dt)
        end
    end
    -- Resume loading coroutine if it's still active
    if loadingCoroutine and coroutine.status(loadingCoroutine) ~= "dead" then
        coroutine.resume(loadingCoroutine)
    end

    -- Update logic for the map once it is loaded
    if mapLoaded and gamemap then
        -- Mettre à jour la carte (par exemple, si elle contient des éléments interactifs ou de la physique)
        gamemap:update(dt)
    end

    cam:lookAt(player.x, player.y)
end

return map
