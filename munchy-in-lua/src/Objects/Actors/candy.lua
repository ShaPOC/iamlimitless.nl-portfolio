---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- 'Mother / Base / Parent' Class
local object = dofile( _G.ROOT .. "System/Elements/object.lua" )

local candy = {}

-- Enable inheritance on the object class
setmetatable(candy, {
  __index = object, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- Get the resource class
resource = require( "System/resource" )

-- Colors
local colors = {
    "Striped",
    "Pink"
}
-- Rotations
local rotations = {
    "Flip",
    "Roll"
}

local _rotationSpeed = 25

local function rotate()
    _rotationAction = candy.prop:moveRot ( -359 , _rotationSpeed , MOAIEaseType.LINEAR )
end

local _spawningPosition = nil

-- "Constructor" for this "Class"
function candy.init( world , position , layer ) 

    -- We remember the position for the velocity when spawned
    _spawningPosition = position

    candy.prop = object.initWithAnimatedSpriteSheet( 
        "candy" , 
        resource.get( "Resources/Sprites/Candy/Candy" .. colors[ math.random( 1 , 2 ) ] .. rotations[ math.random( 1 , 2 ) ] .. "0.png" ) ,
        7 ,
        9 ,
        61 ,
        require( "Resources/Sprites/Candy/Candy" .. colors[ math.random( 1 , 2 ) ] .. rotations[ math.random( 1 , 2 ) ] .. "0" ) ,
        64 ,
        64 ,
        math.random( 1.40 , 2.60 ) )
    
    -- We generate a random rotation speed for extra niceness
    _rotationSpeed = math.random( 6 , 25 )

    -- Set the world for the candy to live in
    candy.setWorld( world )
    -- Add the body and fixture
    candy.fixture = candy.addCircle( MOAIBox2DBody.DYNAMIC )
    -- Set the position
    candy.body:setTransform( position.x , position.y )
    
    -- We make it spin!
    rotate()
    
    return candy.prop
  
end

function candy.spawn( target , v )

    -- Velocity towards the object
    velocity = ( Vector2.new( 0 , 0 ) + target - _spawningPosition )
    -- Slow it down!
    velocity = velocity * v

    candy.body:applyLinearImpulse( velocity.x , velocity.y )

end

function candy.fixedUpdate( elapsedTime )

    if type(_rotationAction) == "userdata" and _rotationAction:isDone() then _rotationAction:start() end

end

function candy.pause()
  
    if type(_rotationAction) == "userdata" then
        _rotationAction:pause()
    end
  
end

function candy.resume()
  
    if type(_rotationAction) == "userdata" then
        _rotationAction:start()
    end
  
end

-- The destroy function is called once the object should no longer be on the screen
function candy.destroy()
  
    _rotationAction = nil
    
    if candy.fixture ~= nil then
        candy.fixture:destroy()
        candy.fixture = nil
    end
    if candy.body ~= nil then
        candy.body:destroy()
        candy.body = nil
        object.body = nil
    end
    
    if candy.prop ~= nil then
        candy.prop:setDeck( nil )
        candy.prop = nil
    end
    
    object.destroy()
    object = nil
  
end

return candy