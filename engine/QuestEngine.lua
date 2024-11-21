QuestEngine = {}
QuestEngine.__index = QuestEngine

function QuestEngine:new()
    local instance = {
        quests = {} -- Stocke toutes les quêtes par ID
    }
    setmetatable(instance, QuestEngine)
    return instance
end

-- Ajoute une quête au moteur
function QuestEngine:addQuest(quest)
    table.insert(self.quests, quest)
end

-- Charge les quêtes depuis un fichier JSON
function QuestEngine:loadFromJson(jsonString)
    local questsData = json.decode(jsonString)

    for _, questData in ipairs(questsData) do
        local rewardFunction = function()
            print(questData.rewardMessage) -- Exemple simple d'une récompense
        end

        local quest = Quest:new(questData.id, questData.name, questData.description, questData.prerequisites, questData.rewardText,
            rewardFunction)
        self:addQuest(quest)
    end
end

-- Vérifie si toutes les quêtes prérequises sont complétées
function QuestEngine:canStartQuest(questId)
    local quest = self.quests[questId]
    if not quest then
        return false, "La quête n'existe pas."
    end

    for _, prereqId in ipairs(quest.prerequisites) do
        local prereqQuest = self.quests[prereqId]
        if not prereqQuest or not prereqQuest.isCompleted then
            return false, "La quête " .. prereqQuest.name .. " doit être complétée avant."
        end
    end

    return true, "La quête peut être commencée."
end

return QuestEngine
