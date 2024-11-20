local test_combat = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        -- Blue background
        love.graphics.clear(hex('5fcde4'))
        uiManager:draw("test_combat")
    end)

    -- Add the CRT shader stage
    -- pipeline:addStage(G.SHADERS['CRT'], function() end)

    return pipeline
end

function test_combat:load(args)
    player1 = CombatObject:new("Héros Invocateur", 100, 20, 5, 10, "invocateur")
    enemy1 = CombatObject:new("Gobelin", 50, 15, 3, 8)
    enemy2 = CombatObject:new("Orc", 80, 18, 6, 9)
    
    -- Créer le moteur de combat avec les joueurs et les ennemis
    combat_engine = CombatEngine:new({player1, player2}, {enemy1, enemy2})
    combat_engine:main()
    -- Setup the rendering pipeline
    self.pipeline = setupPipeline()
    -- Variable pour gérer le délai entre les tours
    self.turn_delay = 5 -- Délai de 5 seconde entre chaque tour
end

function test_combat:draw()
    -- Afficher les informations des joueurs
    for i, player in ipairs(combat_engine.players) do
        love.graphics.print(player.name .. ": HP " .. player.hp .. "/" .. player.max_hp, 10, i * 20)
    end

    -- Afficher les informations des ennemis
    for i, enemy in ipairs(combat_engine.enemies) do
        love.graphics.print(enemy.name .. ": HP " .. enemy.hp .. "/" .. enemy.max_hp, 200, i * 20)
    end

    -- Si le combat est terminé
    if combat_engine.is_over then
        love.graphics.print("Le combat est terminé!", G.WINDOW.WIDTH / 2 - 50, G.WINDOW.HEIGHT / 2)
    end
end

function test_combat:update(dt)
    -- Mettre à jour le pipeline
    uiManager:update("test_combat", dt)


end



return test_combat
