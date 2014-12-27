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

local blackhole = {}

-- Enable inheritance on the object class
setmetatable(blackhole, {
  __index = object, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- We specify the blackhole.propSize here (for easy adjustment)
local _propSize = 1280
-- The ratio (we need this so we can scale the actual texture alongside the strength)
local _deathRadius
-- Remember which objects entered already
local _entered = {  }
-- Collision handler
local _colHandler
-- The action
local _rotationAction
local _outerRotationAction
-- The world as we remembered it
local _world

-- Get the resource class
local resource = require( "System/resource" )

local function rotate()
    _rotationAction = blackhole.prop:moveRot ( -359 , 40 , MOAIEaseType.LINEAR )
end
local function outerRotate()
    _outerRotationAction = object.outerProp:moveRot ( -359 , 80 , MOAIEaseType.LINEAR )
end

-- Get user data returns everything about the object
-- Almost like the still unimplemented Box2D getUserData would do
function blackhole.getUserData( )
  
    return blackhole
  
end


-- "Constructor" for this "Class"
function blackhole.init( world , deathRadius ) 

    _world = world
    -- Get the aspect ratio
    _deathRadius = deathRadius

    blackhole.prop = object.init( 
      "blackhole" , 
      resource.get( "Resources/Sprites/Singularity/InnerSingularity0.png" ) ,
      _propSize ,
      _propSize )
    
    -- Set the world for the candy to live in
    blackhole.setWorld( world )
    
    blackhole.createBodyAndFixture()

    -- We make it spin!
    rotate()
    
    return blackhole.prop
  
end

function blackhole.createBodyAndFixture()

    -- Add the body and fixture
    blackhole.fixture = blackhole.addCircle( MOAIBox2DBody.STATIC , _deathRadius )
    blackhole.fixture.getUserData = function () return blackhole.getUserData() end
    blackhole.fixture:setSensor( true )
    -- Set random rotation starting angle
    blackhole.body:setTransform( 0 , 0 , math.random( 0 , 359 ) )

end

function blackhole.createOuterSingularity(  )
  
    object.outerQuad = MOAIGfxQuad2D.new()
    object.outerQuad:setTexture( resource.get( "Resources/Sprites/Singularity/OuterSingularity0.png" ) )
    object.outerQuad:setRect( _propSize / -2 , _propSize / -2 , _propSize / 2 , _propSize / 2 )

    object.outerProp = MOAIProp2D.new()
    object.outerProp:setDeck( object.outerQuad )

    -- We make it spin
    outerRotate()

    return object.outerProp

end

function blackhole.createActualHole(  )
  
    object.holeQuad = MOAIGfxQuad2D.new()
    object.holeQuad:setTexture( resource.get( "Resources/Sprites/Singularity/BlackHole0.png" ) )
    object.holeQuad:setRect( _propSize / -2 , _propSize / -2 , _propSize / 2 , _propSize / 2 )

    object.holeProp = MOAIProp2D.new()
    object.holeProp:setDeck( object.holeQuad )

    return object.holeProp

end

function blackhole.setCollisionHandler( func ) 
    -- Add the collision handler
    blackhole.fixture:setCollisionHandler( func )
    if _colHandler == nil then
        _colHandler = func
    end
end

function blackhole.objectEntered( obj , tab , callback )

    -- Check if we already registered the object!
    notInThereYet = true
    for key , val in pairs( _entered ) do
        if val.id == obj.id then notInThereYet = false end
    end
    -- If it's not there yet, go ahead
    if notInThereYet then
      
        if type( tab ) == "table" then

            for key , val in pairs( tab ) do
                blackhole [ key ] = val
            end

            if blackhole.deathRadius ~= _deathRadius then

                local inc = _deathRadius / blackhole.deathRadius

                blackhole.holeProp:moveScl( 1 - inc , 1 - inc , 3 )
                blackhole.outerProp:moveScl( ( 1 - inc ) , ( 1 - inc ) , 3 )
                blackhole.prop:moveScl( ( 1 - inc ) , ( 1 - inc ) , 3 )
                
                _deathRadius = blackhole.deathRadius

            end
        end

        table.insert( _entered , obj )

    end
  
end

-- Check if the object has already entered the black hole
function blackhole.alreadyEntered( obj )

    for key , val in pairs( _entered ) do
        if val.id == obj.id then return true end
    end

    return false
end

function blackhole.fixedUpdate( elapsedTime )
  
    if type(_rotationAction) == "userdata" and _rotationAction:isDone() then _rotationAction:start() end
    if type(_outerRotationAction) == "userdata" and _outerRotationAction:isDone() then _outerRotationAction:start() end
  
end

function blackhole.pause()
  

  
end

function blackhole.resume()
  

  
end

function blackhole.destroy()

    if blackhole.fixture ~= nil then
        blackhole.fixture:destroy()
        blackhole.fixture = nil
    end
    if blackhole.body ~= nil then
        blackhole.body:destroy()
        blackhole.body = nil
        object.body = nil
    end
    
    if blackhole.prop ~= nil then
        blackhole.prop:setDeck( nil )
        blackhole.prop = nil
    end
    
    if blackhole.outerProp ~= nil then
        blackhole.outerProp:setDeck( nil )
        blackhole.outerProp = nil
    end
    
    if blackhole.holeProp ~= nil then
        blackhole.holeProp:setDeck( nil )
        blackhole.holeProp = nil
    end
    
    if object ~= nil then
        object.destroy()
        object = nil
    end
  
end

return blackhole