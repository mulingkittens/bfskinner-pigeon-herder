return function(LevelEntites)
    return function(x, y)
        --print("WALL", x, y, LevelEntites)
        local obj = setmetatable({
                quad = function(self)
                    return LevelEntites.sprites["wall"]
                end,

                x = (x-1) * 128,
                y = (y-1) * 128,

                update = function(self, dt)

                    --update

                end,

                 get_occlusion_block = function(self)

                    return Rect(self.x, self.y, 128, 128)

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