---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

Vector2 = {}
Vector2.__index = Vector2
 
function Vector2.__add(a, b)
  if type(a) == "number" then
    return Vector2.new(b.x + a, b.y + a)
  elseif type(b) == "number" then
    return Vector2.new(a.x + b, a.y + b)
  else
    return Vector2.new(a.x + b.x, a.y + b.y)
  end
end
 
function Vector2.__sub(a, b)
  if type(a) == "number" then
    return Vector2.new(b.x - a, b.y - a)
  elseif type(b) == "number" then
    return Vector2.new(a.x - b, a.y - b)
  else
    return Vector2.new(a.x - b.x, a.y - b.y)
  end
end
 
function Vector2.__mul(a, b)
  if type(a) == "number" then
    return Vector2.new(b.x * a, b.y * a)
  elseif type(b) == "number" then
    return Vector2.new(a.x * b, a.y * b)
  else
    return Vector2.new(a.x * b.x, a.y * b.y)
  end
end
 
function Vector2.__div(a, b)
  if type(a) == "number" then
    return Vector2.new(b.x / a, b.y / a)
  elseif type(b) == "number" then
    return Vector2.new(a.x / b, a.y / b)
  else
    return Vector2.new(a.x / b.x, a.y / b.y)
  end
end
 
function Vector2.__eq(a, b)
  return a.x == b.x and a.y == b.y
end
 
function Vector2.__lt(a, b)
  return a.x < b.x or (a.x == b.x and a.y < b.y)
end
 
function Vector2.__le(a, b)
  return a.x <= b.x and a.y <= b.y
end
 
function Vector2.__tostring(a)
  return "(" .. a.x .. ", " .. a.y .. ")"
end
 
function Vector2.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, Vector2)
end
 
function Vector2.distance(a, b)
  return (b - a):len()
end
 
function Vector2:clone()
  return Vector2.new(self.x, self.y)
end
 
function Vector2:unpack()
  return self.x, self.y
end
 
function Vector2:len()
  return math.sqrt(self.x * self.x + self.y * self.y)
end
 
function Vector2:lenSq()
  return self.x * self.x + self.y * self.y
end
 
function Vector2:normalize()
  local len = self:len()
  self.x = self.x / len
  self.y = self.y / len
  return self
end
 
function Vector2:normalized()
  return self / self:len()
end
 
function Vector2:rotate(phi)
  local c = math.cos(phi)
  local s = math.sin(phi)
  self.x = c * self.x - s * self.y
  self.y = s * self.x + c * self.y
  return self
end
 
function Vector2:rotated(phi)
  return self:clone():rotate(phi)
end
 
function Vector2:perpendicular()
  return Vector2.new(-self.y, self.x)
end
 
function Vector2:projectOn(other)
  return (self * other) * other / other:lenSq()
end
 
function Vector2:cross(other)
  return self.x * other.y - self.y * other.x
end
 
setmetatable(Vector2, { __call = function(_, ...) return Vector2.new(...) end })

-- Shallow copy
function shallowcopy(orig)
  
    local orig_type = type(orig)
    local copy
    
    if orig_type == 'table' then
      
        copy = {}
        
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
        
    else -- number, string, boolean, etc
        copy = orig
    end
    
    return copy
end

-- Remove from table by value
function tableRemoveByValue( table , values )
  
    for i = #table , 1 , -1 do
        if values[ table[ i ] ] then
            table.remove( table , i )
        end
    end
    
end

-- Check if circles intersect
-- This is used to find out wether two fingers or just one finger is used
function circlesIntersect( c1X , c1Y , c1Radius , c2X , c2Y , c2Radius )
  
    distanceX = c2X - c1X;
    distanceY = c2Y - c1Y;
 
    magnitude = math.sqrt(distanceX * distanceX + distanceY * distanceY);
    return magnitude < c1Radius + c2Radius;
    
end