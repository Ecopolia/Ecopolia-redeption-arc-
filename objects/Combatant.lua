Combatant = {}
Combatant.__index = Combatant

-- Fonction de création d'un nouveau combattant (allié ou ennemi)
function Combatant:new(type, name, hp, attack, defense, speed, manaCost, classType, spriteSheet, animations)
    local instance = {
        id = id or uuid(),
        type = type or "Ally",  -- "Ally" ou "Enemy"
        name = name or (type == "Enemy" and "Ennemi" or "Allié"),
        hp = hp or (type == "Enemy" and 80 or 50),
        maxHp = hp,
        attack = attack or (type == "Enemy" and 12 or 10),
        defense = defense or (type == "Enemy" and 4 or 3),
        speed = speed or (type == "Enemy" and 7 or 8),
        manaCost = manaCost or (type == "Ally" and 10 or nil),  -- Coût en mana seulement pour les alliés
        classType = classType or "warrior",  -- Type de classe : "warrior", "healer", "protector"
        spriteSheet = spriteSheet,
        animations = animations,
        currentAnimation = nil,
        direction = "down",  -- Direction par défaut
    }

    setmetatable(instance, Combatant)
    return instance
end

-- Fonction pour déterminer l'action du combattant en fonction de sa classe
function Combatant:chooseAction(allies, enemies, player)
    local bad = self.type == "Ally" and enemies or allies  -- Cible ennemie si allié, et alliée si ennemi
    local good = self.type == "Ally" and allies or enemies -- Cible allies si allié, et enemies si ennemi
    if self.classType == "warrior" then
        if #bad > 0 then
            self:attackTarget(bad[math.random(#bad)])
        else
            self:attackTarget(player)
        end
    elseif self.classType == "healer" then
        self:healTarget(good[math.random(#good)])
    elseif self.classType == "protector" then
        self:defendTarget(good[math.random(#good)])
    end
end

-- Fonction pour attaquer une cible
function Combatant:attackTarget(target)
    if target.hp > 0 then
        local damage = math.max(0, self.attack - target.defense)
        target.hp = target.hp - damage
        print(self.name .. " attaque " .. target.name .. " pour " .. damage .. " dégâts.")
        if target.hp <= 0 then
            print(target.name .. " est mort.")
        end
    else
        print(target.name .. " est déjà mort.")
    end
end

-- Fonction pour soigner une cible
function Combatant:healTarget(target)
    if target.hp > 0 then
        local healing = self.attack  -- Utilisation de l'attaque comme valeur de guérison
        target.hp = math.min(target.hp + healing, 100) -- Limite la guérison à 100 hp
        print(self.name .. " soigne " .. target.name .. " pour " .. healing .. " HP.")
    else
        print(target.name .. " est mort")
    end
end

-- Fonction pour défendre une cible
function Combatant:defendTarget(target)
    print(self.name .. " défend " .. target.name)
    -- Logique pour rediriger les dégâts ici
end

-- Fonction de mise à jour du combattant en combat
function Combatant:update(dt)
    if self.animations[self.direction] then
        self.animations[self.direction]:update(dt)
    end
end

-- Fonction de dessin du combattant
function Combatant:draw()
    if self.animations and self.direction then
        local anim = self.animations[self.direction]
        if anim then
            anim:draw(self.spriteSheet, self.x, self.y)
        end
    end
end

return Combatant
