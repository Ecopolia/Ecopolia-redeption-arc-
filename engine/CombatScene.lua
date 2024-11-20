local CombatScene = {}
CombatScene.__index = CombatScene

-- Creates a new combat scene
function CombatScene:new(player, enemies)
  local instance = {
    player = player, -- Player in the combat scene
    enemies = enemies, -- List of enemies
    allies = {},
    turn_orders = {},
    current_turn_index = 0,
    game_state = "start", -- Game state (playerTurn, enemyTurn, etc.)
    action_selected = nil, -- Action selected by the player (attack, summon)
    target_index = 1, -- Current target index for attack or summon
    choosing_target = false, -- Whether the player is choosing a target
    choosing_ally = false, -- Whether the player is choosing an ally to summon
    allies_alive = {}, -- List of living allies
    enemies_alive = {}, -- List of living enemies
    victory = false
  }

  setmetatable(instance, CombatScene)
  return instance
end

-- Updates the list of living allies and enemies
function CombatScene:updateAlives()
  self.allies_alive = {}
  self.enemies_alive = {}

  -- Add living allies
  for _, ally in ipairs(self.allies) do
    if ally.hp > 0 then
      table.insert(self.allies_alive, ally)
    end
  end

  -- Add living enemies
  for _, enemy in ipairs(self.enemies) do
    if enemy.hp > 0 then
      table.insert(self.enemies_alive, enemy)
    end
  end

  if #self.enemies_alive == 0 or self.player.hp <= 0 then
    self.game_state = "end_combat"
  end

  if #self.enemies_alive == 0 and self.player.hp > 0 then
    self.victory = true
  end
end

-- Calculates turn order using living allies and enemies
function CombatScene:calculateTurnOrder()
  self:updateAlives()

  local all_combatants = {self.player}
  for _, ally in ipairs(self.allies_alive) do
    table.insert(all_combatants, ally)
  end
  for _, enemy in ipairs(self.enemies_alive) do
    table.insert(all_combatants, enemy)
  end

  table.sort(all_combatants, function(a, b)
    return a.speed > b.speed
  end)

  self.turn_orders = all_combatants
  self.current_turn_index = 1
end

-- Handles player input
function CombatScene:keypressed(input_key)
  if self.game_state == "playerTurn" and not self.choosing_target and not self.choosing_ally then
    if input_key == "a" then
      self:chooseTarget()
    elseif input_key == "s" then
      self:chooseAlly()
    end
  elseif self.choosing_target and (input_key == "up" or input_key == "down") then
    self:changeTargetSelection(input_key)
  elseif self.choosing_ally and (input_key == "up" or input_key == "down") then
    self:changeAllySelection(input_key)
  elseif input_key == "return" and (self.choosing_target or self.choosing_ally) then
    self:confirmAction()
    self:updateAlives()
    self.current_turn_index = self.current_turn_index + 1
    self.game_state = "process_turn"
  end
end

-- Processes the current turn
function CombatScene:processTurn()
  local current_combatant = nil

  if #self.turn_orders < self.current_turn_index then
    self.current_turn_index = self.current_turn_index + 1
  else
    current_combatant = self.turn_orders[self.current_turn_index]
  end

  if current_combatant ~= nil then
    if current_combatant.hp <= 0 then
      self.current_turn_index = self.current_turn_index + 1
      self:updateAlives()
      return
    end

    if current_combatant == self.player then
      self.game_state = "playerTurn"
    else
      current_combatant:chooseAction(self.allies_alive, self.enemies_alive, self.player)
      self.current_turn_index = self.current_turn_index + 1
    end
  end

  if self.current_turn_index > #self.turn_orders then
    self.current_turn_index = 1
    self:calculateTurnOrder()
  end

  self:updateAlives()
end

-- Chooses a target to attack
function CombatScene:chooseTarget()
  self.game_state = "choose_target"
  if #self.enemies > 0 then
    self.target_index = 1
    self.choosing_target = true
  end
end

-- Chooses an ally to summon
function CombatScene:chooseAlly()
  self.game_state = "choose_ally"
  if #self.player.inventory > 0 then
    self.target_index = 1
    self.choosing_ally = true
  else
    print("No allies available in inventory.")
    self.choosing_ally = false
    self.action_selected = nil
    self.game_state = "playerTurn"
  end
end

-- Changes the target selection
function CombatScene:changeTargetSelection(input_key)
  if input_key == "up" then
    self.target_index = self.target_index - 1
    if self.target_index < 1 then
      self.target_index = #self.enemies
    end
  elseif input_key == "down" then
    self.target_index = self.target_index + 1
    if self.target_index > #self.enemies then
      self.target_index = 1
    end
  end
end

-- Changes the ally selection
function CombatScene:changeAllySelection(input_key)
  if input_key == "up" then
    self.target_index = self.target_index - 1
    if self.target_index < 1 then
      self.target_index = #self.player.inventory
    end
  elseif input_key == "down" then
    self.target_index = self.target_index + 1
    if self.target_index > #self.player.inventory then
      self.target_index = 1
    end
  end
end

-- Confirms the player's action
function CombatScene:confirmAction()
  if self.choosing_target then
    self:processPlayerAction("attack", self.enemies[self.target_index])
    self.choosing_target = false
  elseif self.choosing_ally then
    local ally_to_summon = self.player.inventory[self.target_index]
    self.player:summonAlly(ally_to_summon)
    self.choosing_ally = false
  end
end

-- Processes the player's action
function CombatScene:processPlayerAction(action, target)
  if action == "attack" then
    self.player:attackTarget(target)
  end
end

-- Updates the combat scene
function CombatScene:update(delta_time)
  if self.game_state == "start" then
    self:calculateTurnOrder()
    self.game_state = "process_turn"
  end

  if self.game_state == "process_turn" then
    self:processTurn()
  end

  if self.game_state == "end_combat" then
    -- End combat logic
  end

  for _, enemy in ipairs(self.enemies) do
    enemy:update(delta_time)
  end
end

-- Draws the combat scene
function CombatScene:draw()
  love.graphics.print("Player: " .. self.player.hp .. " HP | Mana: " .. self.player.mana, 10, 10)

  for i, enemy in ipairs(self.enemies) do
    local indicator = (self.choosing_target and i == self.target_index) and ">" or " "
    love.graphics.print(indicator .. enemy.name .. ": " .. enemy.hp .. " HP", 10, 50 + i * 20)
  end

  for i, ally in ipairs(self.player.allies) do
    love.graphics.print("Ally: " .. ally.name .. " (HP: " .. ally.hp .. ")", 200, 50 + i * 20)
  end

  if self.choosing_ally then
    for i, ally in ipairs(self.player.inventory) do
      local indicator = (self.choosing_ally and i == self.target_index) and ">" or " "
      love.graphics.print(indicator .. ally.name .. " (Mana Cost: " .. ally.manaCost .. ")", 300, 50 + i * 20)
    end
  end

  if self.game_state == "playerTurn" and not self.choosing_target and not self.choosing_ally then
    love.graphics.print("Your Turn: 'a' to attack, 's' to summon", 10, 150)
  elseif self.game_state == "enemyTurn" then
    love.graphics.print("Enemy's turn...", 10, 150)
  end

  if self.game_state == "end_combat" then
    love.graphics.print("Combat Over", 10, 150)
    love.graphics.print(self.victory and "Victory" or "Defeat", 10, 170)
  end
end

return CombatScene
