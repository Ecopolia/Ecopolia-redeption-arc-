-- Scène de combat
CombatScene = {}
CombatScene.__index = CombatScene

-- Fonction de création d'une nouvelle scène de combat
function CombatScene:new(player, enemies)
    local instance = {
        player = player,  -- Joueur de la scène de combat
        enemies = enemies,  -- Liste des ennemis
        allies = {},
        turnOrders = {},
        currentTurnIndex = 0,
        gameState = "start",  -- Indicateur de l'état du jeu (playerTurn, enemyTurn, etc.)
        actionSelected = nil,  -- Action sélectionnée par le joueur (attack, summon)
        targetIndex = 1,  -- Indice de la cible actuelle pour l'attaque ou l'invocation
        choosingTarget = false,  -- Indicateur si le joueur est en train de choisir une cible
        choosingAlly = false  -- Indicateur si le joueur est en train de choisir un allié à invoquer
    }

    setmetatable(instance, CombatScene)
    return instance
end

-- Fonction pour charger la scène (invoqué par LOVE)
function CombatScene:load()
    print("Chargement de la scène de combat...")
end

function CombatScene:calculateTurnOrder()
    local allCombatants = {self.player}

    -- Ajouter tous les alliés invoqués
    if self.allies ~= nil then
        for _, ally in ipairs(self.allies) do
            table.insert(allCombatants, ally)
        end
    end

    -- Ajouter tous les ennemis
    for _, enemy in ipairs(self.enemies) do
        table.insert(allCombatants, enemy)
    end

    -- Trier les combattants par vitesse (du plus rapide au plus lent)
    table.sort(allCombatants, function(a, b) return a.speed > b.speed end)
    self.currentTurnIndex = 1
    return allCombatants
end

-- Fonction pour mettre à jour la scène (processus du combat)
function CombatScene:update(dt)
    if self.gameState == "start" then
        self.turnOrders = self:calculateTurnOrder()
        self.gameState = "processturn"
    end

    if self.gameState == "processturn" then
        self:processTurn()
    end

    if self.gameState == "nextturn" then
        
    end
end

-- Fonction pour gérer les entrées du joueur (utilisation de love.keypressed)
function CombatScene:keypressed(key)
    if self.gameState == "playerTurn" and (self.choosingTarget == false or self.choosingAlly == false) then
        if key == "a" then
            self:chooseTarget()
        elseif key == "s" then
            self:chooseAlly()
        end
    elseif self.choosingTarget and (key == "up" or key == "down") then
        self:changeTargetSelection(key)
    elseif self.choosingAlly and (key == "up" or key == "down") then
        self:changeAllySelection(key)
    elseif key == "return" and (self.choosingTarget or self.choosingAlly) then
        self:confirmAction()
        self.currentTurnIndex = self.currentTurnIndex + 1
        self.gameState = "processturn"
    end
end

function CombatScene:processTurn()
    local currentCombatant = self.turnOrders[self.currentTurnIndex]
    -- Gestion des actions du joueur
    if currentCombatant == self.player then
        self.gameState = "playerTurn"
    -- Gestion des actions des alliés
    elseif currentCombatant.__index == Ally then
        currentCombatant:chooseAction(self.allies, self.enemies, self.player)
        self.currentTurnIndex = self.currentTurnIndex + 1
    elseif currentCombatant.__index == Enemy then
        currentCombatant:chooseAction(self.allies, self.enemies, self.player)
        self.currentTurnIndex = self.currentTurnIndex + 1
    end

    if self.currentTurnIndex > #self.turnOrders then
        self.currentTurnIndex = 1
    end 
end

-- Fonction pour choisir une cible à attaquer
function CombatScene:chooseTarget()
    self.gameState = "chooseTarget"
    if #self.enemies > 0 then
        self.targetIndex = 1  -- Commence à la première cible (premier ennemi)
        self.choosingTarget = true  -- Indique qu'on est en train de choisir une cible
    else
        print("Pas d'ennemis disponibles.")
        self.choosingTarget = false
    end
end

-- Fonction pour choisir un allié à invoquer
function CombatScene:chooseAlly()
    self.gameState = "chooseAlly"
    if #self.player.inventory > 0 then
        self.targetIndex = 1  -- Commence avec le premier allié de l'inventaire
        self.choosingAlly = true  -- Indique qu'on est en train de choisir un allié
    else
        print("Pas d'alliés disponibles dans l'inventaire.")
        self.choosingAlly = false
        self.actionSelected = nil  -- Redemander une action si l'inventaire est vide
        self.gameState = "playerTurn"
    end
end

-- Fonction pour changer la sélection de la cible avec les flèches directionnelles
function CombatScene:changeTargetSelection(key)
    if key == "up" then
        self.targetIndex = self.targetIndex - 1
        if self.targetIndex < 1 then self.targetIndex = #self.enemies end
    elseif key == "down" then
        self.targetIndex = self.targetIndex + 1
        if self.targetIndex > #self.enemies then self.targetIndex = 1 end
    end
end

-- Fonction pour changer la sélection de l'allié à invoquer avec les flèches directionnelles
function CombatScene:changeAllySelection(key)
    if key == "up" then
        self.targetIndex = self.targetIndex - 1
        if self.targetIndex < 1 then self.targetIndex = #self.player.inventory end
    elseif key == "down" then
        self.targetIndex = self.targetIndex + 1
        if self.targetIndex > #self.player.inventory then self.targetIndex = 1 end
    end
end

-- Confirmer l'action du joueur (attaque ou invocation)
function CombatScene:confirmAction()
    if self.choosingTarget then
        self:processPlayerAction("attack", self.enemies[self.targetIndex])
        self.choosingTarget = false
    elseif self.choosingAlly then
        local allyToSummon = self.player.inventory[self.targetIndex]
        self.player:summonAlly(allyToSummon)
        self.choosingAlly = false
    end
end

-- Fonction pour gérer les actions du joueur
function CombatScene:processPlayerAction(action, target)
    if action == "attack" then
        self.player:attackTarget(target)
    end
end

-- Fonction pour dessiner la scène (invoqué par LOVE)
function CombatScene:draw()
    -- Affichage des stats du joueur
    love.graphics.print("Joueur: " .. self.player.hp .. " HP | Mana: " .. self.player.mana, 10, 10)

    -- Afficher les ennemis et leurs stats
    for i, enemy in ipairs(self.enemies) do
        local indicator = (self.choosingTarget and i == self.targetIndex) and ">" or " "
        love.graphics.print(indicator .. enemy.name .. ": " .. enemy.hp .. " HP", 10, 50 + i * 20)
    end

    -- Afficher les alliés invoqués
    for i, ally in ipairs(self.player.allies) do
        love.graphics.print("Allié: " .. ally.name .. " (HP: " .. ally.hp .. ")", 200, 50 + i * 20)
    end

    -- Afficher l'inventaire lors de l'invocation
    if self.choosingAlly then
        for i, ally in ipairs(self.player.inventory) do
            local indicator = (self.choosingAlly and i == self.targetIndex) and ">" or " "
            love.graphics.print(indicator .. ally.name .. " (Coût en mana: " .. ally.manaCost .. ")", 300, 50 + i * 20)
        end
    end

    -- Affichage du message d'action selon l'état du jeu
    if self.gameState == "playerTurn" and not self.choosingTarget and not self.choosingAlly then
        love.graphics.print("Votre tour: 'a' pour attaquer, 's' pour invoquer", 10, 150)
    elseif self.gameState == "enemyTurn" then
        love.graphics.print("Tour des ennemis...", 10, 150)
    end
end

return CombatScene
