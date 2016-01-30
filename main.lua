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

  -- Sprites
  Sprites = {
    Pigeon = love.graphics.newImage('assets/pigeon.png')
  },

  -- All pigeons
  Pigeons = {},
}

PigeonFactory = require("src/pigeon")
--blah = require("src/arena")

function love.load(arg)
  -- Set window size
  love.window.setMode(1280, 720, {
    minwidth = 640,
    minheight = 360,
    -- fullscreen = true,
    -- fullscreentype = "desktop",
    vsync = true,
    resizable = true,
  })

  -- Default background color
  love.graphics.setBackgroundColor(255, 255, 255)

    -- initialise pigeons
    local pigeons = Game.Pigeons
    for i = 1, 5 do
      pigeons[#pigeons + 1] = PigeonFactory(i * 50, i * 50)
    end
end

function love.update(dt)
  -- Update the screen scale to match the window
  Game.Screen.scale = love.graphics.getWidth() / Game.Screen.width
  Game.Screen.offset_x = (love.graphics.getWidth() - (Game.Screen.width * Game.Screen.scale)) / 2
  Game.Screen.offset_y = (love.graphics.getHeight() - (Game.Screen.height * Game.Screen.scale)) / 2

    -- update pigeons
    for i, pigeon in ipairs(Game.Pigeons) do
      pigeon:update(Game, dt)
    end
end

function love.draw(dt)
  love.graphics.push()
  local _r, _g, _b, _a = love.graphics.getColor()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.translate(Game.Screen.offset_x, Game.Screen.offset_y)
  love.graphics.scale(Game.Screen.scale, Game.Screen.scale)

    -- draw pigeons
    for i, pigeon in ipairs(Game.Pigeons) do
      pigeon:draw(Game, dt)
    end
    --love.graphics.draw(blah)

  love.graphics.setColor(_r, _g, _b, _a)
  love.graphics.pop()
end

function love.mousepressed(x, y, button, istouch)
  -- Convert coordinates into game space
  x = x / Game.Screen.scale
  y = y / Game.Screen.scale

  -- Spawn a new pigeon there
  local pigeons = Game.Pigeons
  pigeons[#pigeons + 1] = PigeonFactory(
    x - Game.Sprites.Pigeon:getWidth() / 2,
    y - Game.Sprites.Pigeon:getHeight() / 2)
end
