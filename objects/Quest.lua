Quest = {}
Quest.__index = Quest

function Quest:new(id, name, description, prerequisites, rewardFunction)
    local instance = {
        id = id or uuid(),
        name = name,
        description = description,
        prerequisites = prerequisites or {},
        isCompleted = false,
        rewardFunction = rewardFunction or function()
        end -- Fonction de récompense par défaut
    }
    setmetatable(instance, Quest)
    return instance
end

function Quest:complete()
    self.isCompleted = true
    self:reward() -- Exécute la fonction de récompense
end

function Quest:reward()
    self.rewardFunction() -- Appelle la fonction de récompense
end

return Quest
