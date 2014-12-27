---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@galaxyraiders.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

require( "System/Foundation/filesystem" )

local language = {}
language.__index = language

-- Manual constructor method
function language.init( config )
  
    -- If and when the options table exists, and more importantly has a language code, use this!
    -- Else, use the default language of the device
    language.languageCode = ( config and config.languageCode ) and config.languageCode or MOAIEnvironment.languageCode
    -- Now it can still be nil though, because some environments just aren't supported by 
    -- MOAIEnvironment. In that case, just make it english.
    if not language.languageCode then
        language.languageCode = "nl_NL"
    end
    
    -- Now get the file
    local languageFile = filesystem:read( _G.ROOT .. "Languages/Data/" .. cl.languageCode .. ".json" )

    -- And decode it and keep it in memory
    if languageFile then language.languageTable = MOAIJsonParser.decode( languageFile ) end
    
end

-- Get Method to fetch language
-- @param string str The original string which has to be translated
function language.get(str)
  
    return ( language.languageTable and language.languageTable[ str ] ) and language.languageTable[ str ] or str

end

return language