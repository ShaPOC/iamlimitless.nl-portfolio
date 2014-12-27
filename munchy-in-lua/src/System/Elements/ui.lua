---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local ui = {}
-- This class is abstract and may not be initialized on it's own!
--ui.__index = ui

setmetatable(ui, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

local _layer
local _font 

local resource = require "System/resource"

-- Public elements (we want to use it inside our daughter classes)
ui._elements = {}

-- "Constructor" for this "Class"
function ui.init( layer ) 
    
    -- Add the needed classes
    _layer = layer
    _font = resource.get( "Resources/Fonts/MunchyFont.otf" )
  
end

function ui.addElement( name , image , size , position , callback )
  
    local quad = MOAIGfxQuad2D.new()
    quad:setTexture( image )
    quad:setRect( size.x / -2 , size.y / -2 , size.x / 2 , size.y / 2 )
    
    local prop = MOAIProp2D.new()
    prop:setDeck( quad )
    prop:setLoc( position.x , position.y )

    -- We keep track if the button is pressed or not
    prop.down = false
    -- And we always want an ID for reference!
    prop.id = MOAIEnvironment:generateGUID()

    if type( callback ) == "function" then
        prop.onTouch = function( touchType , idx , x , y , tapCount ) 

            -- Make sure any animation stops!
            if prop.anim then prop.anim:stop() end

            if touchType ~= "up" or prop.down then
                callback( touchType , idx , x , y , tapCount )
            end

            if ( prop.disabled == nil or not prop.disabled ) and touchType == "down" then 
                prop.anim = prop:moveScl( 1 - prop:getScl() -0.25 , 1 - prop:getScl() -0.25 , 0.4 , MOAIEaseType.EASE_IN )
                prop.down = true
            elseif ( prop.disabled == nil or not prop.disabled ) and ( touchType == "up" or touchType == "cancel" ) then 
                prop.anim = prop:moveScl( 1 - prop:getScl() , 1 - prop:getScl() , 0.4 , MOAIEaseType.EASE_IN )
                prop.down = false
            end
        end
    end

    -- Save the prop
    ui._elements[ name ] = prop
    
    return prop

end

function ui.addSwitch( name , offImage , onImage , size , position , currentState , callback )
  
    local offQuad = MOAIGfxQuad2D.new()
    offQuad:setTexture( offImage )
    offQuad:setRect( size.x / -2 , size.y / -2 , size.x / 2 , size.y / 2 )
    
    local offProp = MOAIProp2D.new()
    offProp:setDeck( offQuad )
    offProp:setLoc( position.x , position.y )
    
    -- And we always want an ID for reference!
    offProp.id = MOAIEnvironment:generateGUID()
    
    local onQuad = MOAIGfxQuad2D.new()
    onQuad:setTexture( onImage )
    onQuad:setRect( size.x / -2 , size.y / -2 , size.x / 2 , size.y / 2 )
    
    local onProp = MOAIProp2D.new()
    onProp:setDeck( onQuad )
    onProp:setLoc( position.x , position.y )

    -- And we always want an ID for reference!
    onProp.id = MOAIEnvironment:generateGUID()

    -- Save the prop
    ui._elements[ name ] = {
        state = currentState ,
        switching = false ,
        on = onProp ,
        off = offProp
    }
    
    ui._elements[ name ][ ( ui._elements[ name ][ "state" ] and "off" or "on" ) ]:setColor( 0 , 0 , 0 , 0 )
    ui._elements[ name ][ ( ui._elements[ name ][ "state" ] and "off" or "on" ) ]:setScl( 0.8 , 0.8 )

    local theOnTouch = function( touchType , idx , x , y , tapCount ) 

        if touchType == "up" and not ui._elements[ name ][ "switching" ] then

            ui._elements[ name ][ "switching" ] = true

            -- Switch the two props!
            ui.showAnimation( ui._elements[ name ][ ( ui._elements[ name ][ "state" ] and "off" or "on" ) ] )
            ui.hideAnimation( ui._elements[ name ][ ( ui._elements[ name ][ "state" ] and "on" or "off" ) ] , 
                function(  )
                    ui._elements[ name ][ "state" ] = ( ui._elements[ name ][ "state" ] == false and true or false )
                    ui._elements[ name ][ "switching" ] = false
                end )
              
            callback( touchType , idx , x , y , tapCount )
        end
    end

    if type( callback ) == "function" then
        offProp.onTouch = theOnTouch
        onProp.onTouch = theOnTouch
    end
    
    return ui._elements[ name ]

end

function ui.removeElement( name )
  
    if type( ui._elements[ name ] ) == "table" then
        for x , p in pairs( ui._elements[ name ] ) do
            if type( p ) == "userdata" then 
                _layer:removeProp( p )
                p:setDeck( nil )
                p = nil
            end
        end
    else
        _layer:removeProp( ui._elements[ name ] )
        ui._elements[ name ]:setDeck( nil )
    end

    ui._elements[ name ] = nil
  
end

function ui.addText( name , fontSize , text , size , position , callback , flip , align , charcodes )

    _font:preloadGlyphs( charcodes or "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!?" , fontSize )

    local fontStyle = MOAITextStyle.new()
    fontStyle:setFont( _font )
    fontStyle:setSize( fontSize )

    local prop = MOAITextBox.new()
    prop:setStyle( fontStyle )
    prop:setString( text )
    prop:setRect( size.x / -2 , size.y / -2 , size.x / 2 , size.y / 2 )
    prop:setLoc( position.x , position.y )
    prop:setYFlip( flip or true )
    prop:setAlignment( align or MOAITextBox.CENTER_JUSTIFY , align or MOAITextBox.CENTER_JUSTIFY )

    -- And we always want an ID for reference!
    prop.id = MOAIEnvironment:generateGUID()

    if type( callback ) == "function" then
        prop.onTouch = function( touchType , idx , x , y , tapCount ) 
            callback( touchType , idx , x , y , tapCount )
        end
    end

    ui._elements[ name ] = prop

    return prop

end

function ui.hideAnimation( prop , callback )
  
    -- Animations moving and scaling the object
    local scaleAnimation = prop:moveScl( -0.2 , -0.2 , 0.2 , MOAIEaseType.EASE_IN )
    local fadeAnimation = prop:seekColor( 0 , 0 , 0 , 0 , 0.2 , MOAIEaseType.EASE_IN )

    local hide = MOAIAction.new()
    hide:addChild( scaleAnimation )
    hide:addChild( fadeAnimation )
    hide:start()

    if type( callback ) == "function" then
         -- And callback when it's done
        hide:setListener( MOAIAction.EVENT_STOP , callback )
    end
  
end

function ui.showAnimation( prop , callback )
  
    prop:setColor( 0 , 0 , 0 , 0 )
    prop:setScl( 0.8 , 0.8 )
  
    -- Animations moving and scaling the object
    local scaleAnimation = prop:moveScl( 0.26 , 0.26 , 0.12 , MOAIEaseType.EASE_IN )
    local fadeAnimation = prop:seekColor( 1 , 1 , 1 , 1 , 0.12 , MOAIEaseType.EASE_IN )

    local show = MOAIAction.new()
    show:addChild( scaleAnimation )
    show:addChild( fadeAnimation )
    show:start()
    
    animCompleteCheck = nil
    show:setListener( MOAIAction.EVENT_STOP , function() 
        animCompleteCheck = prop:moveScl( -0.06 , -0.06 , 0.08 , MOAIEaseType.EASE_OUT ) 
            if type( callback ) == "function" then
                 -- And callback when it's done
                animCompleteCheck:setListener( MOAIAction.EVENT_STOP , callback )
            end
        end )
  
end

function ui.destroy()

    for name , element in pairs( ui._elements ) do
         ui.removeElement( name ) 
    end

end

return ui