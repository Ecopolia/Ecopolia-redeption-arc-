-- player.lua

local Player = {}

function Player.new(name, initialGold, initialMaterials, initialFood)
  local player = {
    name = name,
    skills = {},
    health = 100,
  }

  setmetatable(player, { __index = Player })

  return player
end


return Player
