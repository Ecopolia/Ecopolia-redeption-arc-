PlayerCombat = {}
PlayerCombat.__index = PlayerCombat

-- Fonction de création d'un joueur pour le combat
function PlayerCombat:new(playerBase)
    local instance = {
        name = playerBase.name or "Joueur",
        hp = playerBase.hp or 100,
        attack = playerBase.attack or 15,
        defense = playerBase.defense or 5,
        speed = playerBase.speed or 20,
        mana = playerBase.mana or 50,
        inventory = playerBase.ecodex or {}, -- Récupère l'inventaire du joueur de base
        spriteSheet = playerBase.spriteSheet,
        animations = playerBase.animations,
        allies = {}, -- Liste des alliés invoqués (vide au début du combat)
        currentAnimation = nil,
        direction = "down"
    }

    setmetatable(instance, PlayerCombat)
    return instance
end

-- Fonction pour choisir un allié à invoquer depuis l'inventaire
function PlayerCombat:chooseSummon()
    -- Vérifier si l'inventaire contient des alliés invoquables
    if #self.inventory == 0 then
        print("Pas d'alliés disponibles dans l'inventaire.")
        return nil
    end

    -- Afficher les options d'invocation
    print("Choisissez un allié à invoquer :")
    for index, ally in ipairs(self.inventory) do
        print(index .. ". " .. ally.name .. " (Coût en mana : " .. ally.manaCost .. ")")
    end

    -- Sélection de l'utilisateur (remplacer par un choix utilisateur dans une vraie interface)
    local choice = tonumber(io.read()) -- Simule la sélection via la console

    -- Vérifier si le choix est valide
    if choice and self.inventory[choice] then
        local selectedAlly = self.inventory[choice]

        -- Vérifier si le joueur a assez de mana
        if self.mana >= selectedAlly.manaCost then
            print("Vous avez choisi d'invoquer " .. selectedAlly.name)
            return selectedAlly
        else
            print("Pas assez de mana pour invoquer " .. selectedAlly.name)
            return nil
        end
    else
        print("Choix invalide.")
        return nil
    end
end

-- Fonction pour invoquer un allié pendant le combat
function PlayerCombat:summonAlly(ally)
    if self.mana >= ally.manaCost then
        self.mana = self.mana - ally.manaCost
        table.insert(self.allies, ally)
        print(self.name .. " invoque " .. ally.name)
    else
        print("Pas assez de mana pour invoquer " .. ally.name)
    end
end

-- Fonction pour attaquer un ennemi
function PlayerCombat:attackTarget(target)
    if target.hp > 0 then
        local damage = math.max(0, self.attack - target.defense)
        target.hp = math.max(0, target.hp - damage)
        print(self.name .. " attaque " .. target.name .. " pour " .. damage .. " dégâts.")
        if target.hp <= 0 then
            print(target.name .. " est mort.")
        end
    else
        print(target.name .. " est déjà mort.")
    end
end

return PlayerCombat
