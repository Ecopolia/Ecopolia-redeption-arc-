-- Moteur de combat
require "objects/combat_object"
CombatEngine = {}
CombatEngine.__index = CombatEngine

function CombatEngine:new(players, enemies)
    local obj = {
        players = players,
        enemies = enemies,
        turn_order = {},
        turn_index = 1,
        is_over = false
    }
    setmetatable(obj, CombatEngine)

    -- Déterminer l'ordre des tours en fonction de la vitesse
    obj:calculateTurnOrder()  -- Appel de la méthode ici

    return obj
end

-- Calculer l'ordre des tours en fonction de la vitesse
function CombatEngine:calculateTurnOrder()
    local all_combatants = {}
    
    for _, player in ipairs(self.players) do
        table.insert(all_combatants, player)
    end
    for _, enemy in ipairs(self.enemies) do
        table.insert(all_combatants, enemy)
    end
    
    -- Trier tous les combattants par vitesse décroissante
    table.sort(all_combatants, function(a, b) return a.speed > b.speed end)
    self.turn_order = all_combatants
end

-- Effectuer un tour de combat
function CombatEngine:takeTurn()
    -- Tour de chaque combattant dans l'ordre
    for i = 1, #self.turn_order do
        local combatant = self.turn_order[i]
        
        if combatant:isAlive() then
            -- Régénération de mana de 15% chaque tour
            combatant:regenerateMana(15)

            -- Afficher les options d'action
            print(combatant.name .. ", c'est à ton tour!")
            print("1. Attaquer")
            print("2. Invoquer un allié")

            -- Supposons que tu aies une fonction pour obtenir l'input du joueur
            local choice = getPlayerInput()
            while ( choice ~= 1 and choice ~= 2 ) do
                choice = getPlayerInput()
            end
            
            if choice == 1 then
                -- Logique d'attaque
                local target = self:chooseRandomTarget(self.enemies)
                if target then
                    combatant:attackTarget(target)
                end
            elseif choice == 2 then
                combatant:invokeAlly() -- Invoquer un allié
            else
                print("Choix invalide.")
            end
        end
    end
    
    -- Vérifier si le combat est terminé
    self:checkBattleStatus() -- Vérifier si le combat est terminé)
end    

function CombatEngine:main ()
    -- Boucle principale du jeu
    while not self.is_over do
        self:takeTurn()
    end
end

-- Choisir une cible aléatoire parmi les vivants
function CombatEngine:chooseRandomTarget(combatants)
    local living_combatants = {}
    for _, combatant in ipairs(combatants) do
        if combatant:isAlive() then
            table.insert(living_combatants, combatant)
        end
    end
    if #living_combatants > 0 then
        local index = math.random(1, #living_combatants)
        return living_combatants[index]
    else
        return nil
    end
end

-- Vérifier si le combat est terminé
function CombatEngine:checkBattleStatus()
    -- Vérifier si tous les ennemis sont morts
    local enemies_alive = false
    for _, enemy in ipairs(self.enemies) do
        if enemy:isAlive() then
            enemies_alive = true
            break
        end
    end

    -- Vérifier si tous les joueurs sont morts
    local players_alive = false
    for _, player in ipairs(self.players) do
        if player:isAlive() then
            players_alive = true
            break
        end
    end

    if not enemies_alive then
        print("Tous les ennemis sont vaincus. Les joueurs gagnent !")
        self.is_over = true
    elseif not players_alive then
        print("Tous les joueurs sont vaincus. Les ennemis gagnent !")
        self.is_over = true
    end
end

-- Vérifier si le combattant est un joueur
function CombatEngine:isPlayer(combatant)
    for _, player in ipairs(self.players) do
        if player == combatant then
            return true
        end
    end
    return false
end

function getPlayerInput() 
    if love.keyboard.isDown('i') then
        return 2
    end
    if love.keyboard.isDown('o') then
        return 1
    end
end


return CombatEngine
