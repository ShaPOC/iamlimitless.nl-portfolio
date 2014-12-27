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
local game_ui = {}

-- Enable inheritance on the object class
setmetatable(game_ui, {
  __index = ui, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})
-- Language manager
local language = require "System/language" 
-- Resource manager
local resource = require "System/resource"
-- Score
local _score = 0
-- Time
local _time = 0
-- The layer
local _layer = nil
-- The screen
local _screen = nil
-- The world
local _world = nil
-- Paused
local _paused = false
-- Options shown
local _optionsShown = false
-- Options shown
local _menuShown = false
-- Disable button until animation is complete
local _buttonsDisabled = false

-- Game over props
local _gameUIMenu = nil
local _gameUITimeProp = nil
local _gameUIScoreProp = nil
local _gameUIProps = {}
-- Game over props
local _gameOver = nil
local _gameOverProps = {}
-- Pause menu props
local _pauseMenu = nil
local _pauseMenuProps = {}
-- Pause menu props
local _optionsMenu = nil
local _optionsMenuProps = {}

function game_ui.showGameOverScreen(  )
  
    _screen.sound.playSound( "gameover" )
  
    _gameOver = game_ui.addElement( 
        "gameover_background" , -- The name
        resource.get( "Resources/UI/gameover_background.png" ) , -- The image
        Vector2.new( 1511 , 594 ) , -- The size
        Vector2.new( _layer:wndToWorld( _screen.relative( { top = "50%" , left = "50%" } , true ) ) ) -- The position
    )

    _layer:insertProp( _gameOver )
    table.insert( _gameOverProps , _gameOver )

    local titleText = game_ui.addText( 
        "gameover_title" , -- The name
        80 ,
        string.upper( language.get( "Game Over" ) ) ,
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 210 )
    )
    titleText:setParent( _gameOver )

    _layer:insertProp( titleText )
    table.insert( _gameOverProps , titleText )

    local retryButton = game_ui.addElement( 
        "gameover_retry" , -- The name
        resource.get( "Resources/UI/gameover_retry.png" ) , -- The image
        Vector2.new( 191 , 198 ) , -- The size
        Vector2.new( 500 , -290 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.sound.playSound( "pop-high" )
                _screen.activate( "game" ) 
            end 
        end
    )
    retryButton:setParent( _gameOver )
    -- Stop other touch events when touching this button
    retryButton.stopPropagation = true

    _layer:insertProp( retryButton )
    table.insert( _gameOverProps , retryButton )
    
    local exitButton = game_ui.addElement( 
        "gameover_exit" , -- The name
        resource.get( "Resources/UI/gameover_exit.png" ) , -- The image
        Vector2.new( 191 , 198 ) , -- The size
        Vector2.new( -500 , -290 ) , -- The position
        function ( touchType ) 
            if touchType == "up" then 
                 _screen.sound.playSound( "pop-low" )
                _screen.activate( "menu" ) 
            end 
        end
    )
    exitButton:setParent( _gameOver )
    -- Stop other touch events when touching this button
    exitButton.stopPropagation = true

    _layer:insertProp( exitButton )
    table.insert( _gameOverProps , exitButton )

    local highScoresButton = game_ui.addElement( 
        "gameover_highscore" , -- The name
        resource.get( "Resources/UI/gameover_highscore.png" ) , -- The image
        Vector2.new( 655 , 199 ) , -- The size
        Vector2.new( 0 , -290 ) , -- The position
        function ( touchType )
            if touchType == "up" then
                _screen.device.showLeaderboard()
                _screen.sound.playSound( "pop-high" )
            end
        end
    )
    highScoresButton:setParent( _gameOver )
    -- Stop other touch events when touching this button
    highScoresButton.stopPropagation = true
    
    _layer:insertProp( highScoresButton )
    table.insert( _gameOverProps , highScoresButton )
    
    local highScoreText = game_ui.addText( 
        "gameover_highscore_text" , -- The name
        80 ,
        string.upper( language.get( "Highscores" ) ),
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 0 ) 
    )
    highScoreText:setParent( highScoresButton )

    _layer:insertProp( highScoreText )
    table.insert( _gameOverProps , highScoreText )
    
    local gameOverText_01 = game_ui.addText( 
        "gameover_text_01" , -- The name
        40 ,
        string.upper( language.get( "The universe imploded" ) ),
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 186 , 40 )
    )
    gameOverText_01:setParent( _gameOver )
    
    _layer:insertProp( gameOverText_01 )
    table.insert( _gameOverProps , gameOverText_01 )
    
    local gameOverText_02 = game_ui.addText( 
        "gameover_text_02" , -- The name
        40 ,
        string.upper( language.get( "later thanks to you!" ) ),
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 190 , -110 )
    )
    gameOverText_02:setParent( _gameOver )

    _layer:insertProp( gameOverText_02 )
    table.insert( _gameOverProps , gameOverText_02 )
    
    local gameOverTime = game_ui.addText( 
        "gameover_time" , -- The name
        40 ,
        os.date("!%X",_time) ,
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 220 , -30 )
    )
    gameOverTime:setParent( _gameOver )

    _layer:insertProp( gameOverTime )
    table.insert( _gameOverProps , gameOverTime )

    local timeIcon = game_ui.addElement( 
        "gameover_time_icon" , -- The name
        resource.get( "Resources/UI/gameover_time.png" ) , -- The image
        Vector2.new( 73 , 81 ) , -- The size
        Vector2.new( 80 , -30 )
    )
    timeIcon:setParent( _gameOver )

    _layer:insertProp( timeIcon )
    table.insert( _gameOverProps , timeIcon )
    
    game_ui.showAnimation( _gameOver )
  
