---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- ------------------------------------------------------------
-- Get the config
-- ------------------------------------------------------------
-- Get the config file which is used to instantiate all kinds
-- of other classes during startup
config = require "config"

-- ------------------------------------------------------------
-- Get the user data
-- ------------------------------------------------------------
-- We have a persistant data store on the flash drive to ensure
-- multi platform data persistance. It's started here!
userdata = require "System/userdata"
-- Fetch the data file
userdata.init( config.gameName )

-- ------------------------------------------------------------
-- Get the device class
-- ------------------------------------------------------------
-- Get the device class and initialize it so that it gets
-- filled with all the information used alongside the config.
device = require "System/device"
device.init()

-- ------------------------------------------------------------
-- Get the sound manager
-- ------------------------------------------------------------
-- Get the device class and initialize it so that it gets
-- filled with all the information used alongside the config.
sound = require "System/sound"
sound.init( userdata.data )

-- ------------------------------------------------------------
-- Get the input manager
-- ------------------------------------------------------------
-- We get the input manager and make it public, because we
-- actually use it everywhere!
input = require "System/input"

-- ------------------------------------------------------------
-- Start the screen manager
-- ------------------------------------------------------------
-- The screen manager is called by each screen to set another
-- or influence the current screen

screen = require "System/screen"
-- Insert the device into the screen
screen.device = device
-- And the sound manager
screen.sound = sound
-- And the userdata manager
screen.userdata = userdata
-- Construct the class
screen.init( config )

-- ------------------------------------------------------------
-- Start the preloader
-- ------------------------------------------------------------
-- The preloader fetches incredibly important assets but also
-- fetches the screens for the screen manager
preload = require "System/Bootstrap/preload"
-- We preload the screens and return them to be used by the
-- screen manager later
preload.screen( {
    
    { filename = "Screens/loading", id = "loading" }
    
} , screen.set , function()

preload.set( screen.activate( "loading" ) , function()

-- ------------------------------------------------------------
-- Load the sound and music libraries
-- ------------------------------------------------------------
sound.preload()

-- ------------------------------------------------------------
-- Load everything else!
-- ------------------------------------------------------------
-- Now we load the rest and once that is done, we execute the
-- above inserted command automatically

preload.screen( {
    
    { filename = "Screens/game", id = "game" },
    { filename = "Screens/menu", id = "menu" }
    
} , screen.set , function() 

-- ------------------------------------------------------------
-- Start the screen when everything finsihed loading
-- ------------------------------------------------------------

screen.activate( "menu" )

end ) end ) end )