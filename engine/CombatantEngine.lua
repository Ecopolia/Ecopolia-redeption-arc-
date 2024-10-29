local CombatantEngine = {}
CombatantEngine.__index = CombatantEngine

-- Constructeur du CombatantEngine
function CombatantEngine.new(config)
    local instance = {
        combatants = {},  -- Stocke tous les combattants
    }
    setmetatable(instance, CombatantEngine)
    return instance
end

-- Fonction pour charger les combattants depuis un fichier JSON
function CombatantEngine:loadFromJson(jsonData)
    local combatantData = json.decode(jsonData)

    for _, combatantConfig in ipairs(combatantData) do
        -- Crée un nouveau combattant à partir des données du fichier JSON
        local combatant = Combatant:new(
            combatantConfig.id,
            combatantConfig.type,
            combatantConfig.name,
            combatantConfig.hp,
            combatantConfig.attack,
            combatantConfig.defense,
            combatantConfig.speed,
            combatantConfig.manaCost,
            combatantConfig.classType,
            combatantConfig.spriteSheet
        )

        -- Ajoute le combattant au moteur
        self:addCombatant(combatant)
    end
end

-- Ajoute un combattant au moteur
function CombatantEngine:addCombatant(combatant)
    table.insert(self.combatants, combatant)
end

return CombatantEngine
