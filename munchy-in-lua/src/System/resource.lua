---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local resource = {}
resource.__index = resource

-- "Constructor" for this "Class"
function resource.init() end

-- Create the texture table
local textureCache = {}
-- Create the font table
local fontCache = {}
-- Create the sound table
local soundCache = {}

--[[
-- This method is called by the first preload class. And thus will
-- be executed on game startup. It's recommended to load the
-- most essential resources here.
--]]
function resource.preload ( preloadTable )
  
    local textureList = {}
  
    -- We simply get each file to make it cache automatically
    for x , file in pairs( preloadTable ) do
        table.insert( textureList , resource.get( file ) )
    end
    
    -- And we return the list of textures afterwards
    return textureList

end

--[[
-- This method is used to load a texture and uses a clever way of 
-- caching already loaded texture to save up on memory
--]]
local function getTexture ( file )

    if textureCache [ file ] == nil then

        texture = MOAITexture.new()
        texture:load( file )
        textureCache [ file ] = texture

    end

    return textureCache [ file ]

end
-- This is almost the same method, but for fonts
local function getFont ( file )

    if fontCache [ file ] == nil then

        font = MOAIFont.new()
        font:load( file )
        fontCache [ file ] = font

    end

    return fontCache [ file ]

end
-- This is also almost the same method, but for sounds
local function getSound ( file )

    if soundCache [ file ] == nil then

        sound = MOAIUntzSound.new()
        sound:load( file )
        
        sound:setVolume( 1 )
        sound:setLooping( false )
        
        soundCache [ file ] = sound

    end

    return soundCache [ file ]

end

function resource.get ( file )

    -- Get the file extension to determine the correct action
    extension = string.sub( string.match( file , ".[0-9a-z]+$" ) , 1 )

    if extension == ".png" or extension == ".jpg" then
        -- We use the smaller sized textures on smaller devices to save memory!
        if type( screen ) == "table" and screen.DEVICE_WIDTH ~= nil and screen.DEVICE_WIDTH < 1136 then
            file = string.gsub( file , extension , "-s2" .. extension )
        end
        return getTexture( file )
    end
    if extension == ".otf" or extension == ".ttf" then
        return getFont( file )
    end
    if extension == ".wav" or extension == ".mp3" then
        return getSound( file )
    end

end

return resource