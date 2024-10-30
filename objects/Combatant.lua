Combatant = {}
Combatant.__index = Combatant

function Combatant:new(id, type, name, hp, attack, defense, speed, manaCost, classType, spriteSheet, animations)
    local instance = {
        id = id or uuid(),
        type = type or "Ally",  
        name = name or (type == "Enemy" and "Ennemi" or "Allié"),
        hp = hp or (type == "Enemy" and 80 or 50),
        maxHp = hp,
        attack = attack or (type == "Enemy" and 12 or 10),
        defense = defense or (type == "Enemy" and 4 or 3),
        speed = speed or (type == "Enemy" and 7 or 8),
        manaCost = manaCost or (type == "Ally" and 10 or nil),
        classType = classType or "warrior",
        spriteSheet = spriteSheet,
        attackSheet = love.graphics.newImage('assets/spritesheets/01.png'),
        attackGrid = nil,
        grid = nil,
        animations = {},
        currentAnimation = nil,
        healAnimationPlaying = false,
        protectAnimationPlaying = false,
        direction = "down",
        x = 0,
        y = 0
    }

    if instance.spriteSheet ~= nil then
        instance.spriteSheet = love.graphics.newImage(instance.spriteSheet)
        instance.grid = anim8.newGrid(31, 31, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight())
        instance.animations.base = anim8.newAnimation(instance.grid(1, '1-8'), 0.2)
    end
    instance.attackGrid = anim8.newGrid(64, 64, instance.attackSheet:getWidth(), instance.attackSheet:getHeight())
    
    if instance.classType == 'healer' then
        instance.animations.heal = anim8.newAnimation(instance.attackGrid('1-8', 2), 0.1, 'pauseAtEnd')
    elseif instance.classType == 'protector' then
        instance.animations.protect = anim8.newAnimation(instance.attackGrid('1-8', 7), 0.1, 'pauseAtEnd')
    end
    
    instance.currentAnimation = instance.animations.base
    setmetatable(instance, Combatant)
    return instance
end

function Combatant:chooseAction(allies, enemies, player)
    local bad = self.type == "Ally" and enemies or allies
    local good = self.type == "Ally" and allies or enemies 
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

function Combatant:attackTarget(target)
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

function Combatant:healTarget(target)
    if target.hp > 0 then
        local healing = self.attack
        target.hp = math.min(target.hp + healing, target.maxHp)
        print(self.name .. " soigne " .. target.name .. " pour " .. healing .. " HP.")
        
        -- Set heal animation to play once
        self.healAnimationPlaying = true
        self.animations.heal:gotoFrame(1)  -- Start from the beginning
        self.animations.heal:resume()
    else
        print(target.name .. " est mort")
    end
end

function Combatant:defendTarget(target)
    print(self.name .. " défend " .. target.name)
    self.protectAnimationPlaying = true
    self.animations.protect:gotoFrame(1)  -- Start from the beginning
    self.animations.protect:resume()
end

function Combatant:update(dt)
    -- Update base animation continuously
    self.animations.base:update(dt)
    
    -- Update heal animation if it's playing
    if self.healAnimationPlaying then
        self.animations.heal:update(dt)
        
        -- Stop playing heal animation when it finishes
        if self.animations.heal.status == "paused" then
            self.healAnimationPlaying = false
        end
    end
    if self.protectAnimationPlaying then
        self.animations.protect:update(dt)
        
        -- Stop playing heal animation when it finishes
        if self.animations.protect.status == "paused" then
            self.protectAnimationPlaying = false
        end
    end
end

function Combatant:draw()
    -- Draw base animation
    if self.animations.base then
        self.animations.base:draw(self.spriteSheet, self.x, self.y, 0, 3, 3)
    end

    -- Draw heal animation on top if active
    if self.healAnimationPlaying and self.animations.heal then
        self.animations.heal:draw(self.attackSheet, self.x - 48, self.y - 50, 0, 3, 3)
    end

    if self.protectAnimationPlaying and self.animations.protect then
        self.animations.protect:draw(self.attackSheet, self.x - 48, self.y - 50, 0, 3, 3)
    end
end

return Combatant
