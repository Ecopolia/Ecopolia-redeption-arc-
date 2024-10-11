local map = {}
local mapLoaded = false
local loadingCoroutine = nil
local gamemap = nil
local cam = camera()
local zoomFactor = 40
local mapscale = 0.5
local collision = nil

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
            
            -- gamemap:drawWorldCollision(collision)
        end
    end, gamemap.width*16, gamemap.height*16)

    -- Stage 3: Draw the UI layer on top of the map
    pipeline:addStage(nil, function()
        cam:attach()
        gamemap:drawLayer(gamemap.layers["Ground"])
        gamemap:drawLayer(gamemap.layers["tronc"])
        gamemap:drawLayer(gamemap.layers["Roc"])
        gamemap:drawLayer(gamemap.layers["Batiment"])
        gamemap:drawLayer(gamemap.layers["feuille1"])
        gamemap:drawLayer(gamemap.layers["feuille2"])
        gamemap:drawLayer(gamemap.layers["feuille3"])
        gamemap:drawLayer(gamemap.layers["feuille4"])
        gamemap:drawLayer(gamemap.layers["feuille5"])
        player:draw()
        world:draw()
        cam:detach()
    end)
    return pipeline
end

function map:load(args)

    gamemap = sti('assets/maps/MainMap.lua')
    mapLoaded = true

    -- love.physics.setMeter(32)
    -- world = love.physics.newWorld(0*love.physics.getMeter(), 0*love.physics.getMeter())
    -- if gamemap then
    --     collision = gamemap:initWorldCollision(world)
    -- end
    

    world = bf.newWorld(0, 90.81, true)
    world:newCollider('Rectangle',{600, 200, 50, 50})
    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")

    -- Créer une grille de sprites (64x128 pour chaque sprite)
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    -- Créer une instance du joueur avec position et vitesse initiales
    player = Player:new(700, 300, 100, spriteSheet, grid, world)
    player.anim = player.animations.down

    self.pipeline = setupMapPipeline()
end

function map:draw()
    if self.pipeline then
        self.pipeline:run()
    end

end

function map:update(dt)

    if player then
        cam:lookAt(player.position.x , player.position.y)
        player:update(dt)

        -- Mettre à jour l'animation actuelle du joueur
        if player.anim then
            player.anim:update(dt)
        end
        
    end

    -- Update logic for the map once it is loaded
    if mapLoaded and gamemap then
        -- Mettre à jour la carte (par exemple, si elle contient des éléments interactifs ou de la physique)
        gamemap:update(dt)
    end
    
    -- local mapWidth = gamemap.width * gamemap.tilewidth
    -- local mapHeight = gamemap.height * gamemap.tileheight

    -- if cam.x > (mapWidth - screenWidth/2)  then
    --     cam.x = (mapWidth - screenWidth/2)
    -- end

    -- if cam.y > (mapHeight - screenHeight/2)  then
    --     cam.y = (mapHeight - screenHeight/2)
    -- end
end

return map
