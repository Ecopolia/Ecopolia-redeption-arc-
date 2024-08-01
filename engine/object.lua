-- /** 
--  * Author: Paul Menut
--  * Date: 01/08/2024
--  * 
--  * This module defines a basic Object class with methods for initialization, 
--  * inheritance, type checking, and instantiation. The Object class can be 
--  * extended to create new classes, and instances of these classes can be 
--  * created using the __call metamethod.
--  */

 Object = {}
 Object.__index = Object
 
 function Object:init()
 end
 
 function Object:extend()
   local cls = {}
   for k, v in pairs(self) do
     if k:find("__") == 1 then
       cls[k] = v
     end
   end
   cls.__index = cls
   cls.super = self
   setmetatable(cls, self)
   return cls
 end
 
 function Object:is(T)
   local mt = getmetatable(self)
   while mt do
     if mt == T then
       return true
     end
     mt = getmetatable(mt)
   end
   return false
 end
 
 function Object:__call(...)
   local obj = setmetatable({}, self)
   obj:init(...)
   return obj
 end