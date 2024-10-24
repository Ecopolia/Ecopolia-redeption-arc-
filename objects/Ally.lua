Ally = {}
Ally.__index = Ally

-- Fonction de création d'un nouvel allié
function Ally:new(name, hp, attack, defense, speed, manaCost, spriteSheet, animations)
    local instance = {
        name = name or "Allié",
        hp = hp or 50,
        attack = attack or 10,
        defense = defense or 3,
        speed = speed or 8,  -- Vitesse de l'allié
        manaCost = manaCost or 10,  -- Coût en mana pour invoquer l'allié
        spriteSheet = spriteSheet,
        animations = animations,
        currentAnimation = nil,
        direction = "down",  -- Direction par défaut
    }

    setmetatable(instance, Ally)
    return instance
end

-- Fonction pour attaquer un ennemi
function Ally:attackTarget(target)
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

-- Fonction pour soigner un allié
function Ally:healTarget(target)
    if target.hp > 0 then
        local healing = self.attack  -- Utilisation de l'attaque comme valeur de guérison
        target.hp = math.min(target.hp + healing, 100) -- Limite la guérison à 100 hp
        print(self.name .. " soigne " .. target.name .. " pour " .. healing .. " HP.")
    else
        print(target.name .. " est déjà au maximum de ses points de vie.")
    end
end

-- Fonction pour défendre un allié (prendre les dégâts à sa place)
function Ally:defendTarget(target)
    print(self.name .. " défend " .. target.name)
    -- Logique pour rediriger les dégâts ici
end

-- Fonction de mise à jour de l'allié en combat
function Ally:update(dt)
    if self.animations[self.direction] then
        self.animations[self.direction]:update(dt)
    end
end

-- Fonction de dessin de l'allié
function Ally:draw()
    if self.animations and self.direction then
        local anim = self.animations[self.direction]
        if anim then
            anim:draw(self.spriteSheet, self.x, self.y)
        end
    end
end

return Ally
