---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local space = {}
space._index = space

-- Remember which objects entered already
local _entered = {  }
-- Remember the world
local _world
-- Remember the screen
local _screen

-- Sensor thickness is the acutal thickness of the elements outside the screen
local _sensorThickness = 30
-- Margin outside the screen in pixels (beware, it's scaled down from an iPad resolution!)
local _screenMargin = 220

-- The body which will contain all fixtures
local _spaceBody = nil
-- Every side of the screen
local _leftSideFixture = nil
local _rightSideFixture = nil
local _topSideFixture = nil
local _bottomSideFixture = nil
-- Collision callback functions to be triggered when a collision takes place
local _collisionCallbacks = {}
local _screenFixture = nil

local function triggerCallbacks( side , phase , fixtureA , fixtureB , arbiter )

    if ( not fixtureB.watchingOnly or fixtureB.removeOnOuterSpace ) and fixtureB.enteredTheScreen ~= nil and fixtureB.enteredTheScreen then
        for x , callback in pairs( _collisionCallbacks ) do
            -- We make sure it wants to be collided (some objects only sense)
            callback( side , phase , fixtureA , fixtureB , arbiter )
        end
    end

end

-- "Constructor" for this "Class"
function space.init( world , screen ) 
  
    -- Insert for rememberance
    _world = world
    _screen = screen

    _spaceBody = _world:addBody( MOAIBox2DBody.STATIC )
  
    _leftSideFixture = _spaceBody:addRect(
        ( screen.GAME_WIDTH / -2) -_screenMargin - _sensorThickness , 
        screen.GAME_HEIGHT / -2 - _screenMargin, 
        ( screen.GAME_WIDTH / -2) -_screenMargin , 
        screen.GAME_HEIGHT / 2 + _screenMargin
    )
    _leftSideFixture:setSensor( true )
    _leftSideFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter ) triggerCallbacks( "left" , phase , fixtureA , fixtureB , arbiter ) end )

    _rightSideFixture = _spaceBody:addRect(
        ( screen.GAME_WIDTH / 2) +_screenMargin + _sensorThickness , 
        screen.GAME_HEIGHT / -2 - _screenMargin, 
        ( screen.GAME_WIDTH / 2) +_screenMargin , 
        screen.GAME_HEIGHT / 2 + _screenMargin
    )
    _rightSideFixture:setSensor( true )
    _rightSideFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter ) triggerCallbacks( "right" , phase , fixtureA , fixtureB , arbiter ) end )
    
    _topSideFixture = _spaceBody:addRect(
        screen.GAME_WIDTH / -2 - _screenMargin ,
        ( screen.GAME_HEIGHT / 2) +_screenMargin + _sensorThickness , 
        screen.GAME_WIDTH / 2 + _screenMargin ,
        ( screen.GAME_HEIGHT / 2) +_screenMargin
    )
    _topSideFixture:setSensor( true )
    _topSideFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter ) triggerCallbacks( "top" , phase , fixtureA , fixtureB , arbiter ) end )
    
    _bottomSideFixture = _spaceBody:addRect(
        screen.GAME_WIDTH / -2 - _screenMargin ,
        ( screen.GAME_HEIGHT / -2) -_screenMargin - _sensorThickness , 
        screen.GAME_WIDTH / 2 + _screenMargin ,
        ( screen.GAME_HEIGHT / -2) -_screenMargin
    )
    _bottomSideFixture:setSensor( true )
    _bottomSideFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter ) triggerCallbacks( "bottom" , phase , fixtureA , fixtureB , arbiter ) end )
  
    _screenFixture = _spaceBody:addRect( 
        screen.GAME_WIDTH / -2 ,
        screen.GAME_HEIGHT / -2 , 
        screen.GAME_WIDTH / 2,
        screen.GAME_HEIGHT / 2
    )
    _screenFixture:setSensor( true )
    _screenFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter )

        -- We set a bool telling everyone this fixture was visible inside the screen
        fixtureB.enteredTheScreen = true

    end )
  
end

-- Set the death callback
function space.setCollisionHandler( func )
  
    if type( func ) == "function" then
        table.insert( _collisionCallbacks , func )
    end
  
end

function space.destroy()
  
    --Reset everything!
    _leftSideFixture:destroy()
    _rightSideFixture:destroy()
    _topSideFixture:destroy()
    _bottomSideFixture:destroy()
    _screenFixture:destroy()
    _spaceBody:destroy()

    _spaceBody = nil
    _leftSideFixture = nil
    _rightSideFixture = nil
    _topSideFixture = nil
    _bottomSideFixture = nil
    _screenFixture = nil
    
    _collisionCallbacks = {}
  
end

return space