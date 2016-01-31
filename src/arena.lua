local isometricSpriteSheet = love.graphics.newImage('assets/basic_ground_tiles.png')
local image_w = isometricSpriteSheet:getWidth()
local image_h = isometricSpriteSheet:getHeight()

local sprite_w = 128
local sprite_h = 128
local sprite_depth = 128/2

local grid_size = 20
local number_of_sprites_x = 8
local number_of_sprites_y = 7
local number_of_sprites = number_of_sprites_x * number_of_sprites_y

sprites = {}

for x=1, number_of_sprites_x do 
    sprites[x] = {}
    for y=1, number_of_sprites_y do
        sprites[x][y] = love.graphics.newQuad(x*sprite_w, y*sprite_h, sprite_w, sprite_h, image_w, image_h)
    end
end
 
 
batch = love.graphics.newSpriteBatch(isometricSpriteSheet, sprite_w * sprite_h)

grid_x = 1024/2
grid_y =  (3 * 896)/4

for x=1, grid_size do 
    for y=1, grid_size do
        batch:add(sprites[math.random(1, 6)][math.random(1,4)], 
            grid_x + ((y-x) * (sprite_w/2)), 
            grid_y + ((x+y) * (sprite_depth/2)) - (sprite_depth * (grid_size/2))
            )
    end
end
batch:flush()

print(batch:getCount(), batch:getTexture(), batch:getBufferSize())

return batch
