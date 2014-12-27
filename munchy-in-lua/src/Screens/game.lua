---[[
--  @package    Monster Munchies
--  @author     Jimmy Aupperlee <jimmy@moustachegames.net>
--  @copyright  2014 Jimmy Aupperlee
--  @license    http://moustachegames.net/code-license
--  @version    0.1.0
--  @since      File available since Release 0.1.0
--]]

-- Additions to regular code
require "System/Foundation/datatypes"
require "System/Foundation/debug"
-- Get the resource class
local resource = require( "System/resource" )

-- Instantiate the table as a prepration to return a "class"
local game_screen = {}
game_screen._index = game_screen

---[[
-- Set the layers for this screen
--]]
game_screen.layerNames = {
    "Background",
    "Objects",
    "UI"
}

-- Elapsed Time
game_screen.elapsedTime = 0

-- The spawns
game_screen.spawns = {}

-- List of active bodies (used by Box2D)
game_screen.activeObjectList = {}

-- The black hole object
game_screen.blackHole = {
    orbitalRadius = 650,
    orbitalAngle = 90,
    pullRadius = 550,
    deathRadius = 95,
    gravity = 340,
    pos = nil,
    body = nil
}

game_screen.score = 0
game_screen.orbitSpeed = 10
game_screen.fingerRadius = 300

-- The push magnet (two fingers)
game_screen.pushMagnet = {
    pullRadius = 600,
    gravity = -280,
    ignoreBodyName = { 
        candy = true,
        comet = true 
    }
}

-- The pull magnet (one finger)
game_screen.pullMagnet = {
    pullRadius = 600,
    gravity = 280,
    ignoreBodyName = { 
        candy = true,
        comet = true 
    }
}

-- Add gravitational forces
game_screen.gravitationalForces = {}

-- A table containing touches
game_screen.fingers = {}

---[[
-- The preload screen method gets called by the preload
-- "class" before returning it to the screen manager
--]]
function game_screen.preload(  )

    -- Add every object to the correct table
    return resource.preload( { 
        "Resources/Sprites/Ripples/RipplesPull0.png" , 
        "Resources/Sprites/Ripples/RipplesPush0.png" ,
        
        "Resources/Sprites/Munchy/EyeRolling0.png",
        "Resources/Sprites/Munchy/Idle_0.png",
        
        "Resources/Sprites/Candy/CandyPinkFlip0.png",
        "Resources/Sprites/Candy/CandyPinkRoll0.png",
        "Resources/Sprites/Candy/CandyStripedFlip0.png",
        "Resources/Sprites/Candy/CandyStripedRoll0.png",
        
        "Resources/Sprites/Rocks/Rocks0.png",
        "Resources/Sprites/Fireball/Fireball0.png",

    } )

end

-- Previous elapsed time
local _previousElapsedTime
-- Boolean if the game is paused
local _paused
-- Space environment class
local _space = require( "Objects/Environment/space" )
-- A global timer used by timeouts
local _timer = nil

-- Time
local _randomCandyTimeMin = nil
local _randomCandyTimeMax = nil
-- The next time candy will appear
local _nextRandomCandyTime = 0
-- Time
local _randomRockTimeMin = nil
local _randomRockTimeMax = nil
-- The next time candy will appear
local _nextRandomRockTime = 0
-- Time
local _randomFireballTimeMin = nil
local _randomFireballTimeMax = nil
-- The next time candy will appear
local _nextRandomFireballTime = 0

