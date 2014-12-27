---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- 'Mother / Base / Parent' Class
local object = dofile( _G.ROOT .. "System/Elements/object.lua" )

local magnet = {}

-- Enable inheritance on the object class
setmetatable(magnet, {
  __index = object, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self.init(...)
    return self
  end,
})

-- Get the resource class
resource = require( "System/resource" )

-- "Constructor" for this "Class"
function magnet.init( world , direction ) 

    magnet.prop = object.initWithAnimatedSpriteSheet( 
      "magnet" , 
      resource.get( "Resources/Sprites/Ripples/Ripples" .. direction .. "0.png" ) ,
      7 ,
      5 ,
      31 ,
      require( "Resources/Sprites/Ripples/Ripples" .. direction .. "0" ) ,
      512 ,
      512 )
    
    -- Add the world for Box2D
    magnet.setWorld( world )
    -- Add a body and fixture
    magnet.fixture = magnet.addCircle( MOAIBox2DBody.DYNAMIC, 192 )
    -- Sense only! We don't want things bouncing off this
    magnet.fixture:setSensor( true )
    -- Watching only, do not get sucked into the hole
    magnet.fixture.watchingOnly = true
    -- But we do want the ui to react
    magnet.fixture.enableUIFade = true
    
    return magnet.prop
  
end

-- The destroy function is called once the object should no longer be on the screen
function magnet.destroy()
  
    if magnet.fixture ~= nil then
        magnet.fixture:destroy()
        magnet.fixture = nil
    end
    
    if magnet.body ~= nil then
        magnet.body:destroy()
        magnet.body = nil
        object.body = nil
    end
    
    if magnet.prop ~= nil then
        magnet.prop:setDeck( nil )
        magnet.prop = nil
    end
  
    object.destroy()
    object = nil
  
end

return magnet