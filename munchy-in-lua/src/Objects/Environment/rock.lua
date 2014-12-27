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

local rock = {}

-- Enable inheritance on the object class
setmetatable(rock, {
  __index = object, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- Get the resource class
resource = require( "System/resource" )

local _rotationAction
local _rotationSpeed = 25

local function rotate()
    _rotationAction = rock.prop:moveRot ( -359 , _rotationSpeed , MOAIEaseType.LINEAR )
end

local _spawningPosition

-- "Constructor" for this "Class"
function rock.init( world , position , layer ) 
  
      -- We remember the position for the velocity when spawned
    _spawningPosition = position
  
    rock.prop = object.initWithAnimatedSpriteSheet( 
        "rock" , 
        resource.get( "Resources/Sprites/Rocks/Rocks0.png" ) ,
        9 ,
        7 ,
        61 ,
        require( "Resources/Sprites/Rocks/Rocks0" ) ,
        92 ,
        92 ,
        math.random( 1.40 , 2.60 ) )
    
    -- We generate a random rotation speed for extra niceness
    _rotationSpeed = math.random( 6 , 25 )

    -- Set the world for the candy to live in
    rock.setWorld( world )
    -- Add the body and fixture
    rock.fixture = rock.addCircle( MOAIBox2DBody.DYNAMIC , 30 )
    rock.body:setMassData( 2 )
    -- Set the position
    rock.body:setTransform( position.x , position.y )
    
    -- We make it spin!
    rotate()
    
    return rock.prop
  
end

function rock.spawn( target , v )

    -- Velocity towards the object
    velocity = ( Vector2.new( 0 , 0 ) + target - _spawningPosition )
    -- Slow it down!
    velocity = velocity * v

    rock.body:applyLinearImpulse( velocity.x , velocity.y )

end

function rock.fixedUpdate( elapsedTime )
  
    if type(_rotationAction) == "userdata" and _rotationAction:isDone() then _rotationAction:start() end
  
end

function rock.destroy() 

    _rotationAction = nil
    
    if rock.fixture ~= nil then
        rock.fixture:destroy()
        rock.fixture = nil
    end
    if rock.body ~= nil then
        rock.body:destroy()
        rock.body = nil
        object.body = nil
    end
    
    if rock.prop ~= nil then
        rock.prop:setDeck( nil )
        rock.prop = nil
    end
    
    object.destroy()
    object = nil

end

return rock