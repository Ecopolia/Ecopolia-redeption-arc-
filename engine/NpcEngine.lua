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
            is_questgiver = npcConfig.is_questgiver or false
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

return NpcEngine
