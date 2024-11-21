local NpcEngine = {}
NpcEngine.__index = NpcEngine

function NpcEngine.new(config)

    local instance = {
        npcs = {},  -- Stocke toutes les quêtes par ID
        world = G.WORLD,
        camera = G.CAMERA
    }
    setmetatable(instance, NpcEngine)
    return instance
end

-- Fonction pour charger les NPC depuis un fichier JSON
function NpcEngine:loadFromJson(jsonData)
    local npcData = json.decode(jsonData)

    for _, npcConfig in ipairs(npcData) do
        -- Crée un nouveau NPC à partir des données du fichier JSON
        local npc = NpcElement.new({
            id = npcConfig.id,
            x = npcConfig.x,
            y = npcConfig.y,
            w = npcConfig.w,
            h = npcConfig.h,
            scale = npcConfig.scale or 2,
            speed = npcConfig.speed or 30,
            radius = npcConfig.radius or 100,
            clickableRadius = npcConfig.clickableRadius or 50,
            onClick = function()
                -- Exécutez une action personnalisée à la place
                print("NPC clicked!")
            end,
            -- spritesheet = npcConfig.spritesheet,
            color = npcConfig.color,
            world = self.world,
            camera = self.camera,
            path = npcConfig.path or {},
            mode = npcConfig.mode or "random-in-area",
            waitInterval = npcConfig.waitInterval or 0,
            debug = npcConfig.debug or false,
            is_questgiver = npcConfig.is_questgiver or false,
            description = npcConfig.description or ""
        })

        if npcConfig.questgiverSpritesheet then
            npc.questgiverSpritesheet = love.graphics.newImage(npcConfig.questgiverSpritesheet)
        end

        self:addNpc(npc)
    end
end

-- Ajoute une quête au moteur
function NpcEngine:addNpc(npc)
    table.insert(self.npcs, npc)
end

function NpcEngine:setNpcOnClick(npcId, onClickFunction)
    for _, npc in ipairs(npcs) do
        if npc.id == npcId then  -- assuming each NPC has a unique ID
            npc:setOnClick(onClickFunction)
            break
        end
    end
end

function NpcEngine:isVisible(npc)
    local _camera = G.CAMERA
    -- Get screen boundaries based on camera position and screen dimensions
    local screenX, screenY = _camera:worldCoords(0, 0)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    local npcRight = npc.x + 50
    local npcBottom = npc.y + 50

    return npc.x < screenX + screenWidth and npcRight > screenX and
           npc.y < screenY + screenHeight and npcBottom > screenY
end

function NpcEngine:updateVisibility(uiManager, uiNpcElements)
    -- Get all NPC elements currently registered in the UiManager's "npc" scope
    
    for _, npc in ipairs(uiNpcElements) do
        -- Check if the NPC is visible on the screen
        local isVisible = self:isVisible(npc)

        if isVisible and not npc.isRegistered then
            -- Register the NPC if it's visible and not already registered
            uiManager:registerElement("npc", "npc_" .. npc.id, npc)
            npc.isRegistered = true
        elseif not isVisible and npc.isRegistered then
            -- Unregister the NPC if it's not visible and currently registered
            uiManager:removeElement("npc", "npc_" .. npc.id)
            npc.isRegistered = false
        end
    end
end


function NpcEngine:update(dt, uiManager, uiNpcElements)
    self:updateVisibility(uiManager, uiNpcElements)
end


return NpcEngine
