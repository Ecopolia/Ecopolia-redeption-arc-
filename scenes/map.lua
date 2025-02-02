local map = {}
local mapLoaded = false
local loadingCoroutine = nil
local gamemap = nil
local cam = G.CAMERA
local zoomFactor = 40
local mapscale = 0.5
local collision = true
local colliders = {}
local rewardText = nil -- Texte de la récompense
local rewardTimer = 0 -- Durée pendant laquelle afficher la récompense


local save_and_load = require 'engine/save_and_load'

screenWidth = G.WINDOW.WIDTH
screenHeight = G.WINDOW.HEIGHT

local minimapScale = 0.1
local debug = false

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

    end)

    -- Stage 3: Draw the UI layer on top of the map
    pipeline:addStage(nil, function()
        cam:attach()
        gamemap:drawLayer(gamemap.layers["Ground"])
        gamemap:drawLayer(gamemap.layers["OnGround"])
        gamemap:drawLayer(gamemap.layers["tronc"])
        gamemap:drawLayer(gamemap.layers["Roc"])
        -- gamemap:drawLayer(gamemap.layers["Batiment"])
        gamemap:drawLayer(gamemap.layers["feuille1"])
        gamemap:drawLayer(gamemap.layers["feuille2"])
        gamemap:drawLayer(gamemap.layers["feuille3"])
        gamemap:drawLayer(gamemap.layers["feuille4"])
        gamemap:drawLayer(gamemap.layers["feuille5"])
        player:draw()
        uiManager:draw("npc")
        if debug == true then
            world:draw()
        end
        cam:detach()
        uiManager:draw("map")
        
    end)

    -- Stage 3: Minimap rendering stage
    pipeline:addStage(nil, function()
        -- Minimap dimensions and position on the screen
        local minimapWidth, minimapHeight = 150, 150 -- Set a fixed size for the minimap
        local minimapX, minimapY = G.WINDOW.WIDTH - minimapWidth - 10, G.WINDOW.HEIGHT - minimapHeight - 10 -- Bottom-right corner

        -- Set the size of the minimap "camera" view (the visible area of the map on the minimap)
        local mapViewWidth = minimapWidth / minimapScale
        local mapViewHeight = minimapHeight / minimapScale

        -- Calculate the top-left corner of the visible map area in the minimap, so the player is centered
        local mapMinX = player.x - mapViewWidth / 2
        local mapMinY = player.y - mapViewHeight / 2

        -- Clamp mapMinX and mapMinY to prevent showing areas outside the map
        mapMinX = math.max(0, math.min(mapMinX, gamemap.width * gamemap.tilewidth - mapViewWidth))
        mapMinY = math.max(0, math.min(mapMinY, gamemap.height * gamemap.tileheight - mapViewHeight))

        -- Draw the minimap with scissor (only draw within minimap bounds)
        love.graphics.setScissor(minimapX, minimapY, minimapWidth, minimapHeight) -- Limit drawing to minimap area
        love.graphics.push()

        -- Translate the minimap to its on-screen position and scale
        love.graphics.translate(minimapX, minimapY)
        love.graphics.scale(minimapScale, minimapScale)

        -- Move the map so the player is centered in the minimap
        love.graphics.translate(-mapMinX, -mapMinY)

        -- Draw the relevant map layers (scaled down)
        gamemap:drawLayer(gamemap.layers["Ground"])
        gamemap:drawLayer(gamemap.layers["OnGround"])
        gamemap:drawLayer(gamemap.layers["tronc"])
        gamemap:drawLayer(gamemap.layers["Roc"])
        -- gamemap:drawLayer(gamemap.layers["Batiment"])
        gamemap:drawLayer(gamemap.layers["feuille1"])
        gamemap:drawLayer(gamemap.layers["feuille2"])
        gamemap:drawLayer(gamemap.layers["feuille3"])
        gamemap:drawLayer(gamemap.layers["feuille4"])
        gamemap:drawLayer(gamemap.layers["feuille5"])

        -- Draw the player as a small red circle at the center of the minimap
        love.graphics.setColor(1, 0, 0) -- Red color for the player
        local playerMinimapX = player.x -- The player should remain centered, so no further translation
        local playerMinimapY = player.y
        -- love.graphics.circle("fill", npc_random.position.x, npc_random.position.y, 5/minimapScale)
        love.graphics.setColor(1, 1, 1) -- Reset color
        love.graphics.setColor(0, 0, 1)
        drawArrow(playerMinimapX, playerMinimapY, 10 / minimapScale, player.direction)
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
        love.graphics.setScissor() -- Reset scissor

        -- Draw the minimap's border
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", minimapX, minimapY, minimapWidth, minimapHeight)
        love.graphics.setColor(1, 1, 1) -- Reset color
    end)

    pipeline:addStage(G.SHADERS['TRN'], function()
        -- The pipeline will automatically handle canvas switching, so you just draw
    end)

    return pipeline
