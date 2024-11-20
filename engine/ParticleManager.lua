local ParticleManager = {}
ParticleManager.__index = ParticleManager

function ParticleManager.new()
    local self = setmetatable({}, ParticleManager)

    self.particles = {
        x = 0,
        y = 0
    } -- Main particle container

    return self
end

function ParticleManager:addParticleSystem(imagePath, position, config)
    local image = love.graphics.newImage(imagePath)
    image:setFilter("linear", "linear")

    local ps = love.graphics.newParticleSystem(image, config.bufferSize or 47)
    ps:setColors(unpack(config.colors))
    ps:setDirection(config.direction or 0)
    ps:setEmissionArea(config.emissionArea or "none", 0, 0, 0, false)
    ps:setEmissionRate(config.emissionRate or 20)
    ps:setEmitterLifetime(config.emitterLifetime or -1)
    ps:setInsertMode(config.insertMode or "top")
    ps:setParticleLifetime(config.particleLifetime[1], config.particleLifetime[2])
    ps:setSizes(config.size or 0.4)
    ps:setSpeed(config.speed[1], config.speed[2])
    ps:setSpread(config.spread or 0)

    -- Add the particle system to the list
    table.insert(self.particles, {
        system = ps,
        kickStartSteps = config.kickStartSteps or 0,
        kickStartDt = config.kickStartDt or 0,
        emitAtStart = config.emitAtStart or 0,
        blendMode = config.blendMode or "alpha",
        shader = config.shader or nil,
        texturePath = config.texturePath or "",
        texturePreset = config.texturePreset or "",
        shaderPath = config.shaderPath or "",
        shaderFilename = config.shaderFilename or "",
        position = position
    })
end

function ParticleManager:update(dt)
    for _, particle in ipairs(self.particles) do
        if particle.system then
            particle.system:update(dt)
            -- Emit particles at the start if configured
            if particle.emitAtStart > 0 then
                particle.system:emit(particle.emitAtStart)
                particle.emitAtStart = 0 -- Emit only once
            end
        end
    end
end

function ParticleManager:draw()
    for _, particle in ipairs(self.particles) do
        love.graphics.setBlendMode(particle.blendMode)
        love.graphics.draw(particle.system, particle.position.x, particle.position.y)
    end
    love.graphics.setBlendMode("alpha") -- Reset blend mode
end

return ParticleManager
