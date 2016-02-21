return function(targetPigeons, LevelEntites)
    -- Update level state with number of pigeons
    Game.LevelState.requiredPigeons = Game.LevelState.requiredPigeons + targetPigeons
    return function(x, y)
        local newGoal = setmetatable({

            x = (x-1) * 128,
            y = (y-1) * 128,

            targetPigeons = targetPigeons,
            capturedPigeons = 0,

            quad = function(self)
                 return LevelEntites.sprites["goal"]
            end,

            update = function(self, dt)

                --update

            end,

            post_draw = function(self, dt)

                goalDisplay = self.capturedPigeons .. " / " .. self.targetPigeons

                love.graphics.print(goalDisplay, self.x, self.y)

            end,

            get_occlusion_block = function(self)

                return nil

            end,

            capture_pigeon = function(self)

                local goalRect = Rect(self.x, self.y, 128, 128)

                for i, pigeon in ipairs(Game.Pigeons) do

                    local pigeonRect = Rect(pigeon.x, pigeon.y, pigeon.rect.w, pigeon.rect.h)

                    if goalRect:intersects(pigeonRect) then

                        -- Remove pigeon from the game
                        table.remove(Game.Pigeons, i)

                        -- Increment captured pigeon counters
                        self.capturedPigeons =  self.capturedPigeons + 1
                        Game.LevelState.capturedPigeons = Game.LevelState.capturedPigeons + 1
                        Game.LevelState.remainingPigeons = Game.LevelState.remainingPigeons - 1
                    end

                end

            end,

            win_condition_triggered = function(self)

                return (self.capturedPigeons >= self.targetPigeons)

            end

        }, {

            __tostring = function(self)

                return "goal"

            end

        })
        LevelEntites:addEntity(x, y, newGoal)
        return newGoal
    end
end