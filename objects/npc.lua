NPC = {}
NPC.__index = NPC

function NPC.new(name, color, speed)
    local self = setmetatable({}, NPC)
    self.name = name or "NPC"
    self.color = color or {1, 0, 0}
    self.speed = speed or 1
    self.progress = 0
    return self
end

function NPC:castSpell()
    print(self.name .. " casts a spell!")
end

return NPC