require("src/util")

return function(numPigeons, LevelEntites)
    return function(x, y)
        local newPen = setmetatable({
            
            x = (x-1) * 128,
            y = (y-1) * 128,
            
            numPigeons = numPigeons,
            spawnTimer = 0,
            
            quad = function(self)
                return LevelEntites.sprites["pen"]
            end,
            
            update = function(self, dt)
                -- Decrement spawn timer
                self.spawnTimer = self.spawnTimer - pigeonPenSpawnTimerDecrement
                if self.spawnTimer <= 0 then
                    self.spawnTimer = 0
                end
            end,
             
            --[[--draw = function(self, dt)
            
                love.graphics.draw(Game.Sprites.Pen, self.x, self.y)
            
            end,--]]--
        
            get_occlusion_block = function(self)
            
                return Rect(self.x, self.y + 100, 150, 50)
            
            end,
        
            spawn_pigeon = function(self)

                if (self.spawnTimer == 0) and (self.numPigeons > 0) then
                    
                    self.numPigeons = self.numPigeons - 1
                    
                    self.spawnTimer = pigeonPenSpawnTime
                    
                    return PigeonFactory(self.x + 75, self.y + 50)
                else
                
                    return nil
                
                end
                
            end
            
        }, {
            __tostring = function(self)
                return "pen"
            end
        })
        LevelEntites:addEntity(x, y, newPen)
        return newPen
    end
end