---[[
-- The start method is called every time the screen is
-- set to be visible
--]]
function game_screen.start()

    _paused = false
    
    -- Time
    _randomCandyTimeMin = 7
    _randomCandyTimeMax = 9
    -- The next time candy will appear
    _nextRandomCandyTime = 0
    -- Time
    _randomRockTimeMin = 4
    _randomRockTimeMax = 8
    -- The next time candy will appear
    _nextRandomRockTime = 0
    -- Time
    _randomFireballTimeMin = 32
    _randomFireballTimeMax = 46
    -- The next time candy will appear
    _nextRandomFireballTime = 0

    game_screen.backgroundLayer = game_screen.getLayer( "Background" )
    game_screen.objectLayer = game_screen.getLayer( "Objects" )
    game_screen.UI = game_screen.getLayer( "UI" )
    
    game_screen.world = MOAIBox2DWorld.new ()
    game_screen.world:setGravity( 0 , 0 ) -- No default gravity
    game_screen.world:setUnitsToMeters( 1 / 30 )
    game_screen.world:start()
    
    -- Do we want debugging?
    if not screen.config.debug then
        game_screen.world:setDebugDrawEnabled( false )
    end
    
    game_screen.objectLayer:setBox2DWorld( game_screen.world )
    -- Set the touch layer containing props that may be touched and should react when touched
    input.setPropLayer( "UI" , game_screen.UI )
    -- Initialize the ui
    game_screen.ui = dofile( _G.ROOT .. "Screens/UI/game.lua" )
    game_screen.ui.init( game_screen.UI , screen , game_screen.world )

    backgroundTexture = resource.get( "Resources/Images/background-sq.png" );

    playfieldDeck = MOAIGfxQuad2D.new()
    playfieldDeck:setTexture( backgroundTexture )
    
    -- Always calculated from the center
    playfieldDeck:setRect(screen.GAME_WIDTH / -2, screen.GAME_HEIGHT / -2, screen.GAME_WIDTH / 2, screen.GAME_HEIGHT / 2)

    playfieldProp = MOAIProp2D.new()
    playfieldProp:setDeck(playfieldDeck)
    
    game_screen.backgroundLayer:insertProp(playfieldProp)
    
    game_screen.centerBlackHole = dofile( _G.ROOT .. "Objects/Environment/blackhole.lua" )
    blackHoleProp = game_screen.centerBlackHole.init( game_screen.world , game_screen.blackHole.deathRadius )
    
    -- Set the black hole data
    game_screen.centerBlackHole.setUserData( shallowcopy( game_screen.blackHole ) )
    -- Set a callback
    game_screen.centerBlackHole.setCollisionHandler( deathByBlackHole )
    -- Make it active
    game_screen.gravitationalForces[ game_screen.centerBlackHole.id ] = game_screen.centerBlackHole
    -- Insert the black hole itself
    game_screen.backgroundLayer:insertProp( game_screen.centerBlackHole.createActualHole() )
    -- Insert the singularity
    game_screen.backgroundLayer:insertProp( blackHoleProp )
        -- Insert the black hole itself
    game_screen.backgroundLayer:insertProp( game_screen.centerBlackHole.createOuterSingularity() )
    
    -- Get Munchy
    local munchy = dofile( _G.ROOT .. "Objects/Actors/munchy.lua" )
    munchyProp = munchy.init( game_screen.world , game_screen.objectLayer )

    munchy.body:setTransform( 300 , 400 )
    -- Set a callback
    munchy.fixture:setCollisionHandler( munchyHitsSomething )
    -- Make it active
    game_screen.activeObjectList[ munchy.id ] = munchy
    -- Insert it!
    game_screen.objectLayer:insertProp( munchyProp )
    
    -- And initalize the input
    input.init( screen.config.debug )
    
    input.onTouchDown( game_screen.onTouchDown )
    input.onTouchUp( game_screen.onTouchUp )
    input.onTouchMove( game_screen.onTouchMove )
    
    -- Reset the time
    game_screen.elapsedTime = 0
    game_screen.ui.setTime( game_screen.elapsedTime )
    -- Set the current time now!
    _previousElapsedTime = MOAISim.getDeviceTime()
    
    -- Initialize the borders in space
    _space.init( game_screen.world , screen )
    _space.setCollisionHandler( objectHitsOuterSpace )
    
    -- The next time candy will appear
    _nextRandomCandyTime = 0
    -- The next time candy will appear
    _nextRandomRockTime = 0
    -- The next time candy will appear
    _nextRandomFireballTime = 0
    
    -- Munchy is never dizzy at the beginning
    game_screen.pushMagnet.ignoreBodyName[ "munchy" ] = false
    game_screen.pullMagnet.ignoreBodyName[ "munchy" ] = false
    
    -- Play the music!
    screen.sound.playMusic( "game" )

end