end

function drawArrow(x, y, size, direction)
    local arrow = {
        0 * size, -0.6 * size,
        0.5 * size, 0.2 * size,
        0.35 * size, 0.4 * size,
        -0.35 * size, 0.4 * size,
        -0.5 * size, 0.2 * size
    }


    local angle = 0
    if direction == "right" then
        angle = math.pi / 2
    elseif direction == "down" then
        angle = math.pi
    elseif direction == "left" then
        angle = -math.pi / 2
    end

    -- Rotate and draw the polygon arrow
    love.graphics.push()
    love.graphics.translate(x, y)  -- Move to player's position
    love.graphics.rotate(angle)    -- Rotate based on direction
    love.graphics.polygon("fill", arrow)  -- Draw the arrow
    love.graphics.pop()
end

function map:load(args)
    ManualtransitionIn()
    love.graphics.setDefaultFilter("nearest", "nearest")
    gamemap = sti('assets/maps/MainMap.lua', {"box2d"})
    world = G.WORLD

    if gamemap.layers["Wall"] then
        colliders = gamemap:initWalls(gamemap.layers["Wall"], world)
    end

    z = false
    q = false
    s = false
    d = false
    inDialogue = false

    spriteSheet = love.graphics.newImage("assets/spritesheets/character/maincharacter.png")
    grid = anim8.newGrid(64, 64, spriteSheet:getWidth(), spriteSheet:getHeight())
    local playerData = nil
    if args and args.slot then
        print("Loaded with slot:", args.slot)
        G:setCurrentSlot(args.slot) -- Set the current slot
        playerData = save_and_load.load(args.slot)
    end

    for key, quest in ipairs(quests.quests) do
        if save_and_load.get_quest_data(args.slot, quest.id) then
            quest.isCompleted = save_and_load.get_quest_data(args.slot, quest.id).isCompleted
        end
    end

    if playerData then
        player = Player:new(playerData.x, playerData.y, playerData.speed, spriteSheet, grid, world)
        player.health = playerData.health
    else
        player = Player:new(570, 200, 100, spriteSheet, grid, world)
    end

    player.anim = player.animations.down
    
    for key, npc in ipairs(npcs.npcs) do
        local render = true
        for key2, questid in ipairs(npc.questids) do
            quest = findbyid(quests.quests, questid)
            if quest.isCompleted == false then 
                for key3, needquestid in ipairs(quest.prerequisites) do
                    if save_and_load.get_quest_data(args.slot, needquestid).isCompleted == false then
                        render = false
                    end
                end
            else
                render = false
            end
        end
        
        if render == true then
            uiManager:registerElement("npc", "npc_"..npc.id , npc)
        end
    end

    questInProgress = getNextQuest(quests)

    -- uiManager:registerElement("npc", "npc_random", npc_random)

    self.timer = Timer.new()
    self.pipeline = setupMapPipeline()

    if gamemap and player then
        mapLoaded = true
    end


    echapWindow = Window.new({
        x = G.WINDOW.WIDTH / 2 - 200,
        y = G.WINDOW.HEIGHT / 2 - 250,
        w = 400,
        h = 500,
        z = 10,
        borderThickness = 0,
        title = "",
        uiAtlas = G.UiAtlas_Animation,
        font = G.Fonts.m6x11plus_medium,
        visible = false,
        color = {0.5, 0.5, 0.9}
    })
    uiManager:registerElement('map', 'echapWindow', echapWindow)
    uiManager:hideElement('map', 'echapWindow')

    local returnTitleButton = Button.new({
        text = "[shake=0.4][breathe=0.2]Retour au menu principal[/shake][/breathe]",
        dsfull = false,
        x = echapWindow.x + (300 - 200) / 2, -- Center horizontally in echapWindow
        y = echapWindow.y + (400 - 60) / 2,  -- Center vertically in echapWindow
        w = 300,
        h = 60,
        z = 11,
        onClick = function()
            uiManager:hideElement("map", "echapWindow")
            uiManager:hideElement("map", "returnTitleButton")
            self.setScene('main_menu', { from = 'map' })
        end,
        css = {
            backgroundColor = {0, 0.5, 0},
            hoverBackgroundColor = {0, 1, 0},
            textColor = {1, 1, 1},
            hoverTextColor = {0, 0, 0},
            borderColor = {1, 1, 1},
            borderRadius = 10,
            font = G.Fonts.m6x11plus_medium
        }
    })

    local saveButton = Button.new({
        text = "[shake=0.4][breathe=0.2]Sauvegarder[/shake][/breathe]",
        dsfull = false,
        x = echapWindow.x + (400 - 220) / 2, -- Center horizontally in echapWindow
        y = echapWindow.y + (600 - 60) / 2,  -- Center vertically in echapWindow
        w = 220,
        h = 60,
        z = 11,
        onClick = function()
            uiManager:hideElement("map", "echapWindow")
            uiManager:hideElement("map", "returnTitleButton")
            uiManager:hideElement("map", "saveButton")
            save_and_load.save(player, args.slot, G:getPlaytime(args.slot), "Zone du début")
        end,
        css = {
            backgroundColor = {0, 0.5, 0},
            hoverBackgroundColor = {0, 1, 0},
            textColor = {1, 1, 1},
            hoverTextColor = {0, 0, 0},
            borderColor = {1, 1, 1},
            borderRadius = 10,
            font = G.Fonts.m6x11plus_medium
        }
    })
    
    -- Register the button in the UI Manager within the 'map' scene context for echapWindow
    uiManager:registerElement("map", "returnTitleButton", returnTitleButton)
    uiManager:hideElement("map", "returnTitleButton")
    uiManager:registerElement("map", "saveButton", saveButton)
    uiManager:hideElement("map", "saveButton")

    fpsGraph = debugGraph:new('fps', 20, 10, 50, 30, 0.5, 'fps', love.graphics.newFont(16))
    memGraph = debugGraph:new('mem', 20, 40, 50, 30, 0.5, 'mem', love.graphics.newFont(16))
    dtGraph = debugGraph:new('custom', 20, 70, 50, 30, 0.5, 'custom', love.graphics.newFont(16))

    lastPlayerPosition = { x = player.x, y = player.y }
    visibilityCheckDistance = 50
    firstcheck = true

    uiNpcElements = uiManager:findElements("npc", "^npc_")
