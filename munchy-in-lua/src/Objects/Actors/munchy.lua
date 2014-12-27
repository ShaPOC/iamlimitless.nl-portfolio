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

-- Munchy is a much more complicated object than the others, we use
-- Various datatype features here
require "System/Foundation/datatypes"
require "System/Foundation/debug"

local munchy = {}
-- For convenience
local size = 220
-- Insert important variables for later use
local _layer
local _world

-- Enable inheritance on the object class
setmetatable(munchy, {
  __index = object, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- Get the resource class
local resource = require( "System/resource" )
-- We trigger a boolean when Munchy is 'in action' which means he has
-- either opened his mouth or is dizzy or any animation except the idle
-- ones like eyerolling
local inAction = false
-- A fixture sensing neighboring objects (for looking at and stuff)
local neighboringFixture

-- Save the previous elapsed time as a reference to see how much
-- time has passed
local previousElapsedTime = 0
-- The countdowns to various actions
local countDownToEyeRolling = false
local countDownToSway = false
local countDownToNotDizzy = false
-- The callback if the dizzy is no longer applied
local dizzyCallback = nil

-- The side it's face is facing, can be either left right or just an empty string
-- This is added to the loaded state at the end to fetch te correct sheet
local _currentFaceSide = ""
-- The same as the face side but in this case when it's an empty string, no state 
-- is currently present
local _currentMouthState = ""

local function animationEnd() 
  
    munchy.setState( "idle" )
    inAction = false

end

-- "Constructor" for this "Class"
function munchy.init( world , layer ) 

    munchy.prop = object.init( 
      "munchy" , 
      resource.get( "Resources/Sprites/Munchy/Idle_0.png" ) ,
      size ,
      size )

    munchy.addAnimationState( 
        "EyeRolling" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/EyeRolling0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/EyeRolling0" ) , -- Lua file containing spriesheet information by texturepacker
        10 , -- Amount of sprites in x axis
        7 , -- Amount of sprites in y axis
        68 , -- Sprite ending position
        1.8 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "Dizzy" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/Dizzy0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/Dizzy0" ) , -- Lua file containing spriesheet information by texturepacker
        10 , -- Amount of sprites in x axis
        7 , -- Amount of sprites in y axis
        66 , -- Sprite ending position
        2.3 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.LOOP -- The mode (loop / normal etc. )
    )

    munchy.addAnimationState( 
        "MouthClose" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthClose0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthClose0" ) , -- Lua file containing spriesheet information by texturepacker
        11 , -- Amount of sprites in x axis
        1 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "MouthCloseLeft" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthCloseLeft0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthCloseLeft0" ) , -- Lua file containing spriesheet information by texturepacker
        11 , -- Amount of sprites in x axis
        1 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "MouthCloseRight" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthCloseRight0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthCloseRight0" ) , -- Lua file containing spriesheet information by texturepacker
        11 , -- Amount of sprites in x axis
        1 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )
    
    munchy.addAnimationState( 
        "MouthCloseUp" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthCloseUp0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthCloseUp0" ) , -- Lua file containing spriesheet information by texturepacker
        4 , -- Amount of sprites in x axis
        3 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "MouthOpen" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthOpen0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthOpen0" ) , -- Lua file containing spriesheet information by texturepacker
        11 , -- Amount of sprites in x axis
        1 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL -- The mode (loop / normal etc. )
    )

    munchy.addAnimationState( 
        "MouthOpenLeft" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthOpenLeft0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthOpenLeft0" ) , -- Lua file containing spriesheet information by texturepacker
        11 , -- Amount of sprites in x axis
        1 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL -- The mode (loop / normal etc. )
    )

    munchy.addAnimationState( 
        "MouthOpenRight" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthOpenRight0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthOpenRight0" ) , -- Lua file containing spriesheet information by texturepacker
        11 , -- Amount of sprites in x axis
        1 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL -- The mode (loop / normal etc. )
    )
    
    munchy.addAnimationState( 
        "MouthOpenUp" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/MouthOpenUp0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/MouthOpenUp0" ) , -- Lua file containing spriesheet information by texturepacker
        4 , -- Amount of sprites in x axis
        3 , -- Amount of sprites in y axis
        11 , -- Sprite ending position
        0.4 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL -- The mode (loop / normal etc. )
    )

    munchy.addAnimationState( 
        "TongueGrab" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/TongueGrab0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/TongueGrab0" ) , -- Lua file containing spriesheet information by texturepacker
        7 , -- Amount of sprites in x axis
        3 , -- Amount of sprites in y axis
        21 , -- Sprite ending position
        0.7 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "TongueGrabLeft" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/TongueGrabLeft0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/TongueGrabLeft0" ) , -- Lua file containing spriesheet information by texturepacker
        7 , -- Amount of sprites in x axis
        3 , -- Amount of sprites in y axis
        21 , -- Sprite ending position
        0.7 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "TongueGrabRight" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/TongueGrabRight0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/TongueGrabRight0" ) , -- Lua file containing spriesheet information by texturepacker
        7 , -- Amount of sprites in x axis
        3 , -- Amount of sprites in y axis
        21 , -- Sprite ending position
        0.7 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    munchy.addAnimationState( 
        "TongueGrabUp" , -- The name of the state
        size , -- The x size of the object
        size , -- The y size of the object
        resource.get( "Resources/Sprites/Munchy/TongueGrabUp0.png" ) , -- The actual spritesheet
        require( "Resources/Sprites/Munchy/TongueGrabUp0" ) , -- Lua file containing spriesheet information by texturepacker
        7 , -- Amount of sprites in x axis
        3 , -- Amount of sprites in y axis
        21 , -- Sprite ending position
        0.7 , -- Animation speed (higher is slower , default is 1 )
        MOAITimer.NORMAL , -- The mode (loop / normal etc. )
        animationEnd -- Callback when the animation has finished
    )

    -- Set the layer and world
    _layer = layer
    _world = world

    -- Set the world for munchy to live in
    munchy.setWorld( world )
    -- Add the body and fixture
    munchy.fixture = munchy.addCircle( MOAIBox2DBody.DYNAMIC , 80 )
    -- Make munchy a sensor (it shouldn't bounce when hitting candy)
    munchy.fixture:setSensor( true )

    -- We create a fixture to sense objects in the vincinity
    neighboringFixture = munchy.addCircle( MOAIBox2DBody.STATIC , 160 )
    -- We make sure it's only a watching fixture ( no one should react to it!!! )
    neighboringFixture.watchingOnly = true
    -- Make sure it's a sensor, we don't want things bouncing off here
    neighboringFixture:setSensor( true )
    -- Set the collision handler!
    neighboringFixture:setCollisionHandler( neighboringCollision )

    -- Munchy is never by default dizzy
    object.isDizzy = false

    return munchy.prop
  
end

local function lookat( obj ) 
  
    local objPos = Vector2.new( obj.body:getPosition() )
    local munchyPos = Vector2.new( munchy.body:getPosition() )
    local direction =  Vector2.new( _layer:worldToWnd( objPos.x , objPos.y ) ) - Vector2.new( _layer:worldToWnd( munchyPos.x , munchyPos.y ) )
  
    local angle = math.atan2( direction.y , direction.x )
    angle = angle * ( 180 / math.pi )
    
    print( angle )

    -- Somewhere to the right
    if angle > -30 and angle < 30 then
        rotateTo( -angle )
        _currentFaceSide = "Right"
    -- Somewhere up
    elseif angle > -180 and angle <= -30 then
        rotateTo( 0 )
        _currentFaceSide = "Up"
    -- Somewhere to the left
    elseif ( angle > -180 and angle < -100 ) or ( angle < 180 and angle > 100 ) then
        rotateTo( -angle /  ( 180 / math.pi ) )
        _currentFaceSide = "Left"
    else
        rotateTo( 0 )
        _currentFaceSide = ""
    end
  
end

function object.eatCandyCollision( phase , fixtureA , fixtureB , arbiter ) 

    if phase == MOAIBox2DArbiter.BEGIN then
        _currentMouthState = ""
        screen.sound.playSound( "munchybite" )
        timer = MOAITimer.new ()
        timer:setMode ( MOAITimer.NORMAL )
        timer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function() screen.sound.playSound( "munchygulp" ) end )
        timer:setSpan ( 0.5 )
        timer:start ()
        munchy.setState( "TongueGrab" .. _currentFaceSide )
    end

end

function rotateTo( angle ) 
  
    munchy.prop:setRot( angle , 0.4 )
  
end

-- This method is used by the slightly larger fixture to see objects in a certain range
-- and react to it by opening munchy's mouth for example
function neighboringCollision( phase , fixtureA , fixtureB , arbiter )

    if ( object.isDizzy == nil or object.isDizzy == false ) and type ( fixtureB.getUserData ) == "function" then 

        local data = fixtureB.getUserData()

        if data.name ~= nil and data.name == "candy" then
          
            if phase == MOAIBox2DArbiter.BEGIN then
              
                -- Munchy open mouth sound
                screen.sound.playSound( "munchyopenmouth" )
                inAction = true
                lookat( data )
                _currentMouthState = "MouthOpen"
                munchy.setState( _currentMouthState .. _currentFaceSide )
                
            end
            
            if phase == MOAIBox2DArbiter.END then
              
                inAction = false
                -- Munchy didn't get the candy and can close it's mouth again
                if _currentMouthState == "MouthOpen" then
                    _currentMouthState = "MouthClose"
                    munchy.setState( _currentMouthState .. _currentFaceSide )
                -- Munchy got the candy!
                else 
                    _currentMouthState = ""
                end
                
                rotateTo( 0 )
            end
            
        end
    end
end

function munchy.fixedUpdate( elapsedTime )

    local newTime = elapsedTime - previousElapsedTime
    previousElapsedTime = elapsedTime
    
    if countDownToNotDizzy ~= false then
        if countDownToNotDizzy - newTime <= 0 then
            -- We can either take action when it's done
            object.isDizzy = false
            countDownToNotDizzy = false
            munchy.setState( "idle" )
            inAction = false
            if type( dizzyCallback ) == "function" then dizzyCallback() end
        else
            -- Or countdown!
            countDownToNotDizzy = countDownToNotDizzy - newTime
        end
    end
    
    if not inAction then
        
        -- If we have nothing to countdown to or it's there, take action!
        if countDownToEyeRolling == false or (countDownToEyeRolling - newTime) <= 0 then
            if countDownToEyeRolling ~= false then munchy.setState( "EyeRolling" ) inAction = true end
            countDownToEyeRolling = math.random( 1.5 , 4 )
        else
            -- Countdown!
            countDownToEyeRolling = countDownToEyeRolling - newTime
        end
    end
end

-- Public method to make munchy dizzy
function object.setDizzy( callback )

    object.isDizzy = true
    inAction = true
    rotateTo( 0 )
    munchy.setState( "Dizzy" )
    countDownToNotDizzy = math.random( 3 , 5 )
    dizzyCallback = callback

end

-- The destroy function is called once the object should no longer be on the screen
function munchy.destroy()

    _currentFaceSide = ""
    _currentMouthState = ""

    previousElapsedTime = 0

    countDownToEyeRolling = false
    countDownToSway = false
    countDownToNotDizzy = false

    dizzyCallback = nil

    if munchy.fixture ~= nil then
        munchy.fixture:destroy()
        munchy.fixture = nil
    end
    if munchy.body ~= nil then
        munchy.body:destroy()
        munchy.body = nil
        object.body = nil
    end
    
    if munchy.prop ~= nil then
        munchy.prop:setDeck( nil )
        munchy.prop = nil
    end
    
    object.destroy()
    object = nil
  
end

return munchy