function spawnTry() 
  
    -- Timer checks
    if _nextRandomCandyTime ~= 0 and _nextRandomCandyTime <= game_screen.elapsedTime then
        -- The time has elapsed, now spawn
        _randomCandyTimeMin = _randomCandyTimeMin - 0.05
        _randomCandyTimeMax = _randomCandyTimeMax - 0.02
        spawnCandy()
    end
    if _nextRandomRockTime ~= 0 and _nextRandomRockTime <= game_screen.elapsedTime then
        -- The time has elapsed, now spawn
        _randomRockTimeMin = _randomRockTimeMin - 0.08
        _randomRockTimeMax = _randomRockTimeMax - 0.06
        spawnRock()
    end
    if _nextRandomFireballTime ~= 0 and _nextRandomFireballTime <= game_screen.elapsedTime then
        -- The time has elapsed, now spawn
        _randomFireballTimeMin = _randomFireballTimeMin - 0.5
        _randomFireballTimeMin = _randomFireballTimeMin - 0.4
        spawnFireball()
    end
    
    -- Timer resets
    if _nextRandomCandyTime == 0 or _nextRandomCandyTime <= game_screen.elapsedTime then
        _nextRandomCandyTime = _nextRandomCandyTime + math.random( _randomCandyTimeMin , _randomCandyTimeMax )
    end
    if _nextRandomRockTime == 0 or _nextRandomRockTime <= game_screen.elapsedTime then
        _nextRandomRockTime = _nextRandomRockTime + math.random( _randomRockTimeMin , _randomRockTimeMax )
    end
    if _nextRandomFireballTime == 0 or _nextRandomFireballTime <= game_screen.elapsedTime then
        _nextRandomFireballTime = _nextRandomFireballTime + math.random( _randomFireballTimeMin , _randomFireballTimeMax )
    end
  
end

-- Get a random position including the size of the object which needs to be placed there
function randomObjectPositionOutsideViewPort( objectWidth , objectHeight , viewPortWidth , viewPortHeight )
  
    horVert = math.random( 0 , 1 )
    side = math.random( 0 , 1 )
    
    if horVert == 1 then
        height = math.random( 0 , viewPortHeight )
        if side == 1 then return Vector2.new( viewPortWidth + objectWidth , height ) else return Vector2.new( -objectWidth , height ) end
    else
        width = math.random( 0 , viewPortWidth )
        if side == 1 then return Vector2.new( width , viewPortHeight + objectHeight ) else return Vector2.new( width , -objectHeight ) end
    end
  
end

local function spawn( file , position , distance , velo , target ) 
  
    local spawnThing = dofile( _G.ROOT .. file )
    
    randomPos = randomObjectPositionOutsideViewPort( distance , distance , screen.DEVICE_WIDTH , screen.DEVICE_HEIGHT ) 
    pos = Vector2.new( game_screen.backgroundLayer:wndToWorld( randomPos.x , randomPos.y ) )
    
    spawnThingProp = spawnThing.init( game_screen.world , pos , game_screen.objectLayer , screen.sound )
    
    spawnThing.spawn( position , velo , target )
    
    game_screen.objectLayer:insertProp( spawnThingProp )

    -- Make sure the body gets pulled by gravity
    game_screen.activeObjectList[ spawnThing.id ] = spawnThing
    
    return spawnThing
  
end

function spawnCandy()
    
    spawn( "Objects/Actors/candy.lua" , math.random( -game_screen.blackHole.pullRadius / 2, game_screen.blackHole.pullRadius / 2 ) , 64 , 0.04 )
  
end

function spawnRock()

    spawn( "Objects/Environment/rock.lua" , math.random( -game_screen.blackHole.pullRadius / 2, game_screen.blackHole.pullRadius / 2 ) , 92 , 0.26 )

end

function spawnFireball()

    fb = spawn( "Objects/Environment/fireball.lua" , math.random( -game_screen.blackHole.pullRadius, game_screen.blackHole.pullRadius ) , 512 , 1.2 )
    fb.setCollisionHandler( fireBallHitsSomething )

end

local function removeFinger ( idx )
    
    if game_screen.fingers[ idx ] ~= nil then
        -- And remove it from the forces
        game_screen.gravitationalForces[ game_screen.fingers[ idx ].id ] = nil
        -- If it has a prop (it should)
        if game_screen.fingers[ idx ].prop then
            -- Then remove it
            game_screen.objectLayer:removeProp( game_screen.fingers[ idx ].prop )
        end
        -- Destroy the body
        if game_screen.fingers[ idx ].body ~= nil then game_screen.fingers[ idx ].body:destroy() game_screen.fingers[ idx ].body = nil end
        -- Make sure the magnet.destroy function is called
        if type( game_screen.fingers[ idx ].destroy ) == "function" then game_screen.fingers[ idx ].destroy() end
        -- And finally set it to nil
        game_screen.fingers[ idx ] = nil
    end
