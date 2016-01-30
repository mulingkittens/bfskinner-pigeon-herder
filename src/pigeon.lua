require("src/util")

local state = {
    alive = 0,
    dying = 1,
    dead = 2
}

local function create_move_action(dx, dy)
    return function(self, dt)
        new_x = self.x + dx * pigeonSpeed * dt
        new_y = self.y + dy * pigeonSpeed * dt
        new_rect = Rect(new_x, new_y, self.rect.w, self.rect.h)

        -- Fail if the pigeon wants to move off the screen
        screen_rect = Rect(0, 0, Game.Screen.width, Game.Screen.height)
        if not screen_rect:contains(new_rect) then
            return false
        end
        
        -- Fail if the pigeon wants to move into another pigeon
        for _, other_pigeon in ipairs(Game.Pigeons) do
            if self ~= other_pigeon then
                if other_pigeon.rect:intersects(new_rect) then
                    print("Hit Pigeon")
                    return false
                end
            end
        end
        
        -- Fail if the pigeon wants to move into an object
        for _, object in ipairs(Game.Objects.activeConstuctors) do
            print(_, object)
            if object:get_occlusion_block():intersects(new_rect) then
                print("Hit Object")
                return false
            end
        end
        
        -- Looks like we won't hit anything
        self.x = new_x
        self.y = new_y
        self.rect = new_rect
        return true
    end
end

local Action = {}

Action.think = function(self, dt, other_pigeons)
    -- Pick a random action to do

    self.action = self:selectNextAction()
    self.currentActionTime = 2
    return true
end
Action.move_up = create_move_action(0, -1)
Action.move_down = create_move_action(0, 1)
Action.move_left = create_move_action(-1, 0)
Action.move_right = create_move_action(1, -0)
Action.move_up_left = create_move_action(-1, -1)
Action.move_up_right = create_move_action(1, -1)
Action.move_down_left = create_move_action(-1, 1)
Action.move_down_right = create_move_action(1, 1)

Action.peck = function(self, dt, other_pigeons)
    return true
end

Action.flap = function(self, dt, other_pigeons)
    return true
end

local ActionNames = table_key_index(Action)

local ActionColors = {
    think = { 0, 0, 0, 0, },
    move_up = { 16, 16, 32, 255, },
    move_down = { 32, 32, 64, 255, },
    move_left = { 48, 48, 96, 255, },
    move_right = { 64, 64, 128, 255, },
    move_up_left = { 80, 80, 160, 255, },
    move_up_right = { 96, 96, 192, 255, },
    move_down_left = { 112, 112, 224, 255, },
    move_down_right = { 128, 128, 255, 255, },
    peck = { 0, 192, 0, 255, },
    flap = { 255, 0, 0, 255, },
}

return function(LevelEntites)
    return function(x, y)

        local new_pigeon = setmetatable({
         
            currentState = state.alive,
            action = Action.think,
            currentActionTime = 0,
            x = x,
            y = y,
            foodLevel = 0,
            influenceTable = {},

            initialise = function(self, dt)
                -- bounding box
                self.rect = Rect(self.x, self.y, Game.Sprites.Pigeon:getWidth(), Game.Sprites.Pigeon:getHeight())

                -- initialise influence table
                for _, action in pairs(Action) do
                    self.influenceTable[action] = 0
                end
            end,
            
            quad = function(self)
                return LevelEntites.sprites["pen"]
            end,
            
            update = function(self, dt)

                -- if the pigeon has died return imediately
                if self.currentState == state.dead then
                    return
                end

                -- decrement food level
                self.foodLevel = self.foodLevel - pigeonFoodDecrement
                if self.foodLevel <= 0 then
                    self.foodLevel = 0
                end

                -- decrement all actions in the influence table
                for action in pairs(self.influenceTable) do
                    self.influenceTable[action] = self.influenceTable[action] - pigeonInfluenceDecrement
                    if self.influenceTable[action] <= 0 then
                        self.influenceTable[action] = 0
                    end
                end

                -- run the current action (unless it fails)
                local failed = not self:action(dt)

                -- decrement current action time
                self.currentActionTime = self.currentActionTime - dt
                if failed or self.currentActionTime <= 0 then
                    self.action = Action.think
                    self.currentActionTime = 0
                end
            end,
         
            draw = function(self, Game, dt)

                -- draw pigeon
                local draw = function()
                    love.graphics.draw(Game.Sprites.Pigeon, self.x, self.y)
                end
                if Game.Debug.draw_actions then
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(unpack(ActionColors[ActionNames[self.action]]))
                    draw()
                    love.graphics.setColor(r, g, b, a)
                else
                    draw()
                end

                -- debug output
                if Game.Debug.draw_actions then
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(0, 0, 0, 255)
                    local action_name = ActionNames[self.action]
                    local action_time = string.format('%0.1f', self.currentActionTime)
                    love.graphics.print(action_name .. " " .. action_time, self.x - 10, self.y - 20)
                    love.graphics.print("Food:" .. self.foodLevel, self.x -10, self.y - 30)
                    love.graphics.print("Influence:" .. self.influenceTable[Action.move_down_right], self.x -10, self.y - 40)
                    love.graphics.setColor(r, g, b, a)
                end
                if Game.Debug.draw_bounding_boxes then
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(255, 0, 0, 255)
                    love.graphics.rectangle('line', self.rect.x, self.rect.y, self.rect.w, self.rect.h)
                    love.graphics.setColor(r, g, b, a)
                end
            end,
         
            feed = function(self)

                -- return because you can't feed a dead  pigeon
                if self.currentState == state.dead then
                    return
                end

                -- increment the influence table for the current action
                self.influenceTable[self.action] = self.influenceTable[self.action] + pigeonInfluencePerClick

                -- if the influence level exceeds the maximum set it to the maximum
                if self.influenceTable[self.action] > pigeonInfluenceMax then
                    self.influenceTable[self.action] = pigeonInfluenceMax
                end

                -- increment the food level
                self.foodLevel = self.foodLevel + pigeonFoodPerFeed

                -- if the food level exceeds the maximum, kill the pigeon
                if self.foodLevel > pigeonFoodMaximum then
                    self.currentState = state.dead
                end

            end,
        
            isAlive = function(self)
                if self.currentState == state.dead then
                    return false
                else
                    return true
                end
            end,
            
            selectNextAction = function(self)
            
                local highestInfluence = 0
                local highestInfluenceAction = 0
            
                -- iterate through the influence table and store the action of the highest value
                for action, influence in pairs(self.influenceTable) do
                    if influence > highestInfluence then
                        highestInfluence = influence
                        highestInfluenceAction = action
                    end
                end
                
                -- if the highest value is greater than the upper threshold then return that action
                if highestInfluence >= pigeonInfluenceUpperThreshold then
                    return highestInfluenceAction
                end
                
                -- otherwise return a random action
                return random_value(Action)
                
                --TODO(Gordon): Implement random actions based on influences
                --[[
                -- create a table of actions and asign their percentage of being selected.
                local actionPotentials = {}
                for _, action in pairs(Action) do
                    actionPotentials[action] = 100
                    if self.influenceTable[action] > pigeonInfluenceLowerThreshold then
                        actionPotentials[action] = actionPotentials[action] + self.influenceTable[action]
                    end
                end
                ]]
            end,
            
        }, {

            -- operators

        })

        new_pigeon:initialise()
        LevelEntites:addEntity(x, y, new_pigeon)
        return new_pigeon
    end
end