end

function game_ui.showMenu(  )
  
    _menuShown = true
    _buttonsDisabled = true
  
    _pauseMenu = game_ui.addElement( 
        "pause_background" , -- The name
        resource.get( "Resources/UI/pause_background.png" ) , -- The image
        Vector2.new( 717 , 1000 ) , -- The size
        Vector2.new( _layer:wndToWorld( _screen.relative( { top = "50%" , left = "50%" } , true ) ) ) -- The position
    )
    
    _layer:insertProp( _pauseMenu )
    table.insert( _pauseMenuProps , _pauseMenu )
    
    local titleText = game_ui.addText( 
        "pause_title" , -- The name
        62 ,
        string.upper( language.get( "Paused" ) ) ,
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 430 )
    )
    titleText:setParent( _pauseMenu )

    _layer:insertProp( titleText )
    table.insert( _pauseMenuProps , titleText )

    local resumeButton = game_ui.addElement( 
        "pause_resume_button" , -- The name
        resource.get( "Resources/UI/button_green.png" ) , -- The image
        Vector2.new( 490 , 224 ) , -- The size
        Vector2.new( 0 , 200 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.sound.playSound( "pop-low" )
                _paused = false
                game_ui.hideMenu() 
                _screen.resume() 
            end 
        end
    )
    resumeButton:setParent( _pauseMenu )
    -- Stop other touch events when touching this button
    resumeButton.stopPropagation = true

    _layer:insertProp( resumeButton )
    table.insert( _pauseMenuProps , resumeButton )
    
    local resumeButtonText = game_ui.addText( 
        "pause_resume_button_text" , -- The name
        72 ,
        string.upper( language.get( "Resume" ) ),
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 0 )
    )
    resumeButtonText:setParent( resumeButton )

    _layer:insertProp( resumeButtonText )
    table.insert( _pauseMenuProps , resumeButtonText )
    
    local retryButton = game_ui.addElement( 
        "pause_retry" , -- The name
        resource.get( "Resources/UI/button_retry_large.png" ) , -- The image
        Vector2.new( 190 , 200 ) , -- The size
        Vector2.new( 110 , -300 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" then 
                _screen.sound.playSound( "pop-low" )
                _paused = false
                _screen.activate( "game" ) 
            end 
        end
    )
    retryButton:setParent( _pauseMenu )
    -- Stop other touch events when touching this button
    retryButton.stopPropagation = true

    _layer:insertProp( retryButton )
    table.insert( _pauseMenuProps , retryButton )
    
    local exitButton = game_ui.addElement( 
        "pause_exit" , -- The name
        resource.get( "Resources/UI/button_exit_large.png" ) , -- The image
        Vector2.new( 190 , 200 ) , -- The size
        Vector2.new( -110 , -300 ) , -- The position
        function ( touchType ) 
            if touchType == "up" then 
                _screen.sound.playSound( "pop-low" )
                _screen.activate( "menu" ) 
            end 
        end
    )
    exitButton:setParent( _pauseMenu )
    -- Stop other touch events when touching this button
    exitButton.stopPropagation = true

    _layer:insertProp( exitButton )
    table.insert( _pauseMenuProps , exitButton )
    
    local optionsButton = game_ui.addElement( 
        "pause_options" , -- The name
        resource.get( "Resources/UI/button_blue.png" ) , -- The image
        Vector2.new( 490 , 224 ) , -- The size
        Vector2.new( 0 , -50 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" and not _buttonsDisabled then 
                _screen.sound.playSound( "pop-high" )
                game_ui.showOptions()
            end 
        end
    )
    optionsButton:setParent( _pauseMenu )
    -- Stop other touch events when touching this button
    optionsButton.stopPropagation = true
    
    _layer:insertProp( optionsButton )
    table.insert( _pauseMenuProps , optionsButton )
    
    local optionsButtonText = game_ui.addText( 
        "pause_options_text" , -- The name
        72 ,
        string.upper( language.get( "Options" ) ),
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 0 )
    )
    optionsButtonText:setParent( optionsButton )

    _layer:insertProp( optionsButtonText )
    table.insert( _pauseMenuProps , optionsButtonText )
    
    game_ui.showAnimation( _pauseMenu , function() _buttonsDisabled = false end )
    
end

function game_ui.hideMenu(  )

    if _optionsShown then game_ui.hideOptions() end
    
    game_ui.hideAnimation( _pauseMenu , 
        function() 
            for x , prop in pairs( _pauseMenuProps ) do
                _layer:removeProp( prop )
                _pauseMenuProps[ x ] = nil
            end
        end 
    )
    
    _menuShown = false

end

function game_ui.showOptions( )

    game_ui.hideMenu()
    _optionsShown = true
    _buttonsDisabled = true

    _optionsMenu = game_ui.addElement( 
        "options_background" , -- The name
        resource.get( "Resources/UI/options_background.png" ) , -- The image
        Vector2.new( 865 , 730 ) , -- The size
        Vector2.new( _layer:wndToWorld( _screen.relative( { top = "50%" , left = "50%" } , true ) ) ) -- The position
    )
    
    _layer:insertProp( _optionsMenu )
    table.insert( _optionsMenuProps , _optionsMenu )
    
    local titleText = game_ui.addText( 
        "options_title" , -- The name
        62 ,
        string.upper( language.get( "Options" ) ) ,
        Vector2.new( 460 , 140 ) ,
        Vector2.new( 0 , 290 )
    )
    titleText:setParent( _optionsMenu )

    _layer:insertProp( titleText )
    table.insert( _optionsMenuProps , titleText )

    local exitButton = game_ui.addElement( 
        "options_exit" , -- The name
        resource.get( "Resources/UI/button_back.png" ) , -- The image
        Vector2.new( 160 , 168 ) , -- The size
        Vector2.new( -220 , -270 ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if touchType == "up" and not _buttonsDisabled then 
                _screen.sound.playSound( "pop-low" )
                game_ui.hideOptions() 
            end 
        end
    )
    exitButton:setParent( _optionsMenu )
    -- Stop other touch events when touching this button
    exitButton.stopPropagation = true

    _layer:insertProp( exitButton )
    table.insert( _optionsMenuProps , exitButton )

    local soundSwitch = game_ui.addSwitch( 
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
    
    local soundText = game_ui.addText( 
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
    
    local musicSwitch = game_ui.addSwitch( 
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
    
    local musicText = game_ui.addText( 
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

    local reverseSwitch = game_ui.addSwitch( 
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
    
    local reverseText = game_ui.addText( 
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

    game_ui.showAnimation( _optionsMenu , function() _buttonsDisabled = false end )
    
end

function game_ui.hideOptions( closeNow )

    if not _menuShown and not closeNow then game_ui.showMenu() end

    game_ui.hideAnimation( _optionsMenu , 
        function() 
            for x , prop in pairs( _optionsMenuProps ) do
                _layer:removeProp( prop )
                _optionsMenuProps[ x ] = nil
            end
        end 
    )
    
    _optionsShown = false

end

local _uiBody = nil

local _scoreCollisions = nil
local _scoreFixturePos = nil
local _scoreFixture = nil
local _scoreFadeAnim = nil
local _timeFadeAnim = nil

local _menuCollisions = nil
local _menuFixturePos = nil
local _menuFixture = nil
local _menuFadeAnim = nil

function game_ui.showUI( )
  
    _uiBody = _world:addBody( MOAIBox2DBody.STATIC )
  
    _gameUIScoreProp = game_ui.addElement( 
        "score" , -- The name
        resource.get( "Resources/UI/hud_points.png" ) , -- The image
        Vector2.new( 362 , 124 ) , -- The size
        Vector2.new( _layer:wndToWorld( screen.relative( { top = "150" , left = "227" } , true ) ) ) -- The position
    )

    _layer:insertProp( _gameUIScoreProp )
    table.insert( _gameUIProps , _gameUIScoreProp )

    local scoreText = game_ui.addText( 
        "scoreText" , -- The name
        42 ,
        string.format( "%07d", _score ) ,
        Vector2.new( 200 , 60 ) ,
        Vector2.new( 54 , -8 )
    )
    scoreText:setParent( _gameUIScoreProp )
    
    _layer:insertProp( scoreText )
    table.insert( _gameUIProps , scoreText )
    
    game_ui.showAnimation( _gameUIScoreProp )

    _gameUITimeProp = game_ui.addElement( 
        "time" , -- The name
        resource.get( "Resources/UI/hud_time.png" ) , -- The image
        Vector2.new( 341 , 111 ) , -- The size
        Vector2.new( 12 , -140 ) -- The position
    )
    _gameUITimeProp:setParent( _gameUIScoreProp )

    _layer:insertProp( _gameUITimeProp )
    table.insert( _gameUIProps , _gameUITimeProp )
    
    local timeText = game_ui.addText( 
        "timeText" , -- The name
        42 ,
        os.date("!%X",_time) ,
        Vector2.new( 200 , 60 ) ,
        Vector2.new( 56 , -9 ) ,
        nil ,
        true , 
        MOAITextBox.LEFT_JUSTIFY
    )
    timeText:setParent( _gameUITimeProp )
    
    _layer:insertProp( timeText )
    table.insert( _gameUIProps , timeText )
    
    game_ui.showAnimation( _gameUITimeProp )

    _scoreCollisions = 0
    _scoreFixturePos = Vector2.new( _layer:wndToWorld(  _screen.relative( { top = "180" , left = "220" } , true ) ) )
    _scoreFixture = _uiBody:addCircle( _scoreFixturePos.x , _scoreFixturePos.y , 240 )
    _scoreFixture:setSensor( true )
    
    _scoreFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter ) 
        
        if not fixtureB.watchingOnly or fixtureB.enableUIFade then
            if phase == MOAIBox2DArbiter.BEGIN then
                _scoreCollisions = _scoreCollisions + 1
            elseif phase == MOAIBox2DArbiter.END then
                _scoreCollisions = _scoreCollisions - 1
            end

            if _scoreCollisions >= 1 then
                if _gameUIMenu ~= nil then 
                    if _scoreFadeAnim ~= nil and _scoreFadeAnim:isBusy() then _scoreFadeAnim:stop() end
                    if _timeFadeAnim ~= nil and _timeFadeAnim:isBusy() then _timeFadeAnim:stop() end
                    if _gameUIScoreProp ~= nil then _scoreFadeAnim = _gameUIScoreProp:seekColor( 0.7 , 0.7 , 0.7 , 0.7 , 1 , MOAIEaseType.EASE_IN ) end
                    if _gameUITimeProp ~= nil then _timeFadeAnim = _gameUITimeProp:seekColor( 0.7 , 0.7 , 0.7 , 0.7 , 1 , MOAIEaseType.EASE_IN ) end
                end
            elseif _scoreCollisions < 1 then
                if _gameUIMenu ~= nil then 
                    if _scoreFadeAnim ~= nil and _scoreFadeAnim:isBusy() then _scoreFadeAnim:stop() end
                    if _timeFadeAnim ~= nil and _timeFadeAnim:isBusy() then _timeFadeAnim:stop() end
                    if _gameUIScoreProp ~= nil then _scoreFadeAnim = _gameUIScoreProp:seekColor( 1 , 1 , 1 , 1 , 1 , MOAIEaseType.EASE_IN ) end
                    if _gameUITimeProp ~= nil then _timeFadeAnim = _gameUITimeProp:seekColor( 1 , 1 , 1 , 1 , 1 , MOAIEaseType.EASE_IN ) end
                end
            end
        end
    end )

    _gameUIMenu = game_ui.addElement( 
        "menu" , -- The name
        resource.get( "Resources/UI/hud_button_menu.png" ) , -- The image
        Vector2.new( 122 , 126 ) , -- The size
        Vector2.new( _layer:wndToWorld( screen.relative( { top = "165" , right = "135" } , true ) ) ) , -- The position
        function ( touchType , idx , x , y , tapCount ) 
            if ( _gameUIMenu.disabled == nil or not _gameUIMenu.disabled ) and touchType == "up" then 
                if (_paused) then 
                  _screen.sound.playSound( "pop-low" )
                  if _optionsShown then game_ui.hideOptions( true ) end
                  if _menuShown then game_ui.hideMenu() end
                  _screen.resume() 
                  _paused = false 
                else 
                  _screen.sound.playSound( "pop-high" )
                  game_ui.showMenu() 
                  _screen.pause() 
                  _paused = true 
                end 
            end 
        end -- The callback
    )
    -- Stop other touch events when touching this button
    _gameUIMenu.stopPropagation = true

    _layer:insertProp( _gameUIMenu )
    table.insert( _gameUIProps , _gameUIMenu )

    _menuCollisions = 0
    _menuFixturePos = Vector2.new( _layer:wndToWorld(  _screen.relative( { top = "90" , right = "90" } , true ) ) )
    _menuFixture = _uiBody:addCircle( _menuFixturePos.x , _menuFixturePos.y , 150 )
    
    _menuFixture:setSensor( true )
    _menuFixture:setCollisionHandler( function( phase , fixtureA , fixtureB , arbiter ) 
        
        if not fixtureB.watchingOnly or fixtureB.enableUIFade then
            if phase == MOAIBox2DArbiter.BEGIN then
                _menuCollisions = _menuCollisions + 1
            elseif phase == MOAIBox2DArbiter.END then
                _menuCollisions = _menuCollisions - 1
            end

            if _menuCollisions >= 1 then
                if _gameUIMenu ~= nil then 
                    if _menuFadeAnim ~= nil and _menuFadeAnim:isBusy() then _menuFadeAnim:stop() end
                    _menuFadeAnim = _gameUIMenu:seekColor( 0.6 , 0.6 , 0.6 , 0.6 , 1 , _gameUIMenu.EASE_IN ) 
                    _gameUIMenu.disabled = true
                    _gameUIMenu.stopPropagation = false
                end
            elseif _menuCollisions < 1 then
                if _gameUIMenu ~= nil then 
                    if _menuFadeAnim ~= nil and _menuFadeAnim:isBusy() then _menuFadeAnim:stop() end
                    _menuFadeAnim = _gameUIMenu:seekColor( 1 , 1 , 1 , 1 , 1 , MOAIEaseType.EASE_IN ) 
                    _gameUIMenu.disabled = false
                    _gameUIMenu.stopPropagation = true
                end
            end
        end
    end )

    game_ui.showAnimation( _gameUIMenu )

end

function game_ui.hideUI( )

    if _uiBody ~= nil then
        _uiBody:destroy()
        _uiBody = nil
    end
    
    game_ui.hideAnimation( _gameUIMenu )
    game_ui.hideAnimation( _gameUITimeProp )
    game_ui.hideAnimation( _gameUIScoreProp , 
        function() 
            for x , prop in pairs( _gameUIProps ) do
                _layer:removeProp( prop )
                _gameUIProps[ x ] = nil
            end
        end 
    )

end

-- "Constructor" for this "Class"
function game_ui.init( layer , screen , world ) 

    --Add the layer for later use
    _layer = layer
    -- And the screen
    _screen = screen
    -- And the world (to sense collisions)
    _world = world
    -- And initialize the rest of the ui
    ui.init( layer , screen )
    -- Add the UI
    game_ui.showUI()

end

function game_ui.setTime( miliseconds )
    
    _time = miliseconds
    ui._elements[ "timeText" ]:setString( os.date("!%X", _time ) )
  
end

function game_ui.getTime( )

    return _time

end

function game_ui.setScore( amount ) 
  
    _score = amount
    ui._elements[ "scoreText" ]:setString( string.format( "%07d", _score ) )
  
end

function game_ui.getScore( )
  
    return _score
  
end

function game_ui.destroy() 

    for x , prop in pairs( _gameUIProps ) do
        _layer:removeProp( prop )
        _gameUIProps[ x ] = nil
    end
    
    for x , prop in pairs( _optionsMenuProps ) do
        _layer:removeProp( prop )
        _optionsMenuProps[ x ] = nil
    end
    
    for x , prop in pairs( _pauseMenuProps ) do
        _layer:removeProp( prop )
        _pauseMenuProps[ x ] = nil
    end

    -- Paused
    _paused = false
    -- Options shown
    _optionsShown = false
    -- Options shown
    _menuShown = false
    -- Disable button until animation is complete
    _buttonsDisabled = false

    -- Game over props
    _gameUIMenu = nil
    _gameUITimeProp = nil
    _gameUIScoreProp = nil
    _gameUIProps = {}
    -- Game over props
    _gameOver = nil
    _gameOverProps = {}
    -- Pause menu props
    _pauseMenu = nil
    _pauseMenuProps = {}
    -- Pause menu props
    _optionsMenu = nil
    _optionsMenuProps = {}

    if _uiBody ~= nil then
        _uiBody:destroy()
        _uiBody = nil
    end

    ui.destroy()

end

return game_ui