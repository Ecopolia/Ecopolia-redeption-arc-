-- HexGrid object
local HexGrid = {}

function HexGrid.new(hexRadius)
  local grid = {
    hexRadius = hexRadius,
    xOffset = hexRadius * math.sqrt(3),
    yOffset = hexRadius * 1.5,
    xSpacing = 0,
    ySpacing = 0,
    rows = 0,
    columns = 0,
    mouseX = 0,
    mouseY = 0,
    selectedRow = 0,
    selectedCol = 0,
    camera = {
      x = 0,
      y = 0
    },
    keysPressed = {},
    isCameraEnabled = true,
    data = {},
    dataReady = false
  }
  setmetatable(grid, { __index = HexGrid })
  return grid
end

function HexGrid:setSize(rows, columns)
  self.rows = rows
  self.columns = columns
end

function HexGrid:setSpacing(xSpacing, ySpacing)
  self.xSpacing = xSpacing
  self.ySpacing = ySpacing
end

function HexGrid:setData(row, col, hexData)
  local index = (row - 1) * self.columns + col
  self.data[index] = hexData
end

function HexGrid:getData(row, col)
  local index = (row - 1) * self.columns + col
  return self.data[index]
end

function HexGrid:isDataReady()
  return self.dataReady
end

function HexGrid:toggleDataReady(state)
  self.dataReady = state or not self.dataReady
end

function HexGrid:updateMousePosition(x, y)
  self.mouseX = x
  self.mouseY = y
  self:selectedHexagon()
end

function HexGrid:selectedHexagon()
  self.selectedRow = 0
  self.selectedCol = 0

  -- Calculate the center position of the grid
  local gridWidth = self.columns * self.xOffset
  local gridHeight = self.rows * self.yOffset
  local centerX = love.graphics.getWidth() / 2 - gridWidth / 2
  local centerY = love.graphics.getHeight() / 2 - gridHeight / 2

  -- Adjust mouse coordinates based on camera position
  local mouseXAdjusted = self.mouseX + self.camera.x - centerX
  local mouseYAdjusted = self.mouseY + self.camera.y - centerY

  -- Calculate approximate column and row based on mouse position
  local approxCol = math.floor(mouseXAdjusted / (self.xOffset + self.xSpacing))
  local approxRow = math.floor((mouseYAdjusted - (approxCol % 2) * (self.yOffset / 2)) / (self.yOffset + self.ySpacing))

  -- Calculate the exact position of the hexagon based on the approximate column and row
  local hexX = approxCol * (self.xOffset + self.xSpacing)
  local hexY = approxRow * (self.yOffset + self.ySpacing) + (approxCol % 2) * (self.yOffset / 2)

  -- Calculate the distance from the mouse position to the hexagon's center
  local dx = mouseXAdjusted - hexX
  local dy = mouseYAdjusted - hexY

  -- Determine if the mouse position is closer to a neighboring hexagon
  if dx > self.hexRadius / 2 then
    if dy < 0 then
      approxRow = approxRow - 1
      if approxCol % 2 == 0 then
        approxCol = approxCol + 1
      end
    else
      approxRow = approxRow + 1
      if approxCol % 2 == 1 then
        approxCol = approxCol + 1
      end
    end
  end

  if approxCol >= 0 and approxCol < self.columns and approxRow >= 0 and approxRow < self.rows then
    self.selectedRow = approxRow + 1
    self.selectedCol = approxCol + 1
  end
end

function HexGrid:calculateVertices(x, y)
  local vertices = {}
  for i = 1, 6 do
    local angle = (2 * math.pi / 6) * (i - 1) + math.pi / 6
    local vertexX = x + self.hexRadius * math.cos(angle)
    local vertexY = y + self.hexRadius * math.sin(angle)
    table.insert(vertices, vertexX)
    table.insert(vertices, vertexY)
  end
  return vertices
end

function HexGrid:draw()
  -- Calculate the center position of the grid
  local gridWidth = self.columns * self.xOffset
  local gridHeight = self.rows * self.yOffset
  local centerX = love.graphics.getWidth() / 2 - gridWidth / 2
  local centerY = love.graphics.getHeight() / 2 - gridHeight / 2

  local hexagonSpacingX = self.xSpacing  -- Adjust the spacing between hexagons in the x direction
  local hexagonSpacingY = self.ySpacing  -- Adjust the spacing between hexagons in the y direction

  for row = 1, self.rows do
    for col = 1, self.columns do
      local x = centerX + col * (self.xOffset + hexagonSpacingX) - self.camera.x
      if row % 2 == 0 then
        x = x + (self.xOffset + hexagonSpacingX) / 2
      end
      local y = centerY + row * (self.yOffset + hexagonSpacingY) - self.camera.y

      local vertices = self:calculateVertices(x, y)

      if row == self.selectedRow and col == self.selectedCol then
        love.graphics.setColor(1, 1, 1)  -- Set color to white for the selected hexagon
        love.graphics.polygon('fill', vertices)
      else
        love.graphics.setColor(1, 1, 1)  -- Set color to black for other hexagons
        love.graphics.polygon('line', vertices)
      end

      -- if data is ready, display the wheight of the hexagon
      if self:isDataReady() then
        -- Display data.wheight in the middle of the hexagon
        hexData = self:getData(row, col)
        
        if hexData then
          love.graphics.print(hexData.wheight, x - 10, y - 10)
        end
      end

    end
  end
end


-- Camera methods
function HexGrid:moveCamera(dx, dy)
  if not self.isCameraEnabled then
    return  -- Camera movement is disabled, do nothing
  end

  local gridWidth = self.columns * self.xOffset
  local gridHeight = self.rows * self.yOffset
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  -- Calculate the maximum allowed camera movement based on the grid and screen sizes
  local left = -(gridWidth - screenWidth) / 2
  local top = -(gridHeight - screenHeight) / 2
  
  local right = -left + (2 * self.hexRadius)
  local bot = -top + (2 * self.hexRadius)

  -- Limit camera movement within the grid bounds
  self.camera.x = math.max(left, math.min(right, self.camera.x + dx))
  self.camera.y = math.max(top, math.min(bot, self.camera.y + dy))
end

-- Method to toggle camera movement
function HexGrid:toggleCameraMovement(state)
  self.isCameraEnabled = state or not self.isCameraEnabled
end

function HexGrid:updateCameraMovement(dt)
  local moveSpeed = 300 -- Adjust the move speed as needed

  if (self.keysPressed["up"] or self.keysPressed["w"]) then
    self:moveCamera(0, -moveSpeed * dt)
  end
  if (self.keysPressed["down"] or self.keysPressed["s"]) then
    self:moveCamera(0, moveSpeed * dt)
  end
  if (self.keysPressed["left"] or self.keysPressed["a"]) then
    self:moveCamera(-moveSpeed * dt, 0)
  end
  if (self.keysPressed["right"] or self.keysPressed["d"]) then
    self:moveCamera(moveSpeed * dt, 0)
  end

  self:selectedHexagon()
end

return HexGrid