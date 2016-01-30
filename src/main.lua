-- Just a bunch of globals for now
test_sprite = nil
test_x = 0
test_y = 0
test_vx = 50
test_vy = 50

pigeonFactory = require("pigeon")

local pigeonList = {}

function love.load(arg)
    -- Game setup
    -- test_sprite = love.graphics.newImage('../assets/test.png')
    
    for i = 1, 5 do
    
      pigeonList[#pigeonList+1] = pigeonFactory(i * 50, i * 50)
    
    end
end

function love.update(dt)
    -- Update game state
    test_x = test_x + test_vx * dt
    test_y = test_y + test_vy * dt
    if test_x > 100 or test_x < 0 then
        test_vx = -test_vx
    end
    if test_y > 100 or test_y < 0  then
        test_vy = -test_vy
    end
    
    for i, pigeon in ipairs(pigeonList) do
    
      pigeon:update(dt)
    
    end
end

function love.draw(dt)
    -- Draw things
    -- love.graphics.draw(test_sprite, test_x, test_y)
    
    for i, pigeon in ipairs(pigeonList) do
    
      pigeon:draw(dt)
    
    end
end

