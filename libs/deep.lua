local deep = {}

function deep:new()
   local instance = {
      r = {},
      z_min = nil,
      z_max = nil,
      q = {},
   }
   setmetatable(instance, self)
   self.__index = self
   return instance
end

function deep:queue(z, fn)
   if self.r.z_from and z < self.r.z_from then
      return
   end

   if self.r.z_to and z > self.r.z_to then
      return
   end

   if not self.q[z] then
      self.q[z] = {}
   end

   table.insert(self.q[z], fn)

   if not self.z_min or not self.z_max then
      self.z_min = z
      self.z_max = z
   elseif z < self.z_min then
      self.z_min = z
   elseif z > self.z_max then
      self.z_max = z
   end
end

function deep:restrict(z_from, z_to)
   self.r.z_from = z_from
   self.r.z_to = z_to
end

function deep:draw(z_from, z_to)
   local from, to
   if z_from and z_to then
      if z_from > z_to then
         printf("z_from (%i) can't be larger than z_to (%i)", z_from, z_to)
         return
      end
   
      if z_from > self.z_max or z_to < self.z_min then
         -- Nothing to draw
         return
      end
   
      from = math.max(z_from, self.z_min)
      to = math.min(z_to, self.z_max)
   else
      from = self.z_min
      to = self.z_max
   end

   -- Nothing queued, nothing to draw
   if not from or not to then
      return
   end

   if from > to then
      -- Nothing to draw
      return
   end

   for i=from, to do
      local fns = self.q[i]
      if fns then
         for _, fn in ipairs(fns) do
            fn()
         end
      end
   end

   self.q = {}
end

return deep