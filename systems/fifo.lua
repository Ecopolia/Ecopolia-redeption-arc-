-- Fifo Queue implementation
local Fifo = {}
function Fifo.new () return setmetatable({first=1,last=0},{__index=Fifo}) end
function Fifo:peek() return self[self.first] end
function Fifo:len() return (self.last+1)-self.first end

function Fifo:push(value)
  self.last = self.last + 1
  self[self.last] = value
end

function Fifo:pop()
  if self.first > self.last then return end
  local value = self[self.first]
  self[self.first] = nil
  self.first = self.first + 1
  return value
end

return Fifo