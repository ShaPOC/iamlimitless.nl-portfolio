--[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local screen = {}
screen.__index = screen

-- Some methods inside this 'class' return a Vector2 position
-- So we need our own made Vector2 datatype 'class'
require "System/Foundation/datatypes"

-- The maximum screen width and height
screen.GAME_WIDTH = 2048
screen.GAME_HEIGHT = 1536
-- The actual device width and height
screen.DEVICE_WIDTH = 0
screen.DEVICE_HEIGHT = 0
-- The screen width and height to be used
screen.SCREEN_WIDTH = 0
screen.SCREEN_HEIGHT = 0
-- The offset to be used
screen.SCREEN_OFFSET_X = 0
screen.SCREEN_OFFSET_Y = 0

local function getOptimalScreenSize( config ) 
  
    -- We get either the resolution of the device, or the settings in the config 
    -- which occurs when testing it on a laptop or desktop instead of a mobile device
    screen.DEVICE_WIDTH = MOAIEnvironment.verticalResolution or config.defaultScreenSize.width
    screen.DEVICE_HEIGHT = MOAIEnvironment.horizontalResolution or config.defaultScreenSize.height

    -- Wrong Android shizzle fix
    if (screen.DEVICE_WIDTH < screen.DEVICE_HEIGHT) then
        screen.DEVICE_WIDTH, screen.DEVICE_HEIGHT = screen.DEVICE_HEIGHT, screen.DEVICE_WIDTH
    end

    local gameAspect = screen.GAME_WIDTH / screen.GAME_HEIGHT
    local realAspect = screen.DEVICE_WIDTH / screen.DEVICE_HEIGHT

    if realAspect == gameAspect then
        screen.SCREEN_WIDTH = screen.DEVICE_WIDTH
        screen.SCREEN_HEIGHT = screen.DEVICE_HEIGHT
    elseif ( realAspect - gameAspect ) < 0.2 then
        screen.SCREEN_WIDTH = screen.DEVICE_WIDTH * ( gameAspect - 0.2 )
        screen.SCREEN_HEIGHT = screen.DEVICE_HEIGHT * gameAspect
    elseif realAspect > gameAspect then        
        screen.SCREEN_WIDTH = screen.DEVICE_WIDTH
        screen.SCREEN_HEIGHT = screen.DEVICE_HEIGHT * gameAspect
    else
        screen.SCREEN_WIDTH = screen.DEVICE_WIDTH * gameAspect
        screen.SCREEN_HEIGHT = screen.DEVICE_HEIGHT
    end
    
    -- The offsets are always used!
    screen.SCREEN_OFFSET_Y = (screen.SCREEN_HEIGHT - screen.DEVICE_HEIGHT) / -2 
    screen.SCREEN_OFFSET_X = (screen.SCREEN_WIDTH - screen.DEVICE_WIDTH) / -2 
    
end

-- "Constructor" function
function screen.init( config )

    -- Create the table for the containment of available screens
    screen.available = {}
    -- Currently active
    screen.active = nil
    -- We use the method above (getOptimalScreenSize) to get the optimal size and to
    -- fill the public variables at the top of this 'class'
    getOptimalScreenSize( config )
    -- And insert it into the simulator
    MOAISim.openWindow ( config.gameName , screen.DEVICE_WIDTH, screen.DEVICE_HEIGHT )
    
    -- We save the config inside the screen as well
    screen.config = config
    
    -- ViewPort
    screen.viewport = MOAIViewport.new()
    screen.viewport:setSize( screen.SCREEN_OFFSET_X , screen.SCREEN_OFFSET_Y , screen.SCREEN_OFFSET_X + screen.SCREEN_WIDTH , screen.SCREEN_OFFSET_Y + screen.SCREEN_HEIGHT )
    screen.viewport:setScale( screen.GAME_WIDTH, screen.GAME_HEIGHT )

    -- The thread used for the update
    screen.gameThread = MOAICoroutine.new()

    MOAIGfxDevice.getFrameBuffer():setClearColor( 0 , 0 , 0 , 1 )
  
end

-- This method gives back a percentage of the screen if asked for a 
-- percentage and returns just pixels if asked for just pixels
-- Only used by the screen.relative function
local function getPixelsFromPercentage( pos , hor )
  
    if string.find( pos , "%%" ) ~= nil then
        pos = pos:gsub("%%", "")
        return ( tonumber( pos ) / 100 ) * ( hor and screen.DEVICE_WIDTH or screen.DEVICE_HEIGHT )
    end
  
    return tonumber( pos / ( hor and ( screen.GAME_WIDTH / screen.DEVICE_WIDTH ) or ( screen.GAME_HEIGHT / screen.DEVICE_HEIGHT ) ) )
  
end

--[[
-- Calculate a relative position on the screen

-- This method is primarily used inside screens themselves to position
-- certain elements. Insert a table containing positions in the 
-- following fashion;
-- {
--    top = 40
--    left = 50%
--    bottom = 0 -- optional
--    right = 0 -- optional
--    anchor = 'center' -- optional (default = 'topLeft')
-- }
-- At least one horizontal and one vertical position is required
-- The last parameter specifies if either a table or loos x and y are returned
--]]
function screen.relative( positionTable , loose )

    -- Set the inital values, when a user inserts a wrong
    -- table, then 0 and 0 is returned
    x = 0 
    y = 0
    -- And the default anchor
    anchor = positionTable['anchor'] or "topLeft"

    -- Only iterate when it's a table, there's no use otherwise
    if type(positionTable == "table") then
        -- Iterate through
        for key , value in pairs( positionTable ) do

            if key ~= "anchor" then

                -- First we find out if it's a percentage and if so return
                -- that percentage in pixels
                pos = getPixelsFromPercentage ( value , ( key == "left" or key == "right" ) )

                -- And check which key is used
                if key == "left" then
                    x = pos
                elseif key == "top" then
                    y = pos
                elseif key == "right" then
                    x = screen.DEVICE_WIDTH - pos
                elseif key == "bottom" then
                    y = screen.DEVICE_HEIGHT - pos
                end
            end
        end
    end
    -- Finally return the vector2 containing the values calculated
    if loose then return x , y
    else return Vector2.new( x , y ) end
end

--[[
-- Screen Size to Game Size converter
-- wndToWorld will not calculate the pixwel coordinates correctly due to the scale we
-- are using. This method fixes that
--]]
function screen.deviceToScaled( vector )

    return Vector2.new( 
        vector.x * ( screen.GAME_WIDTH / screen.DEVICE_WIDTH ) , 
        vector.y * ( screen.GAME_HEIGHT / screen.DEVICE_HEIGHT ) 
    )

end

--[[
-- Screen Size to Game Size converter
-- worldTpWnd will not calculate the pixwel coordinates correctly due to the scale we
-- are using. This method fixes that
--]]
function screen.scaledToDevice( vector )

    return Vector2.new( 
        vector.x / ( screen.GAME_WIDTH / screen.DEVICE_WIDTH ) , 
        vector.y / ( screen.GAME_HEIGHT / screen.DEVICE_HEIGHT ) 
    )

end

--[[
-- Add screen method
-- This method expects an array with screen data in the following fashion
-- { 
--    id = { 
--        filename = "Screens/game", 
--        object = < the module game itself > 
--    }
-- }
--]]
function screen.set( screen_array )

    for key, value in pairs( screen_array ) do

        if value.object.layerNames then
            -- We create an empty table to replace the layer table
            layers = {}
            -- Count the layer depth like this
            depthCounter = 1
            -- And now we create the actual layers!
            for layerName, layer in pairs(value.object.layerNames) do
                table.insert(layers, depthCounter, MOAILayer2D.new())
                -- And set them to the main viewport
                layers[ depthCounter ]:setViewport(  screen.viewport )
            end
            -- Set the new layers containing actual layers
            value.object.layers = layers
            -- Set the getLayer method
            value.object.getLayer = function ( layerName ) 
              return value.object.layers[ getLayer( value.object.layerNames, layerName ) ] 
            end
        end

        -- Now we set the available screen for later calling
        screen.available[ key ] = value
    end
    
end

function getLayer( layerNames, layerName ) 
  
    -- Loop through until the layer name matches the layer name in layernames
    for index, layer in pairs(layerNames) do
        if layer == layerName then return index end
    end

    -- When it never matches...
    return nil
  
end

-- Pause the currently active screen
function screen.pause( )
    
    screen.gameThread:pause()
    if type( screen.available[ screen.active ].object.pause ) == "function" then
        screen.available[ screen.active ].object.pause()
    end
  
end

-- Resume the currently active screen
function screen.resume( )
    
    screen.gameThread:start()
    if type( screen.available[ screen.active ].object.resume ) == "function" then
        screen.available[ screen.active ].object.resume()
    end
  
end

-- Set an active screen
function screen.activate( id )

    if screen.available[ id ] and screen.available[ id ].object.layers then
    
        -- The currently active screen should be disabled and destroyed
        if screen.active ~= 0 
            and screen.available[ screen.active ] ~= nil 
            and type( screen.available[ screen.active ].object.destroy ) == "function" then 
            screen.available[ screen.active ].object.destroy()
        end
    
        -- Now we trigger the start method
        if screen.available[ id ].object.start then 
            screen.available[ id ].object.start()
        end
    
        -- Set the render table according to the layers inside
        MOAIRenderMgr.setRenderTable( screen.available[ id ].object.layers )
        
        -- Run the new thread with the update method
        if screen.available[ id ].object.update then
            screen.gameThread:run ( screen.available[ id ].object.update )
        end
        
        -- Set the active ID
        screen.active = id;
    
    end
  
    -- We return the activated screen
    return screen.available[ id ].object

end

return screen