end

local function addFinger( idx , position , pull , idxa )
  
    -- First destroy the finger with the same id if it's there
    if game_screen.fingers[ idx ] ~= nil then removeFinger( idx ) end
  
    -- Create a push or pull object
    local magnet = dofile( _G.ROOT .. "Objects/Environment/magnet.lua" )

    -- We reverse the magnet types if it says so in the userdata (settings)
    if screen.userdata.data.reverse == true then
        -- Reverse the finger!
        if pull == false or pull == nil then pull = true else pull = false end
    end

    -- Create the actual magnet
    magnetProp = magnet.init( game_screen.world , ( pull and "Pull" or "Push" ) )
    magnet.setUserData( shallowcopy( ( pull and game_screen.pullMagnet or game_screen.pushMagnet ) ) )
    magnet.body:setTransform( position.x , position.y )

    magnet.pull = pull
    magnet.idxa = idxa

    -- Add the magnet
    game_screen.gravitationalForces[ magnet.id ] = magnet
    game_screen.objectLayer:insertProp( magnetProp )

    return magnet
  
end

function game_screen.onTouchDown( idx , x , y , tapCount )

    if not _paused then
        -- Add the finger
        game_screen.fingers[ idx ] = addFinger( idx , Vector2.new( game_screen.objectLayer:wndToWorld( x, y ) ) )
        -- Check if there are two fingers set now
        game_screen.checkDoubleFinger()
    end

end

function game_screen.onTouchUp( idx , x , y , tapCount )
  
    if not _paused and game_screen.fingers[ idx ] ~= nil then
        -- Remove the finger
        removeFinger( idx )
        -- Check if there aren't two fingers set now
        game_screen.checkDoubleFinger()
    end
  
end

-- We track the movements to move double fingers
local _fingerMovements = {}

function game_screen.onTouchMove( idx , x , y , tapCount )

    -- Get the new position
    local newPosition = Vector2.new( game_screen.objectLayer:wndToWorld( x, y ) )
    -- We add the movement to keep track of it
    _fingerMovements[ idx ] = { x = newPosition.x , y = newPosition.y }

    if not _paused and game_screen.fingers[ idx ] ~= nil and game_screen.fingers[ idx ].body ~= nil then

        -- If two fingers are set, place the body in the center of the two fingers after moving it
        if game_screen.fingers[ idx ].combined ~= nil and _fingerMovements[ game_screen.fingers[ idx ].combined ] ~= nil then

            newPos = getCenterBetweenVectors( Vector2.new( _fingerMovements[ idx ].x , _fingerMovements[ idx ].y ) , 
              Vector2.new( _fingerMovements[ game_screen.fingers[ idx ].combined ].x , _fingerMovements[ game_screen.fingers[ idx ].combined ].y ) )

            game_screen.fingers[ idx ].body:setTransform( newPos.x , newPos.y )

        else

            -- Move the magnet
            game_screen.fingers[ idx ].body:setTransform( newPosition.x , newPosition.y )

        end

    end

end

function getCenterBetweenVectors( vector1 , vector2 ) 

    difference = ( vector1 - vector2 ) / 2
    newPos = vector1 - difference
    
    return newPos

end

function game_screen.checkDoubleFinger( )

    for idx, finger in pairs( game_screen.fingers ) do

        local fingerPos = Vector2.new( finger.body:getPosition() )
        -- Check to see if there is another finger in the radius of this one
        for idxa, anotherFinger in pairs( game_screen.fingers ) do
          
            if( finger.id ~= anotherFinger.id ) then
              
                -- Change the position to a nice vector
                anotherFingerPos = Vector2.new( anotherFinger.body:getPosition() )
                
                -- Check if the two intersect
                if circlesIntersect( fingerPos.x , fingerPos.y , game_screen.fingerRadius , anotherFingerPos.x , anotherFingerPos.y , game_screen.fingerRadius ) then
                  
                    -- Make sure the two finger job wasn't already set
                    if ( not screen.userdata.data.reverse and not game_screen.fingers[ idx ].pull and not game_screen.fingers[ idxa ].pull ) or
                     ( screen.userdata.data.reverse and game_screen.fingers[ idx ].pull and game_screen.fingers[ idxa ].pull ) then
                        
                        newPos = getCenterBetweenVectors( fingerPos , anotherFingerPos )

                        -- Remove the first one
                        removeFinger( idx )
                        game_screen.fingers[ idx ] = nil
                        -- And the second one
                        removeFinger( idxa )
                        game_screen.fingers[ idxa ] = nil
                      
                        -- And add the pull finger in the middle finger
                        game_screen.fingers[ idx ] = addFinger(  idx , Vector2.new( newPos.x , newPos.y ) , true , idxa )
                        -- And we remember the other finger
                        game_screen.fingers[ idx ].combined = idxa
                      
                    end
                end
            end
        end
    end
