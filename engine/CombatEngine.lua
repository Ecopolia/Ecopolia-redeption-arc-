CombatEngine = {}
CombatEngine.__index = CombatEngine

-- Fonction de création d'un nouvel objet CombatEngine
function CombatEngine:new(player, enemies)
    local instance = {
        player = player,
        enemies = enemies,
        allies = player.allies,
        turnOrder = {},
        currentTurnIndex = 1,
        isCombatActive = true
    }

    instance.turnOrder = instance:calculateTurnOrder()

    setmetatable(instance, CombatEngine)
    return instance
end

-- Fonction pour calculer l'ordre des tours basé sur la vitesse
function CombatEngine:calculateTurnOrder()
    local allCombatants = {self.player}
    
    for _, ally in ipairs(self.allies) do
        table.insert(allCombatants, ally)
    end

    for _, enemy in ipairs(self.enemies) do
        table.insert(allCombatants, enemy)
    end

    table.sort(allCombatants, function(a, b) return a.speed > b.speed end)

    return allCombatants
end

-- Fonction pour gérer un tour de combat
function CombatEngine:processTurn()
    if not self.isCombatActive then
        print("Le combat est terminé.")
        return
    end

    local currentCombatant = self.turnOrder[self.currentTurnIndex]

    if currentCombatant == self.player then
        local action = "summon"  -- Exemple d'action (cela pourrait être un choix du joueur)
        
        if action == "attack" then
            local target = self.enemies[1]
            self.player:attackTarget(target)
        elseif action == "summon" then
            -- Utilise la fonction chooseSummon pour choisir un allié à invoquer
            local chosenAlly = self.player:chooseSummon()
            if chosenAlly then
                self.player:summonAlly(chosenAlly)
            end
        end
    elseif currentCombatant.__index == Ally then
        currentCombatant:attackTarget(self.enemies[1])
    elseif currentCombatant.__index == Enemy then
        currentCombatant:chooseAction(self.enemies, self.turnOrder)
    end

    self:nextTurn()
end

-- Fonction pour démarrer le combat
function CombatEngine:startCombat()
    print("Le combat commence !")

    while self.isCombatActive do
        self:processTurn()
    end
end

return CombatEngine
