---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local sound = {}
sound._index = sound

local resource = require "System/resource"

-- Settings by the user
sound.musicEnabled = true
sound.soundEnabled = true

-- The library containing sounds
local _soundLibrary = {}
-- The library containing music
local _musicLibrary = {}

-- What music is currently plaing
local _musicPlaying = nil
-- What music is to be resumed when we stopped it
local _stoppedMusic = nil

-- "Constructor" for this "Class"
function sound.init( userdata ) 

    MOAIUntzSystem.initialize()
    -- Set the user settings
    sound.musicEnabled = userdata.music
    sound.soundEnabled = userdata.sound

end

function sound.preload()

    -- Music
    _musicLibrary[ "game" ] = {
        sound = resource.get( "Resources/Music/game.mp3" ) ,
        volume = 1 ,
        loop = true
    }
    _musicLibrary[ "mainmenu" ] = {
        sound = resource.get( "Resources/Music/mainmenu.mp3" ) , 
        volume = 0.6 ,
        loop = true
    }
    
    -- Sound
    _soundLibrary[ "gameover" ] = {
        sound = resource.get( "Resources/Sounds/gameover.wav" )
    }
    _soundLibrary[ "pop-high" ] = {
        sound = resource.get( "Resources/Sounds/pop-high.wav" )
    }
    _soundLibrary[ "pop-low" ] = {
        sound = resource.get( "Resources/Sounds/pop-low.wav" )
    }
    _soundLibrary[ "slap" ] = {
        sound = resource.get( "Resources/Sounds/slap.mp3" )
    }
    _soundLibrary[ "dizzy" ] = {
        sound = resource.get( "Resources/Sounds/dizzy.wav" )
    }
    _soundLibrary[ "fireball" ] = {
        sound = resource.get( "Resources/Sounds/fireball.mp3" )
    }
    _soundLibrary[ "swoosh1" ] = {
        sound = resource.get( "Resources/Sounds/swoosh1.wav" )
    }
    _soundLibrary[ "swoosh2" ] = {
        sound = resource.get( "Resources/Sounds/swoosh2.wav" )
    }
    _soundLibrary[ "swoosh3" ] = {
        sound = resource.get( "Resources/Sounds/swoosh3.wav" )
    }
    _soundLibrary[ "swoosh4" ] = {
        sound = resource.get( "Resources/Sounds/swoosh4.wav" )
    }
    
    _soundLibrary[ "munchybite" ] = {
        sound = resource.get( "Resources/Sounds/munchybite.mp3" )
    }
    _soundLibrary[ "munchydizzy" ] = {
        sound = resource.get( "Resources/Sounds/munchydizzy.wav" )
    }
    _soundLibrary[ "munchygulp" ] = {
        sound = resource.get( "Resources/Sounds/munchygulp.mp3" )
    }
    _soundLibrary[ "munchyhit" ] = {
        sound = resource.get( "Resources/Sounds/munchyhit.wav" )
    }
    _soundLibrary[ "munchyopenmouth" ] = {
        sound = resource.get( "Resources/Sounds/munchyopenmouth.mp3" ) ,
        volume = 0.5
    }
    _soundLibrary[ "munchyscream" ] = {
        sound = resource.get( "Resources/Sounds/munchyscream.wav" )
    }

end

function sound.playSound( name )

    if sound.soundEnabled and _soundLibrary[ name ] ~= nil then
        if _soundLibrary[ name ].sound.volume then _soundLibrary[ name ].sound:setVolume( _soundLibrary[ name ].sound.volume ) end
        _soundLibrary[ name ].sound:play()
    end

end

local function setMusic( music )

    _musicPlaying = music
    
    if music.volume then _musicPlaying.sound:setVolume( music.volume ) end
    if music.loop then _musicPlaying.sound:setLooping( music.loop ) end
    
    _musicPlaying.sound:play()
    _musicPlaying.sound:seekVolume( music.volume or 1 , 0.4 , MOAIEaseType.SOFT_SMOOTH )

end

function sound.playMusic( name )

    if sound.musicEnabled and _musicLibrary[ name ] ~= nil and _musicPlaying ~= _musicLibrary[ name ] then

        if _musicPlaying ~= nil then
            local volChange = _musicPlaying.sound:seekVolume( 0 , 0.4 , MOAIEaseType.SOFT_SMOOTH )
            volChange:setListener( MOAIAction.EVENT_STOP , function( ) setMusic( _musicLibrary[ name ] ) end )
        else
            setMusic( _musicLibrary[ name ] )
        end
        
    elseif not sound.musicEnabled and _musicLibrary[ name ] ~= nil then
        _stoppedMusic = _musicLibrary[ name ]
    end

end

function sound.resumeMusic( )

    if _stoppedMusic ~= nil then
        setMusic( _stoppedMusic )
    end

end

function sound.stopMusic( )
  
    -- We want to remember what we stopped
    _stoppedMusic = _musicPlaying
    if _musicPlaying ~= nil then
        _musicPlaying.sound:stop()
        _musicPlaying = nil
    end
  
end

return sound