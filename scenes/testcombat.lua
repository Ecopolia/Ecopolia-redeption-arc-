local testcombat = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Blue background
        love.graphics.clear(hex('5fcde4'))
        combatScene:draw()
    end)

    -- Add the CRT shader stage
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end

function testcombat:load(args)
    -- Exemple de création du joueur et des ennemis pour le combat
    local player = PlayerCombat:new({ name = "Joueur", hp = 100, attack = 20, defense = 10, speed = 15, mana = 50 })
    local enemy1 = Enemy:new("Gobelin", 80, 10, 5, 8, "warrior")
    local enemy2 = Enemy:new("Troll", 120, 15, 8, 6, "warrior")

    -- Création de la scène de combat
    combatScene = CombatScene:new(player, {enemy1, enemy2})
    combatScene:load()

    self.pipeline = setupPipeline()
end

function testcombat:draw()
    if not self.pipeline then
        print("Waiting for pipeline to draw")
        return
    end

    self.pipeline:run()
end

function testcombat:update(dt)
    combatScene:update(dt)
end

function testcombat:keypressed(key)
    combatScene:keypressed(key)
end

return testcombat
