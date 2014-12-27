---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local object = {}
-- This class is abstract and may not be initialized on it's own!
--object.__index = object

setmetatable(object, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

-- All the available states (idle , etc.)
local _states = {}
-- The current state
local _currentState = nil

-- Private fields used by this class
local _world = nil
-- Animation variables
local _spritePosition = nil
local _spriteEnd = nil
local _spriteStep = nil

-- Generate a unique id for this object
object.id = nil
-- The name of the object
object.name = nil
-- These public variables will be filled on init
object.quad = nil
object.prop = nil
object.body = nil
object.fixture = nil
-- The width and height for easy reference
object.width = nil
object.height = nil
object.anim = nil

-- Class wide private variables
local AnimCurve = nil
local Time = nil
local IndexCount = nil
-- Sometimes we wish to force stop an animation becuase another animation
-- is going to override it
local forceEndAnimation = false

-- "Constructor" for this "Class"
function object.init( name , texture , width , height ) 
  
    object.id = MOAIEnvironment:generateGUID()
    object.name = name
  
    object.width = width
    object.height = height
  
    object.prop = MOAIProp2D.new()
  
    object.addIdleState( "idle" , texture , width , height )
    object.setState( "idle" )
    
    return object.prop
end

-- "Constructor" for this "class" to enable animated spritesheet
function object.initWithAnimatedSpriteSheet( name , spritesheet , sheetXCount , sheetYCount , sheetEnd , sheetlua , width , height , spriteStep , mode , callback )

    object.id = MOAIEnvironment:generateGUID()
    object.name = name

    object.width = width
    object.height = height

    object.prop = MOAIProp2D.new()
    
    object.addAnimationState( "idle" , width , height ,  spritesheet , sheetlua , sheetXCount , sheetYCount , sheetEnd , spriteStep , mode , callback )
    object.setState( "idle" )

    object.animate( mode )

    return object.prop
end
local function endAnimation( callback ) 
  
    if _spriteEnd ~= nil then
        AnimCurve:reserveKeys( 1 )
        AnimCurve:setKey( 1 , _spriteEnd , _spriteEnd , MOAIEaseType.FLAT )

        object.anim:reserveLinks( 1 )
        object.anim:setLink( 1 , AnimCurve , object.prop , MOAIProp.ATTR_INDEX )
    end

    if not forceEndAnimation and type( callback ) == "function" then
        callback()
    end
  
end

function object.animate( mode , callback )
  
    -- create the animation curve
    AnimCurve = MOAIAnimCurve.new()
    Time = 1
    IndexCount = _spriteEnd - _spritePosition + 2

    if mode == nil then
        mode = MOAITimer.LOOP
    end

    AnimCurve:reserveKeys(IndexCount)
    -- loop through each frame over time
    for Index = _spritePosition, _spriteEnd do
        AnimCurve:setKey( Time, _spriteStep * ( Time - 1 ), Index , MOAIEaseType.FLAT )
        Time = Time + 1
    end
    -- add the last frame (to time it right)
    AnimCurve:setKey( Time , _spriteStep * ( Time - 1 ) , StopIndex, MOAIEaseType.FLAT )

    -- create the anim
    object.anim = MOAIAnim:new()
    object.anim:reserveLinks( 1 )
    object.anim:setLink( 1 , AnimCurve , object.prop , MOAIProp2D.ATTR_INDEX )
    object.anim:setMode( mode )

    -- We stop at the end of the animation and stay at that frame!
    -- We don't every want the sprite to dissapear because it has no more frames
    -- And if you want to change the animation at the end, just use the callback!
    object.anim:setListener( MOAIAnim.EVENT_STOP , function() endAnimation( callback ) end )

    object.anim:start()
    return object.anim
  
end

function object.addIdleState ( name , texture , width , height )

    _states[ name ] = MOAIGfxQuad2D.new()
    _states[ name ]:setTexture( texture )
    _states[ name ]:setRect( width / -2 , height / -2 , width / 2 , height / 2 )
    _states[ name ].animated = false

end

function object.addAnimationState ( name , width , height ,  spritesheet , sheetlua , sheetXCount , sheetYCount , sheetEnd , spriteStep , mode , callback )

    if mode == nil then
        mode = MOAITimer.LOOP
    end

    if spriteStep == nil then
        spriteStep = 1
    end

    _states[ name ] = MOAITileDeck2D.new()
    _states[ name ]:setTexture( spritesheet )
    _states[ name ]:setRect( width / -2 , height / -2 , width / 2 , height / 2 )
    _states[ name ]:setSize( sheetXCount , sheetYCount )
    
    _states[ name ].mode = mode
    _states[ name ].sheetlua = sheetlua
    _states[ name ].sheetEnd = sheetEnd or sheetXCount * sheetYCount
    _states[ name ].spriteStep = spriteStep / sheetEnd
    
    if type( callback ) == "function" then
        _states[ name ].callback = callback
    end
    
    _states[ name ].animated = true

end

function object.setState( name )

    if _currentState ~= name then
        -- Set the current state
        _currentState  = name

        if _states ~= nil and _states[ name ] ~= nil then

            -- Stop the animation if there is one going
            if object.anim ~= nil and object.anim:isBusy() then
                forceEndAnimation = true
                object.anim:stop()
                forceEndAnimation = false
            end

            -- Reset everything
            _spritePosition = 1
            _spriteEnd = _states[ name ].sheetEnd
            _spriteStep = _states[ name ].spriteStep

            -- Set the new deck
            object.prop:setDeck( _states[ name ] )

            -- If it's animated, start to animate it
            if _states[ name ].animated then

                _spritePosition = 1
                _spriteEnd = _states[ name ].sheetEnd
                _spriteStep = _states[ name ].spriteStep

                return object.animate( _states[ name ].mode , _states[ name ].callback )

            -- Else if it animated before, reset everything!
            elseif object.anim ~= nil then

                AnimCurve:reserveKeys( 1 )
                AnimCurve:setKey( 1 , 1 , 1 , MOAIEaseType.FLAT )
                object.anim:reserveLinks( 1 )
                object.anim:setLink( 1 , AnimCurve , object.prop , MOAIProp.ATTR_INDEX )

            end
        end
    else 
        return _states[ name ]
    end
end

function object.getWorld( )
  
    return _world
  
end

function object.setWorld( world )
  
    _world = world
  
end

local function _addBody( box2dbody )
  
    if object.body == nil then
        object.body = _world:addBody( box2dbody )
        object.prop:setParent( object.body )
    end
  
end

function object.addBody( box2dbody )
  
    _addBody( box2dbody )
  
end

-- Get user data returns everything about the object
-- Almost like the still unimplemented Box2D getUserData would do
function object.getUserData( )
  
    return object
  
end

-- And we would like to be able to set it too
-- The table inserted will be merged
function object.setUserData( table )

    if type( table ) == "table" then
        for key , val in pairs( table ) do
            object[ key ] = val
        end
    end

end

-- The actual private add circle version used by the public
-- overload methods
function object.addCircle( box2dbody , radius )
  
    if radius == nil then

        radius = object.width / 2

    end
  
    if _world ~= nil then

        _addBody( box2dbody )

        local fixture = object.body:addCircle( 0 , 0 , radius )
        fixture.getUserData = function () return object.getUserData() end
        object.body:resetMassData()
        return fixture

    end
  
end

function object.destroy()

    if object.fixture ~= nil then
        object.fixture:destroy()
        object.fixture = nil
    end
    
    if object.body ~= nil then
        object.body:destroy()
        object.body = nil
    end
    
    if object.prop ~= nil then
        object.prop:setDeck( nil )
        object.prop = nil
    end

    _states = nil
    _currentState = nil
    _world = nil
    _spritePosition = nil
    _spriteEnd = nil
    _spriteStep = nil

    object.id = nil
    object.name = nil
    object.quad = nil
    object.prop = nil
    object.width = nil
    object.height = nil

    if object.anim ~= nil then
        object.anim:clear()
        object.anim = nil
    end
    
    AnimCurve = nil
    Time = nil
    IndexCount = nil

end

return object