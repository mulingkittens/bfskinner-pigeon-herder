SpriteManager = require("src/sprite_loader/sprite_manager")

return function()
    local parent = SpriteManager("assets/basic_ground_tiles.png")
    local obj = setmetatable({
        entities = {},
        quadifySprites = function(self)
            local sheetWidth = self.spriteSheet:getWidth()
            local sheetHeight = self.spriteSheet:getHeight()
            self.sprites["grass"] = love.graphics.newQuad(0, 0, 128, 128, sheetWidth, sheetHeight)
            self.sprites["rocks"] = love.graphics.newQuad(128*2, 0, 128, 128, sheetWidth, sheetHeight)
            self.sprites["pen"] = love.graphics.newQuad(128*3, 0, 128, 128, sheetWidth, sheetHeight)
            self.sprites["wall"] = love.graphics.newQuad(128*3, 128*3, 128, 128, sheetWidth, sheetHeight) 
        end,
        
        batchSprites = function(self)
            local sheetWidth = self.spriteSheet:getWidth()
            local sheetHeight = self.spriteSheet:getHeight()
            local spriteBatch = love.graphics.newSpriteBatch(self.spriteSheet, 128 * 128)
            for x, row in pairs(self.entities) do
                for y, entity in pairs(row) do
                    if type(x) == 'number' and type(y) == 'number' then
                        spriteBatch:add(entity:quad(), (x-1)*128, (y-1)*128)
                    end
                end
            end
            spriteBatch:flush()
            return spriteBatch
        end,
        
        addEntity = function(self, x, y, obj)
            if not self.entities[x] then
                self.entities[x] = {}
            end
            self.entities[x][y] = obj
        end,
        
        draw = function(self)
            if not self.spriteBatch then
                self.spriteBatch = self:batchSprites()
                print("DRAWED")
            end
            love.graphics.draw(self.spriteBatch)
        end
    }, {__index = function(self, index) 
            return rawget(self, index) or parent[index] 
            end})

    obj:quadifySprites()
    return obj
end