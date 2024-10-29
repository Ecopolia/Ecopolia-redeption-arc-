local testcombat = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        love.graphics.clear(hex('5fcde4'))
        combatScene:draw()
    end)

    return pipeline
end

function testcombat:load(args)
    local player = PlayerCombat:new({ name = "Joueur", hp = 100, attack = 20, defense = 10, speed = 15, mana = 50 })
    local enemy1 = Combatant:new("Enemy", "Gobelin", 80, 10, 5, 20, nil, "warrior", nil, nil)
    local enemy2 = Combatant:new("Enemy", "Troll", 120, 15, 8, 6, nil, "healer", nil, nil)

    combatScene = CombatScene:new(player, { enemy1, enemy2 })
    combatScene:load()

    self.pipeline = setupPipeline()
    
    -- Create a window for each enemy
    self.enemyWindows = {}
    for i, enemy in ipairs(combatScene.enemies) do
        table.insert(self.enemyWindows, {
            window = Window.new({
                x = 350,
                y = 50 + (i - 1) * 100, -- Stack windows vertically
                w = 200,
                h = 80,
                title = enemy.name,
                color = { 0.8, 0.8, 0.8, 0.9 },
                borderColor = { 0, 0, 0 },
            }),
            enemy = enemy -- Store reference to the enemy
        })
    end
end

function testcombat:draw()
    if not self.pipeline then
        print("Waiting for pipeline to draw")
        return
    end

    self.pipeline:run()

    -- Draw each enemy's window and health bar
    for _, enemyData in ipairs(self.enemyWindows) do
        local window = enemyData.window
        local enemy = enemyData.enemy
        window:draw()
        -- Draw the health bar for the corresponding enemy
        self:drawHealthBar(window, enemy)
    end
end

function testcombat:drawHealthBar(window, enemy)
    local healthPercentage = enemy.hp / enemy.maxHp
    local barWidth = window.width - 10
    local barHeight = 10
    local x = window.x + 5
    local y = window.y + 40 -- Positioning below the title

    -- Draw health bar background
    love.graphics.setColor(0.2, 0.2, 0.2) -- Dark gray for background
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)

    -- Draw health bar foreground
    love.graphics.setColor(0.0, 1.0, 0.0) -- Green for health
    love.graphics.rectangle("fill", x, y, barWidth * healthPercentage, barHeight)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function testcombat:update(dt)
    combatScene:update(dt)

    -- Update each enemy's window as necessary
    for _, enemyData in ipairs(self.enemyWindows) do
        enemyData.window:update(dt)
    end
end

function testcombat:keypressed(key)
    combatScene:keypressed(key)
end

return testcombat
