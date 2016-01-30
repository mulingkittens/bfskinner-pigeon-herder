return function(LevelEntites)
    print("PIT initial", LevelEntites)
    return function(x, y)
        print("PIT", x, y, LevelEntites)
        obj = {
            quad = function(self)
                return LevelEntites.sprites["rocks"]
            end
        }
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end