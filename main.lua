-- Just a bunch of globals for now
test_sprite = nil
test_x = 0
test_y = 0
test_vx = 50
test_vy = 50

pigeonFactory = require("src/pigeon")
--blah = require("src/arena")

local pigeonList = {}

function love.load(arg)
    -- initialise pigeons
    for i = 1, 5 do
      pigeonList[#pigeonList + 1] = pigeonFactory(i * 50, i * 50)
      pigeonList[#pigeonList]:initialise()
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
    
    -- update pigeons
    for i, pigeon in ipairs(pigeonList) do
      pigeon:update(dt)
    end
end

function love.draw(dt)
    -- draw pigeons
    for i, pigeon in ipairs(pigeonList) do
      pigeon:draw(dt)
    end
    --love.graphics.draw(blah)
end

