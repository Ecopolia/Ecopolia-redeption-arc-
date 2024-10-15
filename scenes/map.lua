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
        uiManager:draw("map")
        -- world:draw()
        cam:detach()
    end)
    return pipeline
end

function map:load(args)
    love.graphics.setDefaultFilter("nearest", "nearest")
    gamemap = sti('assets/maps/MainMap.lua' , { "box2d" })
    world = bf.newWorld(0, 90.81, true)
    if gamemap.layers["Wall"] then 
        for i, obj in pairs(gamemap.layers["Wall"].objects) do
            world:newCollider('Rectangle',{obj.x + obj.width/2, obj.y + obj.height/2, obj.width, obj.height})
        end
    end
    

    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    player = Player:new(570, 200, 100, spriteSheet, grid, world)
    player.anim = player.animations.down

    local npc_random = NpcElement.new({
        x = 515,
        y = 260,
        w = 50,
        h = 50,
        scale = 2,
        speed = 30,
        radius = 50,
        clickableRadius = 20,
        onClick = function() print("NPC clicked!") end,
        world = world
    })

    -- uiManager:registerElement("npc_test", "npc_path", npc_path)
    -- uiManager:registerElement("npc_test", "npc_tour", npc_tour)
    uiManager:registerElement("map", "npc_random", npc_random)
    self.timer = Timer.new()
    self.pipeline = setupMapPipeline()

    mapLoaded = true
end

function map:draw()
    if self.pipeline then
        self.pipeline:run()
    end

end

function map:update(dt)

    if mapLoaded then 
        if player then
            cam:lookAt(player.x + 64 , player.y + 64)
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
    
        if gamemap ~= nil then
            local mapWidth = gamemap.width * gamemap.tilewidth
            local mapHeight = gamemap.height * gamemap.tileheight
        end
    
        if cam.x < w/2 then
            cam.x = w/2
        end
    
        if cam.y < (h/2)  then
            cam.y = (h/2)
        end
    
        if mapHeight ~= nil then
            if cam.x > (mapWidth - w/2)  then
                cam.x = (mapWidth - w/2)
            end
        
            if cam.y > (mapHeight - h/2)  then
                cam.y = (mapHeight - h/2)
            end
        end
    
        self.timer:update(dt)
    
        -- Update the UI
        uiManager:update("map", dt)
    end
end

return map
