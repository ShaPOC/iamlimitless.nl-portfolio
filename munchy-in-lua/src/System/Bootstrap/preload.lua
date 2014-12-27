---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- Instantiate the table as a prepration to return a "class"
local preload = {}
preload.__index = preload

-- The preloaders screen and the boolean triggering it
local _screen = nil
local _loading = false

---[[
-- The preload screen method actually preloads screens! Shocker...
-- It does so by invoking the preload method inside these classes
-- Afterwards the screens are returned to the manager for static
-- access
--]]
function preload.screen( inserts , callback , secondCallback )

    local thread = MOAICoroutine.new ()
    local returnValue = {}

    thread:run( function()
        -- We loop through them to (if needed) execute the preload method
        for key , value in pairs( inserts ) do
            
            coroutine:yield ()
            returnValue[ value.id ] = {
            
                filename = value.filename,
                -- Require the file
                object = require( value.filename )
            
            }
          
            if _loading and _screen ~= nil and type( _screen.setPercentage ) == "function" and type( _screen.getPercentage ) == "function" then 
                _screen.setPercentage( _screen.getPercentage() + 20 )
            end
        
            coroutine:yield ()
            -- If the file has a preload method, execute it now!
            if returnValue[ value.id ].object.preload then 
                returnValue[ value.id ].object.preload() 
            end
            
            if _loading and _screen ~= nil and type( _screen.setPercentage ) == "function" and type( _screen.getPercentage ) == "function" then 
                _screen.setPercentage( _screen.getPercentage() + 30 )
            end
        end
        
        if type( callback ) == "function" then
            callback( returnValue )
        end
        
        if type( secondCallback ) == "function" then
            secondCallback( )
        end
    end)

end

---[[
-- When finsihed we will start the callback function for displaying a 
-- screen and the second parameter is what we insert into the first parameter
--]]
function preload.set( screen , onLoad )
 
    -- Insert the screen for preloading 
    _screen = screen
    -- And set loading to true so the preload.screen method knows it needs
    -- to update stuff
    _loading = true

    local thread = MOAICoroutine.new ()
    thread:run( function()
        
        -- We use yields in a thread to make sure everything is loading
        -- whilst showing the loading screen
        coroutine:yield ()
        onLoad()
        
    end)

end

return preload