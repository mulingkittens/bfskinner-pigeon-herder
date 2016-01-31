return function(LevelEntites)
    return function(x, y)
        --print("GRASS", x, y, LevelEntites)
        obj = {
            quad = function(self)
                return LevelEntites.sprites["grass"]
            end
        }
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end