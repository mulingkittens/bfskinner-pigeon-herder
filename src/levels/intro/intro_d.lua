return function(LevelEntites)
    return function(x, y)
        local obj = {
            x = x,
            y = y,
            quad = function(self)
                return LevelEntites.sprites["intro_d"]
            end,
            get_occlusion_block = function(self)
                return Rect(self.x, self.y, 128, 128)
            end,
        }
        LevelEntites:addEntity(x, y, obj)
        return obj
    end
end