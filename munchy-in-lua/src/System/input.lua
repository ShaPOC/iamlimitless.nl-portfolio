---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local input = {}
input.__index = input

-- Debug mode
local _debug = false
-- We need to be able to test two fingers with the mouse
local _twoFingers = false
-- Layers to check for props
local _propLayers = {}

local _callbacks = {
    
    touch = {
        down = {},
        up = {},
        move = {}
    },
    key = {
        down = {},
        up = {}
    }
}

-- A fake ID for the first and the second finger (if needed)
local fakeID_01
local fakeID_02

-- Moai can only recognize 4 fingers and gets realy buggy after that
-- because it will reuse the finger idx's it already used, screwing 
-- up everything! So we keep track of which id's are already used
-- and if it's used again, we force a up touch on the old one
local _currentTouchCount = 0
-- PreviousTouches are remembered here, because we want to catch if
-- the touch cancels (when going outside the parition) so we can
-- Fix the animation
local _previouslyPropertiesTouched = {}

local function onTouch( touchType , idx , x , y , tapCount)

    local propagationStopped = false

    for layerName , layer in pairs( _propLayers ) do 

        -- Let's see what we clicked...
        local propertiesTouched = { layer[ "partition" ]:propListForPoint( layer[ "layer" ]:wndToWorld( x , y ) ) }
        local propertiesTouchedNow = {}

        for i , prop in pairs( propertiesTouched ) do

            -- We immediately remember for the next time
            propertiesTouchedNow[ prop.id ] = prop
            -- If the prop actually has a callback, we clicked on something that needs doing, so do it
            if touchType ~= "move" and type( prop.onTouch ) == "function" then
                prop.onTouch( touchType , idx , x , y , tapCount )
            end
            -- If ignore all other touches is enabled, then only use this property touched
            if prop.stopPropagation then
                propagationStopped = true
                break
            end
        end

        -- We check if a property now isn't touched anymore
        for i , prevProp in pairs( _previouslyPropertiesTouched ) do

            if propertiesTouchedNow[ prevProp.id ] == nil and type( prevProp.onTouch ) == "function" then
                prevProp.onTouch( "cancel" , idx , x , y , tapCount )
            end
        end

        -- And finally we set the previously touched to what is touched now
        _previouslyPropertiesTouched = propertiesTouchedNow
    end

    if propagationStopped == false then 
      
        for i , callback in pairs(_callbacks[ "touch" ][ touchType ]) do

            if type(callback) == "function" then 
                callback( idx , x , y , tapCount )
                if _twoFingers then 
                    diff = math.random( -100 , 100 )
                    callback( ( idx ~= fakeID_01 and idx or fakeID_02 ), x + diff, y + diff, tapCount )
                end
            end
        end
    end
end

function input.setPropLayer( name , layer )
    
    if _propLayers[ name ] == nil then
        _propLayers[ name ] = {}
    end
    
    _propLayers[ name ]["layer"] = layer
    _propLayers[ name ]["partition"] = MOAIPartition.new()
    _propLayers[ name ]["layer"]:setPartition( _propLayers[ name ]["partition"] )

end

function input.removePropLayer( name )

    _propLayers[ name ] = nil

end

local function onKey( eventType , key )
  
    if _debug and key == 480 then
      _twoFingers = ( eventType == "down" ) 
      if not _twoFingers then
          for i , callback in pairs(_callbacks[ "touch" ][ "up" ]) do
              callback( fakeID_02 , 0 , 0 , 0 )
          end
      end
    end
  
    for i , callback in pairs(_callbacks[ "key" ][ eventType ]) do

        if type(callback) == "function" then 
            callback( key )
        end

    end
end

-- We only trace the mouse move when the cursor is down
-- Because in touch situations it's impossible to move your
-- touch while not having the touch down
local traceMouseMove = false

-- "Constructor" for this "Class"
function input.init( debug ) 

    _debug = debug

    if MOAIInputMgr.device.keyboard then

        MOAIInputMgr.device.keyboard:setCallback( 

            function(key, down)

                if down then
                    onKey( "down" , key )
                else 
                    onKey( "up" , key )
                end

            end
        )

    end
  
    -- Mouse was discovered
    if MOAIInputMgr.device.pointer then
        
        -- Generate a fake finger id for the mouse
        fakeID_01 = MOAIEnvironment:generateGUID()
        fakeID_02 = MOAIEnvironment:generateGUID()
        
        MOAIInputMgr.device.pointer:setCallback(
          
            function( x , y )
              
                if( traceMouseMove ) then
                    onTouch( "move", fakeID_01 , x , y , 1 )
                end
              
            end
        )
        
        MOAIInputMgr.device.mouseLeft:setCallback(
  
            function(isMouseDown)
              
                -- Get the location
                posX, posY = MOAIInputMgr.device.pointer:getLoc()
            
                if(isMouseDown) then
                    -- Simulate a touch by generating a fake id and set the tapcount to one (because
                    -- we assume you don't use two mice ... mouses... input things... )
                    onTouch( "down" , fakeID_01 , posX , posY , 1 )
                    traceMouseMove = true
                else 
                    -- The same for up
                    onTouch( "up" , fakeID_01 , posX , posY , 0 )
                    traceMouseMove = false
                end
            
            end
        )
        
    -- Touch was discovered
    else

        -- We hebben een touch
        MOAIInputMgr.device.touch:setCallback(

            -- idx for multitouch (ID per finger)
            function( eventType , idx , x , y , tapCount )

                event = nil 
                -- Set the type of touch
                if eventType == MOAITouchSensor.TOUCH_DOWN then 
                    _currentTouchCount = _currentTouchCount + 1
                    event = "down" 
                elseif eventType == MOAITouchSensor.TOUCH_UP or eventType == MOAITouchSensor.TOUCH_CANCEL then 
                    if _currentTouchCount > 0 then _currentTouchCount = _currentTouchCount - 1 end
                    event = "up"
                elseif eventType == MOAITouchSensor.TOUCH_MOVE then 
                    event = "move" 
                end

                if event ~= nil and _currentTouchCount <= 4 then onTouch( event , idx , x , y , tapCount ) 
                -- Remove all touches if more than 4 fingers, bcause moai get's really buggy after 4 fingers...
                elseif _currentTouchCount > 4 then 
                    for i = 0, 4, 1 do
                        onTouch( "up" , i , 0 , 0 , 0 ) 
                    end
                    _currentTouchCount = 0
                end

            end
          
        )
    end
  
end

function input.clear(  )

    _propLayers = {}

    _callbacks = {
        
        touch = {
            down = {},
            up = {},
            move = {}
        },
        key = {
            down = {},
            up = {}
        }
    }

end

function input.onTouchDown( callback )

    table.insert( _callbacks.touch.down , callback )

end

function input.onTouchUp( callback )

    table.insert( _callbacks.touch.up , callback )

end

function input.onTouchMove( callback )

    table.insert( _callbacks.touch.move , callback )

end

function input.onKeyDown( callback )

    table.insert( _callbacks.key.down , callback )

end

function input.onKeyUp( callback )
  
    table.insert( _callbacks.key.up , callback )

end

return input