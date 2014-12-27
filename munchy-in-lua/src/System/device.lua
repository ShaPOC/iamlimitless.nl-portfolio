---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

local device = {}
device.__index = device

device._isIOS = false
device._isAndroid = false

local function iOSDeviceInit()
  
    -- Set IOS flag to true
    device._isIOS = true
    -- First make sure we are authenticated
    MOAIGameCenterIOS.authenticatePlayer()
  
end

local function androidDeviceInit()
  
    -- Set Android flag to true
    device._isAndroid = true
  
end

-- "Constructor" for this "Class"
function device.init() 
  
    -- If it's iOS
    if MOAIEnvironment.osBrand == MOAIEnvironment.OS_BRAND_IOS then 
        -- Initialize the iOS specific classes and functions
        iOSDeviceInit()
        
    -- If it's Android
    elseif MOAIEnvironment.osBrand == MOAIEnvironment.OS_BRAND_ANDROID then 
        -- Initialize the Android specific classes and functions
        androidDeviceInit()
        
    end
  
end

function device.showLeaderboard( )

    if _isIOS and MOAIGameCenterIOS.isSupported() then
        MOAIGameCenterIOS.showDefaultLeaderboard	()
    end

end

function device.addScore( score , category )

    if _isIOS and MOAIGameCenterIOS.isSupported() then
        MOAIGameCenterIOS.reportScore( score , category )
    end

end

function device.addAchievement( id , percentage )

    if _isIOS and MOAIGameCenterIOS.isSupported() then
        MOAIGameCenterIOS.reportAchievementProgress( id , percentage or 100 )
    end

end

return device