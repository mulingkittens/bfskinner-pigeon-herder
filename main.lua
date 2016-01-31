require("src/variables")

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

Game = {
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

  -- Debug mode (options are ignored unless "debug" argument is given on command line)
  Debug = {
    draw_actions = true,
    draw_bounding_boxes = true,
  },

  -- Sprites
  Sprites = {
    Pigeon = love.graphics.newImage('assets/pigeon.png'),
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
        capturedPigeons = 0
    },

  -- Pigeons
  Pigeons = {},
  
  -- Obejcts
  Objects = {},
  
  -- Level
  LevelGrid = false,
  
  -- TODO(Gordon): Integrate objects with the level loader
  Objects = {
    activeInstances = {},
    default_constructors = setmetatable({
            P = Pen(10, level), --Additionally takes number of pigeons to spawn, can override on level specifics
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
}

Game.Level = level
--LoadLevel requires Game in scope
Game.LevelGrid = LoadLevel("level_test")

feedRadiusShowingTimer = 0
feedRadiusX = 0
feedRadiusY = 0

function love.load(args)
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
    
    -- Initialise level objects
    --[[--local objects = Game.Objects
    objects[#objects + 1] = ObjectFactory.create_pen(150, 750, 4)
    
    for i = 0, 11 do
        objects[#objects + 1] = ObjectFactory.create_barrier(i * 150, 0)
        objects[#objects + 1] = ObjectFactory.create_barrier(i * 150, 900)
    end
    
    for i = 1, 5 do
        objects[#objects + 1] = ObjectFactory.create_barrier(0, i * 150)
        objects[#objects + 1] = ObjectFactory.create_barrier(1650, i * 150)
    end
    
    for i = 5, 6 do
        objects[#objects + 1] = ObjectFactory.create_barrier(i * 150, 450)
    end
    
    objects[#objects + 1] = ObjectFactory.create_goal(1500, 150)--]]--
    
end
    
function love.update(dt)
    
    -- Update the screen scale to match the window
    Game.Screen.scale = love.graphics.getWidth() / Game.Screen.width
    Game.Screen.offset_x = (love.graphics.getWidth() - (Game.Screen.width * Game.Screen.scale)) / 2
    Game.Screen.offset_y = (love.graphics.getHeight() - (Game.Screen.height * Game.Screen.scale)) / 2

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
end

function love.draw(dt)
    love.graphics.push()
    love.graphics.translate(Game.Screen.offset_x, Game.Screen.offset_y)
    love.graphics.scale(Game.Screen.scale, Game.Screen.scale)
    
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

    love.graphics.pop()
end

function love.keypressed(key, isrepeat)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button, istouch)
    -- Convert coordinates into game space
    local mouseX = x / Game.Screen.scale
    local mouseY = y / Game.Screen.scale

    local pigeonWidth = Game.Sprites.Pigeon:getWidth()
    local pigeonHeight = Game.Sprites.Pigeon:getHeight()

    -- check each pigeon's position relative to the mouse
    for i, pigeon in ipairs(Game.Pigeons) do

        local pigeonLeft = pigeon.x
        local pigeonTop = pigeon.y
        local pigeonRight = pigeon.x + pigeonWidth
        local pigeonBottom = pigeon.y + pigeonHeight
        local pigeonCentreX = pigeon.x + (pigeonWidth / 2)
        local pigeonCentreY = pigeon.y + (pigeonHeight / 2)

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
end