end

-- Fixed update intervals
local _fixedUpdateInterval = ( 1 / 30 )
local _lastFixedUpdateInterval = 0

---[[
-- The update method is called once every frame
--]]
function game_screen.update(  )

    while not _paused do 

        if _lastFixedUpdateInterval <= 0 then
            game_screen.fixedUpdate(  )
            _lastFixedUpdateInterval = _fixedUpdateInterval
        end
        
        for i, grav in pairs(game_screen.gravitationalForces) do
      
            if type( grav.update ) == "function" then
                grav.update()
            end
          
        end
        
        for i, obj in pairs(game_screen.activeObjectList) do
      
            if type( obj.update ) == "function" then
                obj.update()
            end
          
        end

        local currentElapsedTime = MOAISim.getDeviceTime()
        local newTime = currentElapsedTime - _previousElapsedTime
        
        game_screen.elapsedTime = game_screen.elapsedTime + newTime
        _lastFixedUpdateInterval = _lastFixedUpdateInterval - newTime
        _previousElapsedTime = currentElapsedTime

        game_screen.ui.setTime( game_screen.elapsedTime )

        spawnTry()

        -- For demonstration purposes
        if game_screen.ui.getTime() >= 60 then
            screen.device.addAchievement( "munchy.survivalist" )
        end

        for id, object in pairs(game_screen.activeObjectList) do
            
            -- Get the vector2 position of the body
            local bodyPos = Vector2.new( object.body:getPosition() )
            local bodyPosVect = screen.deviceToScaled( Vector2.new(game_screen.objectLayer:worldToWnd( bodyPos.x , bodyPos.y ) ) )

            for i, grav in pairs( game_screen.gravitationalForces ) do
              
                -- Get the position
                local gravPos = Vector2.new( grav.body:getPosition() )
                local gravPosVect = screen.deviceToScaled( Vector2.new(game_screen.objectLayer:worldToWnd( gravPos.x , gravPos.y ) ) )
                -- Calculate the distance to the hole or magnet
                distance = gravPosVect:distance(bodyPosVect)

                if not object.name or not grav.ignoreBodyName or not ( grav.ignoreBodyName and grav.ignoreBodyName[ object.name ] ~= nil and grav.ignoreBodyName[ object.name ] ~= false ) then

                    -- If the distance is lower or equal to the pull radius, then start pulling
                    if grav.pullRadius and distance <= grav.pullRadius then

                        -- We calculate the direction in which it needs to move
                        local direction = gravPosVect - bodyPosVect

                        -- Now we calculate the force of the push towards the target
                        local force = direction:normalized() * (1 - distance / grav.pullRadius) * grav.gravity
                        -- And apply that force
                        object.body:applyForce( force.x , -force.y , bodyPosVect.x , bodyPosVect.y )
                        
                    end
                end
            end
        end
        
        coroutine.yield()
        
    end
end

---[[
-- The update method is called on a fixed time set in the engine
--]]
function game_screen.fixedUpdate(  )
  
    for i, grav in pairs(game_screen.gravitationalForces) do
      
        if type( grav.fixedUpdate ) == "function" then
            grav.fixedUpdate( game_screen.elapsedTime )
        end
      
    end
    
    for i, obj in pairs( game_screen.activeObjectList ) do
      
        if type( obj.fixedUpdate ) == "function" then
            obj.fixedUpdate( game_screen.elapsedTime )
        end
      
    end
  
end

local function removeObject( obj )

      if obj.prop then game_screen.objectLayer:removeProp( obj.prop ) end
      if type( obj.destroy ) == "function" then obj.destroy() end

end

