return function(LevelEntites)
    return function(x, y)
        print("WALL", x, y, LevelEntites)
        obj = {
            quad = function(self)
                return LevelEntites.sprites["wall"]
            end
        }
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end