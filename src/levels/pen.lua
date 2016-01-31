require("src/util")

return function(numPigeons, LevelEntites)
    -- Update level state with number of pigeons
    Game.LevelState.remainingPigeons = Game.LevelState.remainingPigeons + numPigeons
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
             
            post_draw = function(self, dt)
            
                penDisplay = self.numPigeons .. " left"
                
                love.graphics.print(penDisplay, self.x, self.y)
                
            end, 
        
            get_occlusion_block = function(self)
            
                return nil
            
            end,
        
            spawn_pigeon = function(self)
                local spawnRect = Rect(self.x + 40, self.y + 20, Game.Sprites.Pigeon.move1:getWidth(), Game.Sprites.Pigeon.move1:getHeight())
                local spawnLocationAvailable = true
                
                for i, pigeon in ipairs(Game.Pigeons) do
                    local pigeonRect = Rect(pigeon.x, pigeon.y, pigeon.rect.w, pigeon.rect.h)
                    if spawnRect:intersects(pigeonRect) then
                        spawnLocationAvailable = false
                    end
                end
                
                if (self.spawnTimer == 0) and (self.numPigeons > 0) and (spawnLocationAvailable) then
                    
                    self.numPigeons = self.numPigeons - 1
                    
                    self.spawnTimer = pigeonPenSpawnTime
                    
                    return PigeonFactory(self.x + 40, self.y + 20)
                    
                else
                
                    return nil
                
                end
                --[[--if (self.spawnTimer == 0) and (self.numPigeons > 0) then
                    
                    self.numPigeons = self.numPigeons - 1
                    
                    self.spawnTimer = pigeonPenSpawnTime
                    
                    return PigeonFactory(self.x + 75, self.y + 50)
                else
                
                    return nil
                
                end--]]--
                
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

