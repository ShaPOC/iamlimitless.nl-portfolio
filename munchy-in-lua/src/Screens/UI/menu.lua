---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- 'Mother / Base / Parent' Class
local ui = dofile( _G.ROOT .. "System/Elements/ui.lua" )
local menu_ui = {}

-- Enable inheritance on the object class
setmetatable(menu_ui, {
  __index = ui, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- The locally saved objects
local _screen
local _layer
local _device

-- Language manager
local language = require "System/language" 
-- Resource manager
local resource = require "System/resource"
-- Main menu props
local _mainUI = nil
local _mainUIProps = {}
-- Pause menu props
local _optionsMenu = nil
local _optionsMenuProps = {}
-- Disable buttons during animations
local _buttonsDisabled = false
-- Options shown
local _optionsShown = false
-- UI shown
local _UIShown = false

function menu_ui.showOptions( )

    menu_ui.hideUI()
    _optionsShown = true
    _buttonsDisabled = true

    _optionsMenu = menu_ui.addElement( 
        "options_background" , -- The name
        resource.get( "Resources/UI/options_background.png" ) , -- The image
        Vector2.new( 865 , 730 ) , -- The size
        Vector2.new( _layer:wndToWorld( _screen.relative( { bottom = "35%" , left = "50%" } , true ) ) ) -- The position
    )
    
    _layer:insertProp( _optionsMenu )
    table.insert( _optionsMenuProps , _optionsMenu )
    
    local titleText = menu_ui.addText( 
        "options_title" , -- The name
        62 ,
        string.upper( language.get( "Options" ) ) ,
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 290 )
    )
    titleText:setParent( _optionsMenu )

    _layer:insertProp( titleText )
    table.insert( _optionsMenuProps , titleText )

    local exitButton = menu_ui.addElement( 
        "options_exit" , -- The name
        resource.get( "Resources/UI/button_back.png" ) , -- The image
        Vector2.new( 160 , 168 ) , -- The size
        Vector2.new( -220 , -270 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" and not _buttonsDisabled then 
                menu_ui.hideOptions() menu_ui.showUI() 
                _screen.sound.playSound( "pop-low" )
            end 
        end
    )
    exitButton:setParent( _optionsMenu )

    _layer:insertProp( exitButton )
    table.insert( _optionsMenuProps , exitButton )

    local soundSwitch = menu_ui.addSwitch( 
        "options_sound" , -- The name
        resource.get( "Resources/UI/switch_off.png" ) , -- The off image
        resource.get( "Resources/UI/switch_on.png" ) , -- The on image
        Vector2.new( 98 , 92 ) , -- The size
        Vector2.new( 260 , 145 ) , -- The position
        _screen.userdata.data.sound ,-- The current state
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.userdata.data.sound = ( _screen.userdata.data.sound == false and true or false )
                _screen.sound.soundEnabled = _screen.userdata.data.sound
                _screen.userdata.save()
            end 
        end
    )
    soundSwitch["off"]:setParent( _optionsMenu )
    soundSwitch["on"]:setParent( _optionsMenu )

    _layer:insertProp( soundSwitch["off"] )
    _layer:insertProp( soundSwitch["on"] )
    
    table.insert( _optionsMenuProps , soundSwitch["off"] )
    table.insert( _optionsMenuProps , soundSwitch["on"] )
    
    local soundText = menu_ui.addText( 
        "options_sound_text" , -- The name
        52 ,
        string.upper( language.get( "Enable Sound" ) ) ,
        Vector2.new( 450 , 80 ) ,
        Vector2.new( -60 , 145 ) ,
        nil ,
        true ,
        MOAITextBox.RIGHT_JUSTIFY
    )
    soundText:setParent( _optionsMenu )

    _layer:insertProp( soundText )
    table.insert( _optionsMenuProps , soundText )
    
    local musicSwitch = menu_ui.addSwitch( 
        "options_music" , -- The name
        resource.get( "Resources/UI/switch_off.png" ) , -- The off image
        resource.get( "Resources/UI/switch_on.png" ) , -- The on image
        Vector2.new( 98 , 92 ) , -- The size
        Vector2.new( 260 , 10 ) , -- The position
        _screen.userdata.data.music ,-- The current state
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.userdata.data.music = ( _screen.userdata.data.music == false and true or false )
                _screen.sound.musicEnabled = _screen.userdata.data.music
                if _screen.userdata.data.music == false then _screen.sound.stopMusic() else _screen.sound.resumeMusic() end
                _screen.userdata.save()
            end 
        end
    )
    musicSwitch["off"]:setParent( _optionsMenu )
    musicSwitch["on"]:setParent( _optionsMenu )

    _layer:insertProp( musicSwitch["off"] )
    _layer:insertProp( musicSwitch["on"] )
    
    table.insert( _optionsMenuProps , musicSwitch["off"] )
    table.insert( _optionsMenuProps , musicSwitch["on"] )
    
    local musicText = menu_ui.addText( 
        "options_music_text" , -- The name
        52 ,
        string.upper( language.get( "Enable Music" ) ) ,
        Vector2.new( 450 , 80 ) ,
        Vector2.new( -60 , 10 ) ,
        nil ,
        true ,
        MOAITextBox.RIGHT_JUSTIFY
    )
    musicText:setParent( _optionsMenu )

    _layer:insertProp( musicText )
    table.insert( _optionsMenuProps , musicText )

    local reverseSwitch = menu_ui.addSwitch( 
        "options_reverse" , -- The name
        resource.get( "Resources/UI/switch_off.png" ) , -- The off image
        resource.get( "Resources/UI/switch_on.png" ) , -- The on image
        Vector2.new( 98 , 92 ) , -- The size
        Vector2.new( 260 , -125 ) , -- The position
        _screen.userdata.data.reverse ,-- The current state
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.userdata.data.reverse = ( _screen.userdata.data.reverse == false and true or false )
                _screen.userdata.save()
            end 
        end
    )
    reverseSwitch["off"]:setParent( _optionsMenu )
    reverseSwitch["on"]:setParent( _optionsMenu )

    _layer:insertProp( reverseSwitch["off"] )
    _layer:insertProp( reverseSwitch["on"] )
    
    table.insert( _optionsMenuProps , reverseSwitch["off"] )
    table.insert( _optionsMenuProps , reverseSwitch["on"] )
    
    local reverseText = menu_ui.addText( 
        "options_reverse_text" , -- The name
        52 ,
        string.upper( language.get( "Reverse Controls" ) ) ,
        Vector2.new( 450 , 80 ) ,
        Vector2.new( -60 , -125 ) ,
        nil ,
        true ,
        MOAITextBox.RIGHT_JUSTIFY
    )
    reverseText:setParent( _optionsMenu )

    _layer:insertProp( reverseText )
    table.insert( _optionsMenuProps , reverseText )

    menu_ui.showAnimation( _optionsMenu , function() _buttonsDisabled = false end )
    
end

function menu_ui.hideOptions()

    menu_ui.hideAnimation( _optionsMenu , 
        function() 
            for x , prop in pairs( _optionsMenuProps ) do
                _layer:removeProp( prop )
                _optionsMenuProps[ x ] = nil
            end
            _optionsShown = false
        end 
    )

end

function menu_ui.showUI( )
  
    _UIShown = true
    _buttonsDisabled = true

    _mainUI = menu_ui.addElement( 
        "main_background" , -- The name
        resource.get( "Resources/UI/menu_background.png" ) , -- The image
        Vector2.new( 680 , 657 ) , -- The size
        Vector2.new( _layer:wndToWorld( _screen.relative( { bottom = "35%" , left = "50%" } , true ) ) ) -- The position
    )

    _layer:insertProp( _mainUI )
    table.insert( _mainUIProps , _mainUI )
  
    local playButton = menu_ui.addElement( 
        "menu_play_button" , -- The name
        resource.get( "Resources/UI/button_green.png" ) , -- The image
        Vector2.new( 490 , 224 ) , -- The size
        Vector2.new( 0 , 150 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.sound.playSound( "pop-high" )
                _screen.activate( "game" )
            end 
        end
    )
    playButton:setParent( _mainUI )

    _layer:insertProp( playButton )
    table.insert( _mainUIProps , playButton )

    local playButtonText = menu_ui.addText( 
        "menu_play_button_text" , -- The name
        72 ,
        string.upper( language.get( "Play" ) ),
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 0 )
    )
    playButtonText:setParent( playButton )

    _layer:insertProp( playButtonText )
    table.insert( _mainUIProps , playButtonText )
    
    local optionsButton = menu_ui.addElement( 
        "menu_options_button" , -- The name
        resource.get( "Resources/UI/button_settings.png" ) , -- The image
        Vector2.new( 230 , 242 ) , -- The size
        Vector2.new( -135 , -120 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if not _buttonsDisabled and touchType == "up" then 
                menu_ui.showOptions()
                _screen.sound.playSound( "pop-high" )
            end 
        end
    )
    optionsButton:setParent( _mainUI )

    _layer:insertProp( optionsButton )
    table.insert( _mainUIProps , optionsButton )
    
    local highscoreButton = menu_ui.addElement( 
        "menu_options_button" , -- The name
        resource.get( "Resources/UI/button_highscores.png" ) , -- The image
        Vector2.new( 230 , 242 ) , -- The size
        Vector2.new( 135 , -120 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.sound.playSound( "pop-high" )
                _device.showLeaderboard()
            end 
        end
    )
    highscoreButton:setParent( _mainUI )

    _layer:insertProp( highscoreButton )
    table.insert( _mainUIProps , highscoreButton )
    
    menu_ui.showAnimation( _mainUI , function() _buttonsDisabled = false end )

end

function menu_ui.hideUI( )

    menu_ui.hideAnimation( _mainUI , 
        function() 
            for x , prop in pairs( _mainUIProps ) do
                _layer:removeProp( prop )
                _mainUIProps[ x ] = nil
            end
            _UIShown = false
        end 
    )

end

function menu_ui.init( layer , screen , device )

    --Add the layer for later use
    _layer = layer
    -- And the screen
    _screen = screen
    -- And the device
    _device = device
    
    -- And initialize the rest of the ui
    ui.init( layer , screen )

    -- Add the UI
    menu_ui.showUI()

end

return menu_ui