SpriteManager = require("src/sprite_loader/sprite_manager")

local spriteX = 128
local spriteY = 128
local scalex = 1
local scaleY = 1

return function()
    --local parent = SpriteManager("assets/basic_ground_tiles.png")
    local parent = SpriteManager("assets/sprites.png")
    local obj = setmetatable({
        entities = {},
        quadifySprites = function(self)
            local sheetWidth = self.spriteSheet:getWidth()
            local sheetHeight = self.spriteSheet:getHeight()
            --[[--self.sprites["grass"] = love.graphics.newQuad(0, 0, 128, 128, sheetWidth, sheetHeight)
            self.sprites["rocks"] = love.graphics.newQuad(128*2, 0, 128, 128, sheetWidth, sheetHeight)
            self.sprites["pen"] = love.graphics.newQuad(128*3, 0, 128, 128, sheetWidth, sheetHeight)
            self.sprites["wall"] = love.graphics.newQuad(128*3, 128*3, 128, 128, sheetWidth, sheetHeight) 
            self.sprites["goal"] = love.graphics.newQuad(128*3, 128*1, 128, 128, sheetWidth, sheetHeight) --]]--
            self.sprites["grass"] = love.graphics.newQuad(0, 0, spriteX, spriteY, sheetWidth, sheetHeight)
            self.sprites["rocks"] = love.graphics.newQuad(0, 128, spriteX, spriteY, sheetWidth, sheetHeight)
            self.sprites["pen"] = love.graphics.newQuad(0, 128, spriteX, spriteY, sheetWidth, sheetHeight)
            self.sprites["wall"] = love.graphics.newQuad(128, 0, spriteX, spriteY, sheetWidth, sheetHeight)
            self.sprites["goal"] = love.graphics.newQuad(128, 128, spriteX, spriteY, sheetWidth, sheetHeight)
        end,
        
        reset = function(self)
             self.spriteBatch = nil   
        end,
                
        batchSprites = function(self)
            local sheetWidth = self.spriteSheet:getWidth()
            local sheetHeight = self.spriteSheet:getHeight()
            local spriteBatch = love.graphics.newSpriteBatch(self.spriteSheet, spriteX * spriteY)
            for x, row in pairs(self.entities) do
                for y, entity in pairs(row) do
                    if type(x) == 'number' and type(y) == 'number' then
                        spriteBatch:add(entity:quad(), (x-1)*spriteX*scalex, (y-1)*spriteY*scaleY)
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
            end
            love.graphics.draw(self.spriteBatch)
        end
    }, {__index = function(self, index) 
            return rawget(self, index) or parent[index] 
            end})

    obj:quadifySprites()
    return obj
end
