require("src/variables")
ParticleFactory = require("src/particles")
Menu = {

    main = {
        
        update = function(dt)
            
           -- update
           
        end,
        
        draw = function(dt)
            
            love.graphics.draw(Game.Sprites.Menu.main)
            
        end,
        
        mousepressed = function(x, y, button, istouch)
        
            --mouse pressed
        
        end,
    
        keypressed = function(key, isrepeat)
        
            if key == 'space' then
               Game.Menu = Menu.play
            end
            if key == 'i' then
               Game.Menu = Menu.howtoplay
            end
            if key == 'c' then
               Game.Menu = Menu.credits
            end
        
        end
        
    },
    
    howtoplay = {
        
        update = function(dt)
            
           -- update
           
        end,
        
        draw = function(dt)
            
            --draw
            
        end,
        
        mousepressed = function(x, y, button, istouch)
        
            -- mouse pressed
        
        end,
    
        keypressed = function(key, isrepeat)
        
            if key == 'space' then
               Game.Menu = Menu.main
            end
        
        end
        
    },
    
    gameover = {
        
        update = function(dt)
            
           -- update
           
        end,
        
        draw = function(dt)
            
            --draw
            
        end,
        
        mousepressed = function(x, y, button, istouch)
        
            -- mouse pressed
        
        end,
    
        keypressed = function(key, isrepeat)
        
            if key == 'space' then
               Game.Menu = Menu.main
            end
        
        end
        
    },
    
    credits = {
        
        update = function(dt)
            
           -- update
           
        end,
        
        draw = function(dt)
            
            love.graphics.draw(Game.Sprites.Menu.credits)
            
        end,
        
        mousepressed = function(x, y, button, istouch)
        
            if key == 'space' then
               Game.Menu = Menu.main
            end
        
        end,
    
        keypressed = function(key, isrepeat)
        
            -- key pressed
        
        end
        
    },
    
    play = {
        
        update = function(dt)
            
            -- Update objects
            for i, object in ipairs(Game.Objects.activeInstances) do
                if object.update then
                    object:update(dt)
                end
            
                -- Spawn pigeons from pen objects
                if tostring(object) == "pen" then
                    local pigeons = Game.Pigeons
                    newPigeon = object:spawn_pigeon()
                    if newPigeon then
                        pigeons[#pigeons + 1] = newPigeon
                    end
                end
                
                -- Capture pigeons from goal objects
                if tostring(object) == "goal" then
                    object:capture_pigeon()
                end
            end
            
            -- Update pigeons
            for i, pigeon in ipairs(Game.Pigeons) do
                pigeon:update(dt)
                
                -- If pigeon is dead remove him from the game
                if not pigeon:isAlive() then
                    table.remove(Game.Pigeons, i)
                end
            end

            -- Decrement the feed radius timer
            feedRadiusShowingTimer = feedRadiusShowingTimer - dt;
            if feedRadiusShowingTimer <= 0 then
                feedRadiusShowingTimer = 0
            end
           
        end,
        
        draw = function(dt)
            
            --Draw backgrounds
            Game.Level:draw()
            
            -- Draw objects
            for i, object in ipairs(Game.Objects) do
              object:draw(dt)
            end

            -- Draw pigeons
            for i, pigeon in ipairs(Game.Pigeons) do
                pigeon:draw(Game, dt)
            end
            
                -- Draw the feed radius if showing
            if feedRadiusShowingTimer > 0 then
                love.graphics.draw(Game.Sprites.FeedRadius, feedRadiusX, feedRadiusY)
            end
            
        end,
        
        mousepressed = function(x, y, button, istouch)
        
            -- Convert coordinates into game space
            local mouseX = x / Game.Screen.scale
            local mouseY = y / Game.Screen.scale

            -- check each pigeon's position relative to the mouse
            for i, pigeon in ipairs(Game.Pigeons) do

                local pigeonLeft = pigeon.x
                local pigeonTop = pigeon.y
                local pigeonRight = pigeon.x + pigeon.rect.w
                local pigeonBottom = pigeon.y + pigeon.rect.h
                local pigeonCentreX = pigeon.x + (pigeon.rect.w / 2)
                local pigeonCentreY = pigeon.y + (pigeon.rect.h / 2)

                if pigeonFeedByRadius then
                
                    -- add the feed radius display
                    feedRadiusShowingTimer = pigeonFeedRadiusDisplayTime
                    feedRadiusX = mouseX - (pigeonFeedRadius / 2)
                    feedRadiusY = mouseY - (pigeonFeedRadius / 2)
                
                    -- check if the pigeon is within the feed range
                    local distanceFromMouse = ((mouseX-pigeonCentreX)^2+(mouseY-pigeonCentreY)^2)^0.5

                    if distanceFromMouse <= pigeonFeedRadius then
                    
                        -- feed the pigeon
                        pigeon:feed()
                    
                    end
                
                else
                
                    -- check if the pigeon is under the cusor
                    if (mouseX > pigeonLeft) and (mouseX < pigeonRight) and
                        (mouseY > pigeonTop) and (mouseX < pigeonBottom) then
                       
                        -- feed the pigeon under the cursor
                        pigeon:feed()
                    end
                end
            end
        
        end,
    
        keypressed = function(key, isrepeat)
        
            if key == 'escape' then
                love.event.quit()
            elseif key == 'n' then
                if Game.CurrentLevel + 1 > #Game.PlayableLevels then
                    Game.CurrentLevel = (Game.CurrentLevel - #Game.PlayableLevels) + 1
                else
                    Game.CurrentLevel = Game.CurrentLevel + 1
                end
                Game.LevelGrid = LoadLevel(Game.PlayableLevels[Game.CurrentLevel])
                print("SKIPPING TO", Game.PlayableLevels[Game.CurrentLevel])
                Game:reset()
                love.load(Game.configArgs or {})
            end
        
        end
        
    }
    
}

Game = {
    
    -- Menu position
    Menu = Menu.main,
    
    -- Screen configuration
    Screen = {
        -- Coordinate system size
        width = 1920,
        height = 1080,
        -- Scale and offset to fit window
        scale = 1,
        offset_x = 0,
        offset_y = 0,
    },
    
    PlayableLevels = {
        "level1",
        "level2",
        "level3",
        "level9",
    },
    
    CurrentLevel = 1,

  -- Debug mode (options are ignored unless "debug" argument is given on command line)
  Debug = {
    draw_actions = true,
    draw_bounding_boxes = true,
  },

  -- Sprites
  Sprites = {
    Pigeon = {
        hop = love.graphics.newImage('assets/pigeon/hop.png'),
        look = love.graphics.newImage('assets/pigeon/look.png'),
        move1 = love.graphics.newImage('assets/pigeon/move1.png'),
        move2 = love.graphics.newImage('assets/pigeon/move2.png'),
        peck = love.graphics.newImage('assets/pigeon/peck.png'),
    },
    Menu = {
        main = love.graphics.newImage('assets/mainmenu.png') -- ,
        -- credits = love.graphics.newImage('assets/credits.png')
    },
    FeedRadius = love.graphics.newImage('assets/feed_radius.png'),
    Pen = love.graphics.newImage('assets/pen.png'),
    Barrier = love.graphics.newImage('assets/barrier.png'),
    Goal = love.graphics.newImage('assets/goal.png')
  },
  
    -- Level state
    LevelState = {
        timeRunning = 0,
        totalPigeons = 10,
        deadPigeons = 0,
        capturedPigeons = 0,
        ambientAudio = {},
    },

    -- Pigeons
    Pigeons = {},

    -- Level
    LevelGrid = false,
      
    reset = function(self)
        self.Pigeons = {}
        self.LevelState =  {
            timeRunning = 0,
            totalPigeons = 10,
            deadPigeons = 0,
            capturedPigeons = 0
        }
        self.Level:reset()
        self.Objects:reset()
        self.LevelGrid = LoadLevel(self.PlayableLevels[self.CurrentLevel])
    end
    
}

-- Import other modules
GetAudioManager = require("src/audio")
PigeonFactory = require("src/pigeon")
PenFactory = pcall(require, "src/pen") -- TODO
--ObjectFactory = require("src/objects")
LoadLevel = require("src/loader")

--level entities
LevelManager = require("src/levels/level_entities")
Grass = require("src/levels/grass")
Pit = require("src/levels/pit")
Wall = require("src/levels/wall")
Pen = require("src/levels/pen")
Goal = require("src/levels/goal")

local level = LevelManager()
--Wrap the Pigeon Factory in a constructor tat should allow it to be added to the sprite batch

Game.Level = level

-- TODO(Gordon): Integrate objects with the level loader
Game.Objects = {
    reset = function(self)
        self.activeInstances = {}
    end,
    
    activeInstances = {},
    default_constructors = setmetatable({
        P = Pen(20, level), --Additionally takes number of pigeons to spawn, can override on level specifics
        S = Pit(level),
        G = Goal(level),
        [" "] = Grass(level), 
        ["|"] = Wall(level),
        ["-"] = Wall(level),
    },
    {
        __index = function(self, idx)
            return rawget(self, idx) or function() end
        end
    })
}

--LoadLevel requires Game in scope
Game.LevelGrid = LoadLevel(Game.PlayableLevels[Game.CurrentLevel])

feedRadiusShowingTimer = 0
feedRadiusX = 0
feedRadiusY = 0

function love.load(args)
    Game.configArgs = args
    
    -- Look for args
    local fullscreen = false
    local debug = false
    
    for _, arg in ipairs(args) do
        if arg == "fullscreen" then
            fullscreen = true
        elseif arg == "debug" then
            debug = true
        end
    end
    
    -- Set window size
    local flags = {
        minwidth = 640,
        minheight = 360,
        fullscreen = arg.fullscreen or false,
        vsync = true,
        resizable = true,
    }
    
    if fullscreen then
        flags.fullscreen = true
        flags.fullscreentype = "desktop"
    end
    
    -- Set window dimensions and mode
    love.window.setMode(1280, 720, flags)
    
    -- Set debug mode
    if not debug then
        Game.Debug = {}
    end  

    -- seed random number generator
    love.math.setRandomSeed(love.timer.getTime())

    -- Default background color
    love.graphics.setBackgroundColor(255, 255, 255)

end
    
function love.update(dt)
    
    -- Update the screen scale to match the window
    Game.Screen.scale = love.graphics.getWidth() / Game.Screen.width
    Game.Screen.offset_x = (love.graphics.getWidth() - (Game.Screen.width * Game.Screen.scale)) / 2
    Game.Screen.offset_y = (love.graphics.getHeight() - (Game.Screen.height * Game.Screen.scale)) / 2

    -- Update current menu
    Game.Menu.update(dt)

    -- render audio last after events have been processed
    local am = GetAudioManager()
    am:update()
    am:start(Game.LevelState.ambientAudio)

end

function love.draw(dt)
    love.graphics.push()
    love.graphics.translate(Game.Screen.offset_x, Game.Screen.offset_y)
    love.graphics.scale(Game.Screen.scale, Game.Screen.scale)
    
    -- Draw current menu
    Game.Menu.draw(dt)

    love.graphics.pop()
end

function love.keypressed(key, isrepeat)
    
    -- Update current menu
    Game.Menu.keypressed(key, isrepeat)
    
end

function love.mousepressed(x, y, button, istouch)
    
    -- Update current menu
    Game.Menu.mousepressed(x, y, button, istouch)

end