end

function map:draw()
    if self.pipeline then
        self.pipeline:run()
    end

    if questInProgress then
        love.graphics.setColor(1, 1, 1, 1) -- Couleur blanche pour le texte
        love.graphics.setFont(G.Fonts.m6x11plus_medium) -- Remplacez par la police que vous utilisez
        local textX = G.WINDOW.WIDTH - 300 -- Position X en haut à droite
        local textY = 10 -- Position Y
        love.graphics.printf("Quête : " .. questInProgress.name, textX, textY, 280, "right")
        love.graphics.printf("Description : " .. questInProgress.description, textX, textY + 20, 280, "right")
    end

    -- Affichage du texte de récompense en haut de l'écran
    if rewardText then
        love.graphics.setColor(1, 1, 0, 1) -- Couleur jaune pour attirer l'attention
        love.graphics.setFont(G.Fonts.m6x11plus_medium) -- Police utilisée (à adapter selon votre projet)
        local textX = G.WINDOW.WIDTH / 2 -- Centré horizontalement
        local textY = 20 -- Décalage vertical en haut
        love.graphics.printf(rewardText, textX - 200, textY, 400, "center") -- Affiche le texte centré
        love.graphics.setColor(1, 1, 1, 1) -- Réinitialise la couleur
    end

    

    if version == 'dev-mode' and debug == true then
        -- Draw graphs
        fpsGraph:draw()
        memGraph:draw()
        dtGraph:draw()
    end

    if SaveDialogue then
        SaveDialogue:draw()
    end

    if questDialogue then
        questDialogue:draw()
    end

end

