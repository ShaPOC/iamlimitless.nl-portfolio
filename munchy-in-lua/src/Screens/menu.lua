---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- Instantiate the table as a prepration to return a "class"
local menu_screen = {}
menu_screen.__index = menu_screen

---[[
-- Set the layers for this screen
--]]
menu_screen.layerNames = {
    "Background" ,
    "UI"
}

-- Vector2 is used here
require( "System/Foundation/datatypes" )
-- Get the resource class
local resource = require( "System/resource" )
-- Get the UI used (buttons and stuff)
menu_screen.ui = dofile( _G.ROOT .. "Screens/UI/menu.lua" )

-- Size
local _logoSize = Vector2.new( 1050 , 266 )

-- The props as used by this screen
local _backgroundProp = nil
local _logoProp = nil

-- Destroying
local _destroying = false

-- The action
local _scaleUpAction  = nil
local _scaleDownAction  = nil

function scaleDown()

    if not _destroying then
        if type(_scaleUpAction) == "userdata" then
            _scaleUpAction:stop()
            _scaleUpAction = nil
        end
        _scaleDownAction = _logoProp:moveScl ( -0.2 , -0.2 , 4 , MOAIEaseType.SOFT_SMOOTH )
        _scaleDownAction:setListener ( MOAIAction.EVENT_STOP , scaleUp )
        _scaleDownAction:start()
    end

end

function scaleUp()
  
    if not _destroying then
        if type(_scaleDownAction) == "userdata" then
            _scaleDownAction:stop()
            _scaleDownAction = nil
        end
        _scaleUpAction = _logoProp:moveScl ( 0.2 , 0.2 , 4 , MOAIEaseType.SOFT_SMOOTH )
        _scaleUpAction:setListener ( MOAIAction.EVENT_STOP , scaleDown )
        _scaleUpAction:start()
    end

end

---[[
-- The preload screen method gets called by the preload
-- "class" before returning it to the screen manager
--]]
function menu_screen.preload(  )

    -- Add every object to the correct table
--    return resource.preload( { 
--        "Resources/Images/background-sq.png",
--        "Resources/UI/button_settings.png",
--        "Resources/UI/button_highscores.png"
--    } )

end

---[[
-- The start method is called every time the screen is
-- set to be visible
--]]
function menu_screen.start(  )
  
    menu_screen.backgroundLayer = menu_screen.getLayer( "Background" )
    menu_screen.UI = menu_screen.getLayer( "UI" )

    local backgroundDeck = MOAIGfxQuad2D.new()
    backgroundDeck:setTexture( resource.get( "Resources/Images/background-sq.png" ) )

    -- Always calculated from the center
    backgroundDeck:setRect(screen.GAME_WIDTH / -2, screen.GAME_HEIGHT / -2, screen.GAME_WIDTH / 2, screen.GAME_HEIGHT / 2)

    _backgroundProp = MOAIProp2D.new()
    _backgroundProp:setDeck( backgroundDeck )

    menu_screen.backgroundLayer:insertProp( _backgroundProp )
    
    local logoDeck = MOAIGfxQuad2D.new()
    logoDeck:setTexture( resource.get( "Resources/UI/logo.png" ) )

    -- Always calculated from the center
    logoDeck:setRect( _logoSize.x / -2 , _logoSize.y / -2 , _logoSize.x / 2 , _logoSize.y / 2 )
    
    _logoProp = MOAIProp2D.new()
    _logoProp:setLoc( menu_screen.backgroundLayer:wndToWorld( screen.relative( { top = "20%" , left = "50%" } , true ) ) )
    _logoProp:setDeck( logoDeck )
    
    menu_screen.backgroundLayer:insertProp( _logoProp )

    -- Set the touch layer containing props that may be touched and should react when touched
    input.setPropLayer( "UI" , menu_screen.UI )
    -- Initialize the ui
    menu_screen.ui.init( menu_screen.UI , screen , device )
    
    -- And initalize the input
    input.init( screen.config.debug )
    
    -- Action
    scaleUp()
    
    -- Play the music!
    screen.sound.playMusic( "mainmenu" )

end

function menu_screen.update()

    if type(_scaleUpAction) == "userdata" and _scaleUpAction:isDone() then scaleDown() end
    if type(_scaleDownAction) == "userdata" and _scaleDownAction:isDone() then scaleUp() end

end

function menu_screen.destroy( )

    -- We stop some things during the destroy sequence
    _destroying = true

    -- Clear all inputs
    input.clear()
    -- Destroy the UI
    menu_screen.ui.destroy()
    -- Destory the background
    menu_screen.UI:removeProp( _backgroundProp )
    _backgroundProp:setDeck( nil )
    
    -- Scale up
    if type(_scaleUpAction) == "userdata" then 
        _scaleUpAction:stop()
        _scaleUpAction  = nil
    end
    -- Scale down
    if type(_scaleDownAction) == "userdata" then 
        _scaleDownAction:stop()
        _scaleDownAction  = nil
    end
    
    -- We are done!
    _destroying = false

end

return menu_screen