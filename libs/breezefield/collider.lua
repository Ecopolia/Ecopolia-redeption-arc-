-- a Collider object, wrapping shape, body, and fixtue
local set_funcs, lp, lg, COLLIDER_TYPES = unpack(
   require((...):gsub('collider', '') .. '/utils'))

local Collider = {}
Collider.__index = Collider



function Collider.new(world, collider_type, ...)
   print("Collider.new is deprecated and may be removed in a later version. use world:newCollider instead")
   return world:newCollider(collider_type, {...})
end

function Collider:draw_type()
   if self.collider_type == 'Edge' or self.collider_type == 'Chain' then
      return 'line'
   end
   return self.collider_type:lower()
end

function Collider:__draw__()
   self._draw_type = self._draw_type or self:draw_type()
   local args
   if self._draw_type == 'line' then
      args = {self:getSpatialIdentity()}
   else
      args = {'line', self:getSpatialIdentity()}
   end
   love.graphics[self:draw_type()](unpack(args))
end

function Collider:setDrawOrder(num)
   self._draw_order = num
   self._world._draw_order_changed = true
end

function Collider:getDrawOrder()
   return self._draw_order
end

function Collider:draw()
   self:__draw__()
end


function Collider:destroy()
   self._world:_remove(self)
   self.fixture:setUserData(nil)
   self.fixture:destroy()
   self.body:destroy()
end

function Collider:getSpatialIdentity()
   if self.collider_type == 'Circle' then
      return self:getX(), self:getY(), self:getRadius()
   else
      return self:getWorldPoints(self:getPoints())
   end
end

function Collider:getWidth()
   if self.collider_type == 'Circle' then
      return self:getRadius() * 2 -- The width of a circle is its diameter
   elseif self.collider_type == 'Polygon' then
      local x1, y1, x2, y2 = self:getWorldPoints(self:getPoints())
      return math.abs(x2 - x1) -- Width is the difference between the x-coordinates of the rectangle
   elseif self.collider_type == 'Edge' or self.collider_type == 'Chain' then
      local x1, y1, x2, y2 = self:getWorldPoints(self:getPoints())
      return math.abs(x2 - x1) -- Width is the distance between the two endpoints of the edge/chain
   else
      return 0 -- Default case for unsupported types
   end
end

function Collider:getHeight()
   if self.collider_type == 'Circle' then
      return self:getRadius() * 2 -- The height of a circle is its diameter
   elseif self.collider_type == 'Polygon' then
      local _, _, _, y1, _, y2 = self:getWorldPoints(self:getPoints())
      return math.abs(y2 - y1) -- Height is the difference between the y-coordinates of the rectangle
   elseif self.collider_type == 'Edge' or self.collider_type == 'Chain' then
      local _, _, _, y1, _, y2 = self:getWorldPoints(self:getPoints())
      return math.abs(y2 - y1) -- Height is the distance between the y-coordinates of the two endpoints of the edge/chain
   else
      return 0 -- Default case for unsupported types
   end
end

function Collider:getBoundingBox()
   if self.collider_type == 'Circle' then
      local x, y = self:getX(), self:getY()
      local r = self:getRadius()
      return x - r, y - r, x + r, y + r
   elseif self.collider_type == 'Polygon' then
      local vertices = {self:getWorldPoints(self:getPoints())}
      local min_x, min_y = vertices[1], vertices[2]
      local max_x, max_y = vertices[1], vertices[2]
      for i = 3, #vertices, 2 do
         min_x = math.min(min_x, vertices[i])
         min_y = math.min(min_y, vertices[i+1])
         max_x = math.max(max_x, vertices[i])
         max_y = math.max(max_y, vertices[i+1])
      end
      return min_x, min_y, max_x, max_y
   elseif self.collider_type == 'Edge' or self.collider_type == 'Chain' then
      local x1, y1, x2, y2 = self:getWorldPoints(self:getPoints())
      return math.min(x1, x2), math.min(y1, y2), math.max(x1, x2), math.max(y1, y2)
   else
      error('Collider type not supported for bounding box')
   end
end



function Collider:collider_contacts()
   local contacts = self:getContacts()
   local colliders = {}
   for i, contact in ipairs(contacts) do
      if contact:isTouching() then
	 local f1, f2 = contact:getFixtures()
	 if f1 == self.fixture then
	    colliders[#colliders+1] = f2:getUserData()
	 else
	    colliders[#colliders+1] = f1:getUserData()
	 end
      end
   end
   return colliders
end

return Collider
