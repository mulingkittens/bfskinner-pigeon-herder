-- Just a bunch of globals for now
test_sprite = nil
test_x = 0
test_y = 0
test_vx = 50
test_vy = 50

function love.load(arg)
    -- Game setup
    test_sprite = love.graphics.newImage('assets/test.png')
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
end

function love.draw(dt)
    -- Draw things
    love.graphics.draw(test_sprite, test_x, test_y)
end

