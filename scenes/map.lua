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

    gamemap = sti('assets/maps/MainMap.lua' , { "box2d" })
    world = bf.newWorld(0, 90.81, true)
    if gamemap.layers["Wall"] then 
        for i, obj in pairs(gamemap.layers["Wall"].objects) do
            world:newCollider('Rectangle',{obj.x + obj.width/2, obj.y + obj.height/2, obj.width, obj.height})
        end
    end
    mapLoaded = true

    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    player = Player:new(600, 300, 100, spriteSheet, grid, world)
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
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local mapWidth = gamemap.width * gamemap.tilewidth
    local mapHeight = gamemap.height * gamemap.tileheight

    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < (h/2)  then
        cam.y = (h/2)
    end

    if cam.x > (mapWidth - w/2)  then
        cam.x = (mapWidth - w/2)
    end

    if cam.y > (mapHeight - h/2)  then
        cam.y = (mapHeight - h/2)
    end
end

return map
