-- Définir l'objet de combat
CombatObject = {}
CombatObject.__index = CombatObject

function CombatObject:new(name, hp, attack, defense, speed, role)
    local obj = {
        name = name,
        hp = hp,
        max_hp = hp,  -- Si tu as une valeur max pour les points de vie
        max_mana = 100, -- Exemple de valeur de mana max
        mana = 100,     -- Initialiser mana à max_mana
        attack = attack,
        defense = defense,
        speed = speed,
        role = role,
        is_alive = true, -- Initialiser is_alive à true
    }
    setmetatable(obj, self)
    return obj
end

function CombatObject:attackTarget(target)
    if not self:isAlive() then
        return
    end

    local damage = self.attack - target.defense
    if damage < 0 then damage = 0 end

    target.hp = target.hp - damage
    print(self.name .. " attaque " .. target.name .. " et inflige " .. damage .. " dégâts.")

    if target.hp <= 0 then
        target.hp = 0
        target.is_alive = false
        print(target.name .. " est tombé au combat.")
    else
        print(target.name .. " a encore " .. target.hp .. " HP.")
    end
end

function CombatObject:heal(amount)
    if not self:isAlive() then return end

    self.hp = self.hp + amount
    if self.hp > self.max_hp then
        self.hp = self.max_hp
    end
    print(self.name .. " se soigne de " .. amount .. " HP. Total: " .. self.hp .. "/" .. self.max_hp)
end

function CombatObject:regenerateMana(percentage)
    -- Régénère un pourcentage de la mana maximale
    local mana_to_regen = self.max_mana * (percentage / 100)
    self.mana = math.min(self.max_mana, self.mana + mana_to_regen)
    print(self.name .. " régénère " .. mana_to_regen .. " mana. Mana actuelle : " .. self.mana)
end

function CombatObject:invokeAlly()
    local invocation_cost = self.max_mana * 0.45 -- Coût d'invocation = 45% de la mana max

    if self.mana >= invocation_cost then
        -- Si suffisamment de mana, invoquer un allié
        local ally = CombatObject:new("Thomas", 60, 15, 4, 7, "allié")
        ally.turn_counter = 0 -- Compteur pour gérer les tours
        ally.is_invoked = true -- Indique que c'est un allié invoqué
        table.insert(combat_engine.players, ally) -- Ajouter l'allié à la liste des joueurs
        self.mana = self.mana - invocation_cost -- Réduire la mana
        print(self.name .. " invoque un allié! Mana restante : " .. self.mana)
    else
        print(self.name .. " n'a pas assez de mana pour invoquer!")
    end
end

function CombatObject:invokeAction(combat_engine)
    if self:isAlive() then
        -- Logique pour décider entre attaquer ou soigner
        local target = combat_engine:chooseRandomTarget(combat_engine.enemies)
        if target and math.random() < 0.5 then -- 50% de chance d'attaquer
            self:attackTarget(target)
        else
            local allyToHeal = combat_engine:chooseRandomTarget(combat_engine.players)
            if allyToHeal and allyToHeal.hp < allyToHeal.max_hp then
                allyToHeal:heal(10) -- Soigner 10 HP
            end
        end
    end
end

function CombatObject:isAlive()
    return self.is_alive
end