function deathByBlackHole( phase , fixtureA , fixtureB , arbiter )
  
    -- Get the object data
    local data = fixtureB:getUserData()
    local bHole = fixtureA:getUserData()
  
    if not bHole.alreadyEntered( data ) and not fixtureB.watchingOnly then

        -- First remove the body from the active list (we don't want it anymore!)
        if game_screen.activeObjectList[ data.id ] ~= nil then game_screen.activeObjectList[ data.id ] = nil end
        -- Disable it!
        fixtureB.watchingOnly = true

        -- Sound the swoosh
        screen.sound.playSound( "swoosh" .. math.random( 1 , 4 ) )

        local body = fixtureB:getBody()

        local dataPos = Vector2.new( data.body:getPosition() )
        local dataPosVect = Vector2.new( game_screen.objectLayer:worldToWnd( dataPos.x , dataPos.y ) )

        local bHolePos = Vector2.new( bHole.body:getPosition() )
        local bHolePosVect = Vector2.new(game_screen.objectLayer:worldToWnd( bHolePos.x , bHolePos.y ) )

        if data.prop then

            local directionToAnimate = screen.deviceToScaled( bHolePosVect - dataPosVect )

            -- Animations moving and scaling the object
            local scaleAnimation = data.prop:moveScl( -1 , -1 , 1 , MOAIEaseType.EASE_IN )
            local moveAnimation = data.prop:moveLoc( 
                directionToAnimate.x , 
                -directionToAnimate.y , 
                1 , 
                MOAIEaseType.EASE_IN 
            )

            local suckAnimation = MOAIAction.new()
            suckAnimation:addChild( scaleAnimation )
            suckAnimation:addChild( moveAnimation )
            suckAnimation:start()

             -- And remove the prop
            suckAnimation:setListener( MOAIAction.EVENT_STOP , function( ) removeObject( data ) end )

        end

        if data.name ~= nil then
            
            if data.name == "candy" then

                -- Increase the size of the black hole
                acceptedByHole = bHole.objectEntered( data , { 
                    orbitalRadius = bHole.orbitalRadius + 25,
                    pullRadius = bHole.pullRadius + 25,
                    deathRadius = bHole.deathRadius + 10,
                    gravity = bHole.gravity + 12,
                })

            elseif data.name == "munchy" then
            
                -- Make munchy scream
                screen.sound.playSound( "munchyscream" )
                -- Fade out the UI!
                game_screen.ui.hideUI()
                -- Munchy entered (register it as such)
                bHole.objectEntered( data )
                -- Start a 3 second timeout before saying game over (animations will make it nice)
                if _timer ~= nil  and _timer:isBusy() then _timer:stop() end
                _timer = MOAITimer.new ()
                _timer:setMode ( MOAITimer.NORMAL )
                _timer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, gameOver)
                _timer:setSpan ( 1.5 )
                _timer:start ()
            end
        end
        
        body:destroy()
        body = nil
    end
end

