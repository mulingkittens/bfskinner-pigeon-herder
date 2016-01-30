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

print("Quadding", "x+1", "y+1", "x", "y", "x*sprite_w", "y*sprite_h", "x+sprite_w", "y+sprite_h", "image_w", "image_h")
for x=0, number_of_sprites_x do 
    sprites[x+1] = {}
    for y=0, number_of_sprites_y do
        print("Quadding", x+1, y+1, x, y, x*sprite_w, y*sprite_h, x+sprite_w, y+sprite_h, image_w, image_h)
        offset_x = x*sprite_w
        offset_y = y*sprite_h
        sprites[x+1][y+1] = love.graphics.newQuad(offset_x, offset_y, sprite_w, sprite_h, image_w, image_h)
    end
end
 
 
batch = love.graphics.newSpriteBatch(isometricSpriteSheet, sprite_w * sprite_w)

grid_x = 1024/2
grid_y =  (3 * 896)/4

for x=1, grid_size do 
    for y=1, grid_size do
        --sprites[math.random(0, 8)][math.random(0,7)]
        batch:add(sprites[math.random(1, 8)][math.random(1,5)], 
            grid_x + ((y-x) * (sprite_w/2)), 
            grid_y + ((x+y) * (sprite_depth/2)) - (sprite_depth * (grid_size/2))
            )
    end
end
batch:flush()

return batch
