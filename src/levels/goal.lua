return function(LevelEntites)
    return function(x, y)
        local newGoal = setmetatable({
            
            x = x,
            y = y,
            
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
        LevelEntites.addEnity(x, y, newGoal)
        return newGoal
    end
end