function map:update(dt)

    -- Mise à jour du timer pour le texte de récompense
    if rewardText and rewardTimer > 0 then
        rewardTimer = rewardTimer - dt
        if rewardTimer <= 0 then
            rewardText = nil -- Supprime le texte après expiration du timer
        end
    end

    if not questInProgress then
        questInProgress = getNextQuest(quests)
    end

    if questInProgress and questInProgress.id == 1 then
        -- Logique pour la quête 1

        if z and q and s and d then
            movementKeysPressed = true
        else
            movementKeysPressed = false
        end

        if not questDialogue and not inDialogue then
            inDialogue = true
            questDialogue = LoveDialogue.play("dialogs/quest_1.ld", {
                enableFadeIn = false,
                enableFadeOut = false,
                fadeInDuration = 0,
                fadeOutDuration = 0,
            })
        end
    
        if questDialogue and not questDialogue.isActive then
            -- Actions après la fin du dialogue de la quête 1
            if movementKeysPressed then
                inDialogue = false
                questDialogue = nil
                questInProgress:complete()
                rewardText = questInProgress.rewardText
                rewardTimer = 3
                questInProgress = getNextQuest(quests)
            else
                questDialogue = LoveDialogue.play("dialogs/quest_1retry.ld", {
                    enableFadeIn = false,
                    enableFadeOut = false,
                    fadeInDuration = 0,
                    fadeOutDuration = 0,
                })
            end
        end
    end
    
    if questInProgress and questInProgress.id == 2 then
        -- Logique pour la quête 2
        if not npcquest2 then
            npcquest2 = findbyid(npcs.npcs, 3)
            npcquest2:setQuestGiverState(true)
            npcquest2.onClick = (function()
                inDialogue = true
                npcquest2Click = true
                questDialogue = LoveDialogue.play("dialogs/quest_2.ld", {
                    enableFadeIn = false,
                    enableFadeOut = false,
                    fadeInDuration = 0,
                    fadeOutDuration = 0,
                })
            end)
        end
    
        if questDialogue and not questDialogue.isActive and npcquest2Click then
            -- Actions après la fin du dialogue de la quête 2
            inDialogue = false
            npcquest2:setQuestGiverState(false)
            questInProgress:complete()
            rewardText = questInProgress.rewardText
            rewardTimer = 3
            questInProgress = getNextQuest(quests)
        end
    end
    
    
    if questInProgress and questInProgress.id == 3 then
        if not npcquest3 then
            npcquest3 = findbyid(npcs.npcs, 1)
            npcquest3:setQuestGiverState(true)
            npcquest3.onClick = (function()
                inDialogue = true
                npcquest3Click = true
                questDialogue = LoveDialogue.play("dialogs/quest_3.ld", {
                    enableFadeIn = false,
                    enableFadeOut = false,
                    fadeInDuration = 0,
                    fadeOutDuration = 0,
                })
            end)
        end

        if questDialogue and not questDialogue.isActive and npcquest3Click and inDialogue == true then
            -- Actions après la fin du dialogue de la quête 3
            inDialogue = false
            npcquest3:setQuestGiverState(false)
            self.setScene('testcombat')
        end
    end
    
    

    if mapLoaded then
        if player then
            cam:lookAt(player.x + 64, player.y + 64)
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
            -- print(cam:mousePosition(npc_random.position.x, npc_random.position.y , G.WINDOW.WIDTH, G.WINDOW.HEIGHT))
        end

        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()

        if gamemap ~= nil then
            local mapWidth = gamemap.width * gamemap.tilewidth
            local mapHeight = gamemap.height * gamemap.tileheight
        end

        if cam.x < w / 2 then
            cam.x = w / 2
        end

        if cam.y < (h / 2) then
            cam.y = (h / 2)
        end

        if mapHeight ~= nil then
            if cam.x > (mapWidth - w / 2) then
                cam.x = (mapWidth - w / 2)
            end

            if cam.y > (mapHeight - h / 2) then
                cam.y = (mapHeight - h / 2)
            end
        end

        self.timer:update(dt)

        -- Update the UI
        uiManager:update("map", dt)
        uiManager:update("npc", dt)

        if SaveDialogue then
            SaveDialogue:update(dt)
        end

        if questDialogue then
            questDialogue:update(dt)
        end

        if debug then
            fpsGraph:update(dt)
            memGraph:update(dt)
            dtGraph:update(dt, math.floor(dt * 1000))
            dtGraph.label = 'DT: ' .. math.round(dt, 4)
            print(love.mouse.getPosition())
        end

    end
end

function map:keypressed(key) 
    if key == 'f3' then
        debug = not debug
    end
    if key == 'f4' and debug then
        if collision == true then
            for _, collider in ipairs(colliders) do
                if collider and collider.destroy then
                    collider:destroy()
                end
            end
            colliders = {}
            collision = false
        else
            if gamemap.layers["Wall"] then
                colliders = gamemap:initWalls(gamemap.layers["Wall"], world)
            end
            collision = true
        end
    end
    if key == 'z' then
        z = true
    end
    if key == 'q' then
        q = true
    end
    if key == 's' then
        s = true
    end
    if key == 'd' then
        d = true
    end
    if SaveDialogue then
        SaveDialogue:keypressed(key)
    end
    if questDialogue then
        questDialogue:keypressed(key)
    end
    if key == 'escape' then
        if echapWindow.visible == false and inDialogue == false then 
            uiManager:showElement('map', 'echapWindow')
            uiManager:showElement("map", "returnTitleButton")
            uiManager:showElement("map", "saveButton")
            -- uiManager:freezeElement("npc", "npc_random")
        elseif echapWindow.visible == true and inDialogue == false then
            uiManager:hideElement('map', 'echapWindow')
            uiManager:hideElement("map", "returnTitleButton")
            uiManager:hideElement("map", "saveButton")
            -- uiManager:unfreezeElement("npc", "npc_random")
        end
    end
end

return map
