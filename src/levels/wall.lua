return function(LevelEntites)
    return function(x, y)
        print("WALL", x, y, LevelEntites)
        obj = setmetatable({
                quad = function(self)
                    return LevelEntites.sprites["wall"]
                end,
                
                x = x,
                y = y,
            
                update = function(self, dt)
            
                    --update
            
                end,
                
                 get_occlusion_block = function(self)
                
                    return Rect(self.x, self.y, 150, 150)
                
                end,
                
            }, {

            __tostring = function(self)
            
                return "barrier"
            
            end

        })
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end