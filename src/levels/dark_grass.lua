return function(LevelEntites)
    return function(x, y)
        local obj = {
            quad = function(self)
                return LevelEntites.sprites["dark_grass"]
            end
        }
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end