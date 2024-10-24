-- Scène de combat
testcombat = {}

-- Fonction pour gérer les actions du joueur
function testcombat:processPlayerAction(action)
    if action == "attack" then
        -- Attaquer le premier ennemi dans la liste
        local target = self.enemies[1]
        self.player:attackTarget(target)
    elseif action == "summon" then
        -- Utiliser la fonction chooseSummon pour invoquer un allié
        local allyToSummon = self.player:chooseSummon()
        if allyToSummon then
            self.player:summonAlly(allyToSummon)
        end
    end

    -- Passer au tour suivant après l'action du joueur
    self.gameState = "enemyTurn"
end

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Affichage des stats du joueur
        love.graphics.print("Joueur: " .. self.player.hp .. " HP | Mana: " .. self.player.mana, 10, 10)

        -- Afficher les ennemis et leurs stats
        for i, enemy in ipairs(self.enemies) do
            love.graphics.print(enemy.name .. ": " .. enemy.hp .. " HP", 10, 50 + i * 20)
        end

        -- Affichage du message d'action selon l'état du jeu
        if self.gameState == "playerTurn" then
            love.graphics.print("Votre tour: 'a' pour attaquer, 's' pour invoquer", 10, 150)
        elseif self.gameState == "enemyTurn" then
            love.graphics.print("Tour des ennemis...", 10, 150)
        end

        -- Afficher les alliés invoqués
        for i, ally in ipairs(self.player.allies) do
            love.graphics.print("Allié: " .. ally.name .. " (HP: " .. ally.hp .. ")", 200, 50 + i * 20)
        end
    end)

    -- Add the CRT shader stage
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end

function testcombat:load(args)
    ManualtransitionIn()

    player = player,  -- Joueur de la scène de combat
    enemies = enemies,  -- Liste des ennemis
    combatEngine = CombatEngine:new(player, enemies),  -- Moteur de combat
    gameState = "playerTurn",  -- Indicateur de l'état du jeu (playerTurn, enemyTurn, etc.)
    actionSelected = nil  -- Action sélectionnée par le joueur (attack, summon)

    -- Setup the rendering pipeline
    self.pipeline = setupPipeline()
end

function testcombat:draw()
    if not self.pipeline then
        print("Waiting for pipeline to draw")
        return
    end

    self.pipeline:run()
end

-- Fonction pour gérer les entrées du joueur et le processus de combat
function testcombat:update(dt)
    -- Gestion du tour de combat
    if self.gameState == "playerTurn" then
        -- Attendre une action du joueur
        if love.keyboard.isDown("a") then
            self.actionSelected = "attack"
        elseif love.keyboard.isDown("s") then
            self.actionSelected = "summon"
        end

        -- Si une action est sélectionnée
        if self.actionSelected then
            self:processPlayerAction(self.actionSelected)
            self.actionSelected = nil
        end
    elseif self.gameState == "enemyTurn" then
        -- Traiter les actions des ennemis via le moteur de combat
        self.combatEngine:processTurn()
        self.gameState = "playerTurn"
    end
end

return testcombat
