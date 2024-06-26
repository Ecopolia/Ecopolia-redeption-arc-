-- player.lua

local Player = {}

function Player.new(name, initialGold, initialMaterials, initialFood)
  local player = {
    name = name,
    currencies = {
      gold = initialGold or 0,
      materials = initialMaterials or 0,
      food = initialFood or 0
    },
    cells = {},
    buildings = {}
  }

  setmetatable(player, { __index = Player })

  return player
end

function Player:addCurrency(currency, amount)
  self.currencies[currency] = self.currencies[currency] + amount
end

function Player:subtractCurrency(currency, amount)
  if self.currencies[currency] >= amount then
    self.currencies[currency] = self.currencies[currency] - amount
    return true
  else
    return false
  end
end

function Player:getCurrency(currency)
  return self.currencies[currency]
end


return Player
