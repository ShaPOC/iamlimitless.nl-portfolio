--[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- ------------------------------------------------------------
-- ROOT path
-- ------------------------------------------------------------
-- Get the root of this file, which is the project root!
-- Warning, this variable will have an ending forward slash!
-- So don't add an extra forward slash when using it!

_G.ROOT = MOAIFileSystem:getAbsoluteDirectoryPath( "./" )

-- ------------------------------------------------------------
-- The random seed!
-- ------------------------------------------------------------
-- This very important little seed makes sure the game is 
-- different every time
math.randomseed(os.time())

-- ------------------------------------------------------------
-- Set package path to ROOT
-- ------------------------------------------------------------
-- We want the p ackage path to always be in the root no matter
-- where we compile from.
package.path = package.path .. ";" .. _G.ROOT

-- ------------------------------------------------------------
-- And finally, we start the system!
-- ------------------------------------------------------------
require "System/Bootstrap/start"