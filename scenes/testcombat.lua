local testcombat = {}

local function setupPipeline()
    local pipeline = Pipeline.new(G.WINDOW.WIDTH, G.WINDOW.HEIGHT)

    pipeline:addStage(nil, function()
        love.graphics.clear(hex('5fcde4'))
        combatScene:draw()
        particleManager:draw()
    end)

    return pipeline
end

local function createEnemyWindow(enemy, centerX, centerY)
    local windowWidth, windowHeight = 200, 190
    local windowX = centerX - windowWidth / 2
    local windowY = centerY - windowHeight / 2
    
    local window = Window.new({
        x = windowX,
        y = windowY,
        w = windowWidth,
        h = windowHeight,
        title = enemy.name,
        color = { 0.8, 0.8, 0.8, 0.9 },
        borderColor = { 0, 0, 0 },
    })
    
    enemy.x, enemy.y = centerX - (32 * 3) / 2, centerY - (32 * 3) / 2 + 15

    
    return {
        window = window,
        enemy = enemy -- Store reference to the enemy
    }
end

function testcombat:load(args)
    ManualtransitionIn()
    local particleConfig = {
        colors = {0.426, 1, 0.610, 0, 0.117, 1, 0.066, 1, 0, 1, 0.086, 0.5, 1, 1, 1, 0},
        emissionRate = 20,
        emitterLifetime = -1,
        particleLifetime = {1.8, 2.2},
        speed = {169, 100},
        spread = 0.314,
        bufferSize = 47,
        kickStartSteps = 0,
        kickStartDt = 0,
        emitAtStart = 10,
        blendMode = "add",
        texturePreset = "lightBlur",
        texturePath = "assets/imgs/lightBlur.png",
    }

    -- Add a particle system
    -- particleManager:addParticleSystem("assets/imgs/lightBlur.png", {x = 600, y = 300}, particleConfig)
    local player = PlayerCombat:new({ name = "Joueur", hp = 100, attack = 20, defense = 10, speed = 15, mana = 50 })
    local arrayEnemy = {
        findbyid(enemies.combatants, 1),
        findbyid(enemies.combatants, 2),
        findbyid(enemies.combatants, 3)
    }

    combatScene = CombatScene:new(player, arrayEnemy)
    combatScene:load()

    self.pipeline = setupPipeline()

    -- Create a window for each enemy, placing them centered at specified coordinates
    self.enemyWindows = {
        createEnemyWindow(combatScene.enemies[1], 900, 100),
        createEnemyWindow(combatScene.enemies[2], 900, 300),
        createEnemyWindow(combatScene.enemies[3], 900, 500),
    }
end

function testcombat:draw()
    if combatScene then
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
            enemy:draw()
            -- Draw the health bar for the corresponding enemy
            self:drawHealthBar(window, enemy)
        end
    end
end

function testcombat:drawHealthBar(window, enemy)
    local healthPercentage = enemy.hp / enemy.maxHp
    local barWidth = window.width - 10
    local barHeight = 10
    local x = window.x + 5
    local y = window.y + 40

    -- Draw health bar background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)

    -- Draw health bar foreground
    love.graphics.setColor(0.0, 1.0, 0.0)
    love.graphics.rectangle("fill", x, y, barWidth * healthPercentage, barHeight)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function testcombat:update(dt)
    if combatScene then
        combatScene:update(dt)

        -- Update each enemy's window as necessary
        for _, enemyData in ipairs(self.enemyWindows) do
            enemyData.window:update(dt)
        end
    end
end

function testcombat:keypressed(key)
    if combatScene then
        combatScene:keypressed(key)
    end
end

return testcombat
