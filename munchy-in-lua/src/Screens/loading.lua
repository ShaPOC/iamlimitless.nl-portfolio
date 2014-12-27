---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- Instantiate the table as a prepration to return a "class"
local loading_screen = {}
loading_screen.__index = loading_screen

---[[
-- Set the layers for this screen
--]]
loading_screen.layerNames = {
    "PreloadLayer" ,
    "Background"
}

-- Vector2 is used here
require( "System/Foundation/datatypes" )
-- Get the resource class
local resource = require( "System/resource" )

-- The props as used by this screen
local _backgroundProp = nil
local _loaderProp = nil
local _loaderInnerProp = nil
local _loaderInnerDeck = nil
-- Size
local _loadingBarSize = Vector2.new( 540 , 41 )
-- The max width for the loader
local _maxBarWidth = 0
-- The current loading bar width
local _currentBarWidth = 0

---[[
-- The preload screen method gets called by the preload
-- "class" before returning it to the screen manager
--]]
function loading_screen.preload(  )

--    -- Add every object to the correct table
--    return resource.preload( { 
--        "Resources/Images/splash-screen.png" 
--    } )

end

---[[
-- The start method is called every time the screen is
-- set to be visible
--]]
function loading_screen.start(  )
  
    loading_screen.backgroundLayer = loading_screen.getLayer( "Background" )

    local backgroundDeck = MOAIGfxQuad2D.new()
    backgroundDeck:setTexture( resource.get( "Resources/Images/splash-screen.png" ) )

    -- Always calculated from the center
    backgroundDeck:setRect(screen.GAME_WIDTH / -2, screen.GAME_HEIGHT / -2, screen.GAME_WIDTH / 2, screen.GAME_HEIGHT / 2)

    _backgroundProp = MOAIProp2D.new()
    _backgroundProp:setDeck( backgroundDeck )

    loading_screen.backgroundLayer:insertProp( _backgroundProp )
    
    local loaderDeck = MOAIGfxQuad2D.new()
    loaderDeck:setTexture( resource.get( "Resources/UI/loading_outer.png" ) )

    -- Always calculated from the center
    loaderDeck:setRect( _loadingBarSize.x / -2 , _loadingBarSize.y / -2 , _loadingBarSize.x / 2 , _loadingBarSize.y / 2 )
    
    _loaderProp = MOAIProp2D.new()
    _loaderProp:setLoc( loading_screen.backgroundLayer:wndToWorld( screen.relative( { bottom = "25%" , left = "50%" } , true ) ) )
    _loaderProp:setDeck( loaderDeck )
    
    loading_screen.backgroundLayer:insertProp( _loaderProp )
    
    local loaderBar = resource.get( "Resources/UI/loading_inner.png" )
    loaderBar:setWrap( true )
    
    _loaderInnerDeck = MOAIGfxQuad2D.new()
    _loaderInnerDeck:setTexture( loaderBar )
    _loaderInnerDeck:setUVRect( 0.00195312 , 0.03125 , 0.519531 , 0.5 )

    -- Set the max and the current width of the loader bar
    _maxBarWidth = _loadingBarSize.x * 0.98
    _currentBarWidth = 0

    -- Always calculated from the center
    _loaderInnerDeck:setRect( 0 , 0 , 0 , _loadingBarSize.y * 0.70 )
    
    _loaderInnerProp = MOAIProp2D.new()
    _loaderInnerProp:setLoc( _loadingBarSize.x / -2 + 5 , _loadingBarSize.y / -2 + 7 )
    _loaderInnerProp:setDeck( _loaderInnerDeck )
    
    _loaderInnerProp:setParent( _loaderProp )
    
    loading_screen.backgroundLayer:insertProp( _loaderInnerProp )

end

function loading_screen.setPercentage( per )
  
    _currentBarWidth = ( _maxBarWidth / 100 ) * per
    _loaderInnerDeck:setRect( 0 , 0 , _currentBarWidth , _loadingBarSize.y * 0.70 )
  
end

function loading_screen.getPercentage( )

    return tonumber( ( _currentBarWidth / _maxBarWidth ) * 100 )

end

function loading_screen.destroy( )

    _backgroundProp:setDeck( nil )
    _backgroundProp = nil
    
    _loaderProp:setDeck( nil )
    _loaderProp = nil
    
    _loaderInnerProp = nil
    _loaderInnerDeck = nil
    
    _maxBarWidth = 0
    _currentBarWidth = 0

end

return loading_screen