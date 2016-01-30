return function(LevelEntites)
    return function(x, y)
        print("PEN", x, y, LevelEntites)
        obj = {
            quad = function(self)
                return LevelEntites.sprites["pen"]
            end
        }
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end