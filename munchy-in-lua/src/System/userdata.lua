---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local userdata = {}
userdata._index = userdata

-- The path
local path = (MOAIEnvironment.documentDirectory or "./") .. "/saved_user_data.lua"
-- The actual data
userdata.data = {}

local APP_NAME

-- "Constructor" for this "Class"
function userdata.init( name ) 

    -- Insert the name
    APP_NAME = name

    local userdatafile = loadfile(path) or nil

    -- Get the persisted data:
    if (userdatafile ~= nil) then
        userdata.data = userdatafile() -- we de-serialize our loads
    else
        userdata.reset() -- or, we begin anew ..
    end

end

-- Reset the user_data table, in case the user needs it (application-persistent data reset)
function userdata.reset()

    -- The app name used in the file
    userdata.app_name = APP_NAME
    
    userdata.data.music = true
    userdata.data.sound = true
    userdata.data.reverse = false
    
    userdata.data.bestTime = 0
    userdata.data.bestScore = 0

    -- every time we use this method, user_data will persist.
    userdata.save()

end

-- Save the contents of the user_data, for eternity ..
function userdata.save()

    serializer = MOAISerializer.new ()
    serializer:serialize ( userdata.data )

    user_data_Str = serializer:exportToString ()
   
    --compiled = string.dump ( loadstring ( user_data_Str, '' ))
    user_data_file = io.open ( path , 'wb' )
    
    -- attempt to save the file ..
    if (user_data_file ~= nil) then

        user_data_file:write ( user_data_Str )
        user_data_file:close ()

    end

end

return userdata