function munchyHitsSomething( phase , fixtureA , fixtureB , arbiter )
  
    if type ( fixtureB.getUserData ) == "function" and not fixtureB.watchingOnly and phase == MOAIBox2DArbiter.BEGIN then 

        local data = fixtureB.getUserData()
        local munchy = fixtureA.getUserData()
      
        if munchy.name == "munchy" and data.name ~= nil then

            if data.name == "candy" and ( munchy.isDizzy == nil or munchy.isDizzy == false ) then

                -- First remove the body from the active list (we don't want it anymore!)
                if game_screen.activeObjectList[ data.id ] ~= nil then game_screen.activeObjectList[ data.id ] = nil end
                
                if type( munchy.eatCandyCollision ) == "function" then
                    munchy.eatCandyCollision( phase , fixtureA , fixtureB , arbiter )
                end
                
                if data.prop then

                    local dataPos = Vector2.new( data.body:getPosition() )
                    local dataPosVect = Vector2.new( game_screen.objectLayer:worldToWnd( dataPos.x , dataPos.y ) )

                    local munchyPos = Vector2.new( munchy.body:getPosition() )
                    local munchyPosVect = Vector2.new(game_screen.objectLayer:worldToWnd( munchyPos.x , munchyPos.y ) )

                    -- Animations moving and scaling the object
                    local scaleAnimation = data.prop:moveScl( -0.2 , -0.2 , 0.2 , MOAIEaseType.EASE_IN )
                    local moveAnimation = data.prop:moveLoc( ( munchyPosVect.x - dataPosVect.x ) / 2 , ( munchyPosVect.y + 40 - dataPosVect.y ) / -2 , 0.2 , MOAIEaseType.EASE_IN )
                    local colorAnimation = data.prop:seekColor( 0.4 , 0.4 , 0.4 , 0.8 , 0.2 , MOAIEaseType.EASE_IN )

                    local eatAnimation = MOAIAction.new()
                    eatAnimation:addChild( scaleAnimation )
                    eatAnimation:addChild( moveAnimation )
                    eatAnimation:addChild( colorAnimation )
                    eatAnimation:start()

                     -- And remove the prop
                    eatAnimation:setListener( MOAIAction.EVENT_STOP , function( ) removeObject( data ) end )

                end
                -- Add the score!
                game_screen.ui.setScore( game_screen.ui.getScore() + 20 )
                
                data.body:destroy()
                data.body = nil
            end
            
            if data.name == "rock" and type( munchy.setDizzy ) == "function" then
              
                if phase == MOAIBox2DArbiter.BEGIN then
                  
                    local rockVeolcity = Vector2.new( data.body:getLinearVelocity( ) )
                    data.body:setLinearVelocity( rockVeolcity.x / 2 , rockVeolcity.y / 2 )
                  
                    screen.sound.playSound( "munchydizzy" )
                    screen.sound.playSound( "slap" )
                    screen.sound.playSound( "dizzy" )
                  
--                    -- First remove the body from the active list (we don't want it anymore!)
                    game_screen.pushMagnet.ignoreBodyName[ "munchy" ] = true
                    game_screen.pullMagnet.ignoreBodyName[ "munchy" ] = true

--                    -- And we set munchy to dizzy and afterwards we remove the ignore
                    munchy.setDizzy( function()
                        game_screen.pushMagnet.ignoreBodyName[ "munchy" ] = nil
                        game_screen.pullMagnet.ignoreBodyName[ "munchy" ] = nil
                    end )
                end
            end
        end
    end
end

function fireBallHitsSomething( phase , fixtureA , fixtureB , arbiter )

    if type ( fixtureB.getUserData ) == "function" and not fixtureB.watchingOnly then

        local data = fixtureB.getUserData()
        local fireball = fixtureA.getUserData()

        if data.name ~= nil then

            -- First remove the body from the active list (we don't want it anymore!)
            if game_screen.activeObjectList[ data.id ] ~= nil then game_screen.activeObjectList[ data.id ] = nil end

            if data.name == "munchy" then
              
                -- For demonstration purposes
                screen.device.addAchievement( "munchy.firstcomet" )
              
                data.body:destroy()
                data.body = nil
                -- Munchy hit sound
                screen.sound.playSound( "munchyhit" )
              
                -- Remove munchy
                data.prop:setParent( fireball.prop )
                data.prop:setLoc( 130 , 0 )
                data.setDizzy()
                
                -- Fade out the UI!
                game_screen.ui.hideUI()
                -- Start a second timeout before saying game over (animations will make it nice)
                if _timer ~= nil  and _timer:isBusy() then _timer:stop() end
                _timer = MOAITimer.new ()
                _timer:setMode ( MOAITimer.NORMAL )
                _timer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, gameOver)
                _timer:setSpan ( 2 )
                _timer:start ()
            end
            
            if data.name == "candy" or data.name == "rock" then
                game_screen.objectLayer:removeProp( data.prop )
                data.body:destroy()
                data.body = nil
                if type( data.destroy ) == "function" then data.destroy() end
            end

        end

    end

end

function objectHitsOuterSpace( side , phase , fixtureA , fixtureB , arbiter )
  
    if type ( fixtureB.getUserData ) == "function" then 

        local data = fixtureB.getUserData()

        if data.name ~= nil then

            -- First remove the body from the active list (we don't want it anymore!)
            if game_screen.activeObjectList[ data.id ] ~= nil then game_screen.activeObjectList[ data.id ] = nil end

            if data.name == "munchy" then
              
                if data.body ~= nil then 
                    data.body:destroy()
                    data.body = nil
                end
                
                 -- Fade out the UI!
                game_screen.ui.hideUI()
                -- Start a second timeout before saying game over (animations will make it nice)
                if _timer ~= nil  and _timer:isBusy() then _timer:stop() end
                _timer = MOAITimer.new ()
                _timer:setMode ( MOAITimer.NORMAL )
                _timer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, gameOver)
                _timer:setSpan ( 0.3 )
                _timer:start ()
            
            end
          
            if data.name == "candy" or data.name == "rock" or data.name == "fireball" then
                game_screen.objectLayer:removeProp( data.prop )
                if data.body ~= nil then 
                    data.body:destroy()
                    data.body = nil
                end
                if type( data.destroy ) == "function" then data.destroy() end
            end
        end
    end
  
end

local function clearFingers( ) 
    
    for idx , finger in pairs( game_screen.fingers ) do
        removeFinger( idx )
    end
    -- A table containing touches
    game_screen.fingers = {}
  
end

local _isGameOver = false

function gameOver( )
      
      if not _isGameOver then
        
          _isGameOver = true
        
          local score = game_screen.ui.getScore()
          local time = game_screen.ui.getTime()
          
          screen.pause() 
          
          screen.device.addScore( time , "munchy.survival" )
          screen.device.addScore( score , "munchy.highscores" )
          
          game_screen.ui.showGameOverScreen( game_screen.elapsedTime ) 
      end
end

function game_screen.pause ( )
  
    _paused = true
    clearFingers()
    game_screen.world:pause()
    
    if _timer ~= nil  and _timer:isBusy() then _timer:pause() end
    
    -- All objects should execute their own destroy
    for id, body in pairs(game_screen.activeObjectList) do
        if type ( body.pause ) == "function" then
            body.pause()
        end
    end
  
    for i, grav in pairs(game_screen.gravitationalForces) do
        if type ( grav.pause ) == "function" then
            grav.pause()
        end
    end
  
end

function game_screen.resume( )
  
    _previousElapsedTime = MOAISim.getDeviceTime()
    _paused = false
    game_screen.world:start()
  
    if _timer ~= nil  and _timer:isBusy() then _timer:start() end
  
    -- All objects should execute their own destroy
    for id, body in pairs(game_screen.activeObjectList) do
        if type ( body.resume ) == "function" then
            body.resume()
        end
    end
  
    for i, grav in pairs(game_screen.gravitationalForces) do
        if type ( grav.resume ) == "function" then
            grav.resume()
        end
    end
  
end

---[[
-- The destroy method is called when the screen as soon
-- as it's no longer visible
--]]
function game_screen.destroy(  )

    clearFingers()
    
    _space.destroy()

    -- The next time candy will appear
    _nextRandomCandyTime = 0
    -- The next time candy will appear
    _nextRandomRockTime = 0
    -- The next time candy will appear
    _nextRandomFireballTime = 0

    -- Fixed update intervals
    _fixedUpdateInterval = ( 1 / 30 )
    _lastFixedUpdateInterval = 0

    -- Fix munchy dizzy
    game_screen.pushMagnet.ignoreBodyName[ "munchy" ] = false
    game_screen.pullMagnet.ignoreBodyName[ "munchy" ] = false

    -- All objects should execute their own destroy
    for id, body in pairs(game_screen.activeObjectList) do
        if type ( body.destroy ) == "function" then
            body.destroy()
        end
    end
  
    for i, grav in pairs(game_screen.gravitationalForces) do
        if type ( grav.destroy ) == "function" then
            grav.destroy()
        end
    end

    -- Clear all layers
    for x , layername in pairs( game_screen.layerNames ) do
        game_screen.getLayer( layername ):clear()
    end
    
    -- Reset the score!
    game_screen.ui.setScore( 0 )
    
    -- Clear the UI
    game_screen.ui.destroy()
    game_screen.ui = nil
    
    -- Clear all inputs
    input.clear()

    -- Elapsed Time
    game_screen.elapsedTime = 0

    -- The spawns
    game_screen.spawns = {}

    -- List of active bodies (used by Box2D)
    game_screen.activeObjectList = {}

    -- Add gravitational forces
    game_screen.gravitationalForces = {}
    
    if game_screen.backgroundLayer ~= nil then
        game_screen.backgroundLayer:clear()
        game_screen.backgroundLayer = nil
    end
    if game_screen.objectLayer ~= nil then
        game_screen.objectLayer:clear()
        game_screen.objectLayer = nil
    end
    if game_screen.UI ~= nil then
        game_screen.UI:clear()
        game_screen.UI = nil
    end
    
    if game_screen.world ~= nil then
        game_screen.world:clear()
        game_screen.world = nil
    end
    
    if game_screen.centerBlackHole ~= nil then
        game_screen.centerBlackHole.destroy()
    end
    
    _isGameOver = false

end

return game_screen