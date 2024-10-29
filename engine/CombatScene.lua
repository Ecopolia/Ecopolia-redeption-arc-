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
        gameState = "start",  -- État du jeu (playerTurn, enemyTurn, etc.)
        actionSelected = nil,  -- Action sélectionnée par le joueur (attack, summon)
        targetIndex = 1,  -- Indice de la cible actuelle pour l'attaque ou l'invocation
        choosingTarget = false,  -- Si le joueur choisit une cible
        choosingAlly = false,  -- Si le joueur choisit un allié à invoquer
        alliesAlive = {},  -- Liste des alliés vivants
        enemiesAlive = {},  -- Liste des ennemis vivants
        victory = false
    }

    setmetatable(instance, CombatScene)
    return instance
end

-- Met à jour les listes des alliés et ennemis vivants
function CombatScene:updateAlives()
    -- Réinitialiser les listes des vivants
    self.alliesAlive = {}
    self.enemiesAlive = {}

    -- Ajouter les alliés invoqués et en vie
    for _, ally in ipairs(self.allies) do
        if ally.hp > 0 then
            table.insert(self.alliesAlive, ally)
        end
    end

    -- Ajouter les ennemis vivants
    for _, enemy in ipairs(self.enemies) do
        if enemy.hp > 0 then
            table.insert(self.enemiesAlive, enemy)
        end
    end

    if #self.enemiesAlive == 0 or self.player.hp <= 0 then
        self.gameState = "endCombat"
    end

    if #self.enemiesAlive == 0 and self.player.hp > 0 then
        self.victory = true
    end
end

-- Calcule l'ordre des tours en utilisant alliesAlive et enemiesAlive
function CombatScene:calculateTurnOrder()
    self:updateAlives()  -- Met à jour les listes des vivants

    -- Fusionner les alliés et ennemis vivants pour l'ordre de tour
    local allCombatants = {self.player}
    for _, ally in ipairs(self.alliesAlive) do
        table.insert(allCombatants, ally)
    end
    for _, enemy in ipairs(self.enemiesAlive) do
        table.insert(allCombatants, enemy)
    end

    -- Trier par vitesse (du plus rapide au plus lent)
    table.sort(allCombatants, function(a, b) return a.speed > b.speed end)
    self.turnOrders = allCombatants
    self.currentTurnIndex = 1
end

-- Gère les entrées du joueur
function CombatScene:keypressed(key)
    if self.gameState == "playerTurn" and not self.choosingTarget and not self.choosingAlly then
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
        self:updateAlives()
        self.currentTurnIndex = self.currentTurnIndex + 1
        self.gameState = "processturn"
    end
end

-- Gère le processus du tour
function CombatScene:processTurn()
    local currentCombatant = nil
    
    if #self.turnOrders < self.currentTurnIndex then
        self.currentTurnIndex = self.currentTurnIndex + 1
    else 
        currentCombatant = self.turnOrders[self.currentTurnIndex]
    end

    if currentCombatant ~= nil then 
        if currentCombatant.hp <= 0 then
            self.currentTurnIndex = self.currentTurnIndex + 1
            self:updateAlives()
            return
        end

        if currentCombatant == self.player then
            self.gameState = "playerTurn"
        else
            currentCombatant:chooseAction(self.alliesAlive, self.enemiesAlive, self.player)
            self.currentTurnIndex = self.currentTurnIndex + 1
        end
    end

    if self.currentTurnIndex > #self.turnOrders then
        self.currentTurnIndex = 1
        self:calculateTurnOrder()
    end
    self:updateAlives() 
end

-- Choisir une cible pour attaquer
function CombatScene:chooseTarget()
    self.gameState = "chooseTarget"
    if #self.enemies > 0 then
        self.targetIndex = 1  -- Commence à la première cible (premier ennemi)
        self.choosingTarget = true
    end
end

-- Choisir un allié pour invoquer
function CombatScene:chooseAlly()
    self.gameState = "chooseAlly"
    if #self.player.inventory > 0 then
        self.targetIndex = 1  -- Commence avec le premier allié de l'inventaire
        self.choosingAlly = true
    else
        print("Pas d'alliés disponibles dans l'inventaire.")
        self.choosingAlly = false
        self.actionSelected = nil
        self.gameState = "playerTurn"
    end
end

-- Change la sélection de cible
function CombatScene:changeTargetSelection(key)
    if key == "up" then
        self.targetIndex = self.targetIndex - 1
        if self.targetIndex < 1 then self.targetIndex = #self.enemies end
    elseif key == "down" then
        self.targetIndex = self.targetIndex + 1
        if self.targetIndex > #self.enemies then self.targetIndex = 1 end
    end
end

-- Change la sélection d'allié à invoquer
function CombatScene:changeAllySelection(key)
    if key == "up" then
        self.targetIndex = self.targetIndex - 1
        if self.targetIndex < 1 then self.targetIndex = #self.player.inventory end
    elseif key == "down" then
        self.targetIndex = self.targetIndex + 1
        if self.targetIndex > #self.player.inventory then self.targetIndex = 1 end
    end
end

function CombatScene:selectTarget(id)
    self.targetIndex = id
    self.choosingAlly = false
    self.choosingTarget = true
end

function CombatScene:selectAlly(id)
    self.targetIndex = id
    self.choosingTarget = false
    self.choosingAlly = true
end

-- Confirme l'action du joueur
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

-- Gère les actions du joueur
function CombatScene:processPlayerAction(action, target)
    if action == "attack" then
        self.player:attackTarget(target)
    end
end

function CombatScene:load()
    print("Chargement de la scène de combat...")
end

-- Met à jour la scène
function CombatScene:update(dt)
    if self.gameState == "start" then
        self:calculateTurnOrder()
        self.gameState = "processturn"
    end

    if self.gameState == "processturn" then
        self:processTurn()
    end

    if self.gameState == "endCombat" then
        -- Logique de fin de combat (victoire ou défaite)
    end

    for key, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end
end

-- Dessine la scène
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

    if self.gameState == "endCombat" then
        love.graphics.print("Fin du combat", 10, 150)
        if self.victory then
            love.graphics.print("Victoire", 10, 170)
        else
            love.graphics.print("Défaite", 10, 170)
        end
    end
end

return CombatScene
