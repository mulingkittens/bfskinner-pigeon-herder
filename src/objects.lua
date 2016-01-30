require("src/util")

return {

create_pen = function(x, y, numPigeons)

    local newPen = setmetatable({
        
        x = x,
        y = y,
        numPigeons = numPigeons,
        spawnTimer = 0,
        
        update = function(self, dt)
        
            -- Decrement spawn timer
            self.spawnTimer = self.spawnTimer - pigeonPenSpawnTimerDecrement
            if self.spawnTimer <= 0 then
                self.spawnTimer = 0
            end
            
        end,
         
        draw = function(self, dt)
        
            love.graphics.draw(Game.Sprites.Pen, self.x, self.y)
        
        end,
    
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

    return newPen
end,

create_barrier = function(x, y)
    
    local newBarrier = setmetatable({
        
        x = x,
        y = y,
        
        update = function(self, dt)
        
            --update
        
        end,
         
        draw = function(self, dt)
        
            love.graphics.draw(Game.Sprites.Barrier, self.x, self.y)
        
        end,
    
        get_occlusion_block = function(self)
        
            return Rect(self.x, self.y, 150, 150)
        
        end,
        
    }, {

        __tostring = function(self)
        
            return "barrier"
        
        end

    })
    
    return newBarrier
end,

create_goal = function(x, y)
    
    local newGoal = setmetatable({
        
        x = x,
        y = y,
        
        update = function(self, dt)
        
            --update
        
        end,
         
        draw = function(self, dt)
        
            love.graphics.draw(Game.Sprites.Goal, self.x, self.y)
        
        end
        
    }, {

        __tostring = function(self)
        
            return "goal"
        
        end

    })

    return newGoal
end

}

