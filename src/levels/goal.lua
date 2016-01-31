return function(LevelEntites)
    return function(x, y)
        local newGoal = setmetatable({
            
            x = (x-1) * 128,
            y = (y-1) * 128,
            
            quad = function(self)
                 return LevelEntites.sprites["goal"]
            end,
            
            update = function(self, dt)
            
                --update
            
            end,
             
            draw = function(self, dt)
            
                love.graphics.draw(Game.Sprites.Goal, self.x, self.y)
                
            end,
            
            get_occlusion_block = function(self)
            
                return Rect(0, 0, 1, 1)
            
            end,
            
        }, {

            __tostring = function(self)
            
                return "goal"
            
            end

        })
        LevelEntites:addEntity(x, y, newGoal)
        return newGoal
    end
end