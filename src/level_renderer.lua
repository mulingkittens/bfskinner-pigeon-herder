levelSpriteSheet = love.graphics.newImage('assets/basic_ground_tiles.png')
local levelSpriteHeight = 128
local levelSpriteWidth = 128
local levelSpriteDepth = 128/2
local levelSpriteSheetRows = 6
local levelSpriteSheetColumns = 7

local levelSpriteSheetSprites = levelSpriteSheetRows * levelSpriteSheetColumns
local levelSpriteSheetWidth = levelSpriteSheet:getWidth()
local levelSpriteSheetHeight = levelSpriteSheet:getHeight()


return function(level_cfg)
    return setmetatable({
        levelSprites = {},
        grid_x = 0,
        grid_y = 0,
        --grid_x = 1024/2,
        --grid_y =  (3 * 896)/4,
        level_cfg = nil,
        spiteBatch = nil,
        
        initialise = function(self)
            self.level_cfg = level_cfg
            for x=1, levelSpriteSheetRows do 
                self.levelSprites[x] = {}
                for y=1, levelSpriteSheetColumns do
                    self.levelSprites[x][y] = love.graphics.newQuad(x*levelSpriteWidth, y*levelSpriteHeight, levelSpriteWidth, levelSpriteHeight, levelSpriteSheetWidth, levelSpriteSheetHeight)
                end
            end
        end,
        
        batchSpritesForLevel = function(self, grid_x, grid_y, level_cfg)
            print("grid x", grid_x, "grid y", grid_y)
            spriteBatch = love.graphics.newSpriteBatch(levelSpriteSheet, levelSpriteWidth * levelSpriteHeight)
            for x, row in ipairs(level_cfg.map_grid) do
                print("X", x)
                for y, char in ipairs(row) do
                    print("y", y)
                    spriteBatch:add(self.levelSprites[math.random(1, 6)][math.random(1,4)], 
                        grid_x + ((y-x) * (levelSpriteWidth/2)), 
                        grid_y + ((x+y) * (levelSpriteDepth/2)) - (levelSpriteDepth * (#char/2))
                    )
                end
            end
            spriteBatch:flush()
            print(spriteBatch:getCount(), spriteBatch:getTexture(), spriteBatch:getBufferSize())
            return spriteBatch
        end,
        
        draw = function(self)
            if not self.spriteBatch then
                self.spriteBatch = self:batchSpritesForLevel(self.grid_x, self.grid_y, self.level_cfg)
            end
            love.graphics.draw(self.spriteBatch)
                
        end,
        
        update = function(self, grid_x, grid_y)
            --self.grid_x = grid_x
            --self.grid_y = grid_y
        end
    }, {})
end            