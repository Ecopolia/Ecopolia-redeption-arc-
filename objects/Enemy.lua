Enemy = {}
Enemy.__index = Enemy

-- Fonction de création d'un nouvel ennemi
function Enemy:new(name, hp, attack, defense, speed, classType, spriteSheet, animations)
    local instance = {
        name = name or "Ennemi",
        hp = hp or 80,
        attack = attack or 12,
        defense = defense or 4,
        speed = speed or 7,  -- Vitesse de l'ennemi
        classType = classType or "warrior",  -- Type de classe : "warrior", "healer", "protector"
        spriteSheet = spriteSheet,
        animations = animations,
        currentAnimation = nil,
        direction = "down",  -- Direction par défaut
    }

    setmetatable(instance, Enemy)
    return instance
end

-- Fonction pour déterminer l'action de l'ennemi en fonction de sa classe
function Enemy:chooseAction(allies, enemies)
    if self.classType == "warrior" then
        if #enemies > 0 then
            self:attackTarget(enemies[math.random(#enemies)])
        else
            self:attackTarget(player)
        end
    elseif self.classType == "healer" then
        self:healTarget(allies[math.random(#allies)])
    elseif self.classType == "protector" then
        self:defendTarget(allies[math.random(#allies)])
    end
end

-- Fonction pour attaquer un ennemi
function Enemy:attackTarget(target)
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
function Enemy:healTarget(target)
    if target.hp > 0 then
        local healing = self.attack  -- Utilisation de l'attaque comme valeur de guérison
        target.hp = math.min(target.hp + healing, 100) -- Limite la guérison à 100 hp
        print(self.name .. " soigne " .. target.name .. " pour " .. healing .. " HP.")
    else
        print(target.name .. " est déjà au maximum de ses points de vie.")
    end
end

-- Fonction pour défendre un allié
function Enemy:defendTarget(target)
    print(self.name .. " défend " .. target.name)
    -- Logique pour rediriger les dégâts ici
end

-- Fonction de mise à jour de l'ennemi en combat
function Enemy:update(dt)
    if self.animations[self.direction] then
        self.animations[self.direction]:update(dt)
    end
end

-- Fonction de dessin de l'ennemi
function Enemy:draw()
    if self.animations and self.direction then
        local anim = self.animations[self.direction]
        if anim then
            anim:draw(self.spriteSheet, self.x, self.y)
        end
    end
end

return Enemy