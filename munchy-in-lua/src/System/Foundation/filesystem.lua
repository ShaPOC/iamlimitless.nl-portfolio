---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@galaxyraiders.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- Use file system by lua
local lfs = require "lfs"
-- Instantiate the table as a prepration to return a "class"
local filesystem = {}
filesystem.__index = filesystem

-- check if the file exists
function filesystem.exists( file )
  
    local f = io.open( file , "r" )
    if f then f:close() end
    return f ~= nil
    
end

-- Get all lines from a file, returns an empty 
-- string if the file does not exist
function filesystem.read( file )
  
    if not filesystem:exists( file ) then return nil end
    lines = {}
    for line in io.lines( file ) do 
        lines[ #lines + 1 ] = line
    end
    return table.concat( lines , "");
    
end

-- Get files in directory with specific extension
function filesystem.list( dir , ext )
  
    results = {}
    for file in lfs.dir( dir ) do
        if string.match(file, "%.(%w+)") == ext then 
            results[ #results + 1 ] = file
        end
    end
    return results
end

-- return the "class"
return filesystem;