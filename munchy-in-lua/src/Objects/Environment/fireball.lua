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

local fireball = {}

-- Enable inheritance on the object class
setmetatable(fireball, {
  __index = object, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- Get the resource class
resource = require( "System/resource" )

local _spawningPosition
local _layer
local _sound

local _alertTimer = nil
local _soundTimer = nil
local _spaceTimer = nil

-- "Constructor" for this "Class"
function fireball.init( world , position , layer , sound ) 
  
    -- We remember the position for the velocity when spawned
    _spawningPosition = position
    -- And the layer because we spawn some ui elements there
    _layer = layer
    -- Set the sound manager
    _sound = sound
  
    fireball.prop = object.initWithAnimatedSpriteSheet( 
        "fireball" , 
        resource.get( "Resources/Sprites/Fireball/Fireball0.png" ) ,
        2 ,
        3 ,
        6 ,
        require( "Resources/Sprites/Fireball/Fireball0" ) ,
        512 ,
        512 ,
        0.5 )
    
    -- Set the world for the candy to live in
    fireball.setWorld( world )
    -- Add the body and fixture
    fireball.fixture = fireball.addCircle( MOAIBox2DBody.DYNAMIC , 120 )
    fireball.fixture.watchingOnly = true
    fireball.fixture:setSensor( true )
    fireball.body:setMassData( 2 )
    -- Set the position
    fireball.body:setTransform( position.x , position.y )
    
    return fireball.prop
  
end

function fireball.setCollisionHandler( func )
  
    if fireball.fixture ~= nil then
        fireball.fixture:setCollisionHandler( func )
    end
  
end

local function alertPlayer( size , position , callback )

    local alertQuad = MOAIGfxQuad2D.new()
    alertQuad:setTexture( resource.get( "Resources/UI/hud_warning.png" ) )
    alertQuad:setRect( size.x / -2 , size.y / -2 , size.x / 2 , size.y / 2 )

    local alertProp = MOAIProp2D.new()
    alertProp:setDeck( alertQuad )

    -- Add the alert here
    -- Wait for 2 seconds before actually sending it into the screen, we want the user to be alerted
    if _alertTimer ~= nil and _alertTimer:isBusy() then _alertTimer:stop() end
    _alertTimer = MOAITimer.new ()
    _alertTimer:setMode ( MOAITimer.NORMAL )
    _alertTimer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function() 
        if type( callback ) == "function" then
            callback()
        end
    end)
    _alertTimer:setSpan ( 2 )
    _alertTimer:start ()

end

function fireball.spawn( addedRadius , v , target )

    trueTarget = ( target or Vector2.new( 0 , 0 ) ) + addedRadius

    local direction =  Vector2.new(  trueTarget.x , trueTarget.y ) - Vector2.new( _spawningPosition.x , _spawningPosition.y )

    local angle = math.atan2( direction.y , direction.x )
    angle = angle * ( 180 / math.pi )

    fireball.prop:setRot( angle )

    alertPlayer( Vector2.new( 102 , 106 ) , _spawningPosition , function()

        -- Velocity towards the object
        velocity = ( trueTarget - _spawningPosition )
        -- Slow it down!
        velocity = velocity * v

        fireball.body:applyLinearImpulse( velocity.x , velocity.y )

        -- Wait for 0.6 seconds ( so we are sure it's in the screen ) and then play the sound
        if _soundTimer ~= nil and _soundTimer:isBusy() then _soundTimer:stop() end
        _soundTimer = MOAITimer.new ()
        _soundTimer:setMode ( MOAITimer.NORMAL )
        _soundTimer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function() 
            _sound.playSound( "fireball" ) 
            if _spaceTimer ~= nil and _spaceTimer:isBusy() then _spaceTimer:stop() end
            _spaceTimer = MOAITimer.new ()
            _spaceTimer:setMode ( MOAITimer.NORMAL )
            _spaceTimer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function() 
                fireball.fixture.removeOnOuterSpace = true
            end )
            _spaceTimer:setSpan ( 1.5 )
            _spaceTimer:start ()
        end )
        _soundTimer:setSpan ( 0.6 )
        _soundTimer:start ()

    end )

end

function fireball.destroy() 
    
    if _alertTimer ~= nil and _alertTimer:isBusy() then _alertTimer:stop() end
    if _soundTimer ~= nil and _soundTimer:isBusy() then _soundTimer:stop() end
    if _spaceTimer ~= nil and _spaceTimer:isBusy() then _spaceTimer:stop() end
    
    _alertTimer = nil
    _soundTimer = nil
    _spaceTimer = nil
    
    if fireball.fixture ~= nil then
        fireball.fixture:destroy()
        fireball.fixture = nil
    end
    if fireball.body ~= nil then
        fireball.body:destroy()
        fireball.body = nil
        object.body = nil
    end
    
    if fireball.prop ~= nil then
        fireball.prop:setDeck( nil )
        fireball.prop = nil
    end
    
    object.destroy()
    object = nil

end

return fireball