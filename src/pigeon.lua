require("src/util")
AIFactory = require("src/ai")

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
                    return false
                end
            end
        end
        
        -- Fail if the pigeon wants to move into an object
        for _, object in ipairs(Game.Objects.activeInstances) do
            if object.get_occlusion_block then
                if object:get_occlusion_block():intersects(new_rect) then
                    return false
                end
            end
        end
        
        -- Looks like we won't hit anything
        self.x = new_x
        self.y = new_y
        self.rect = new_rect
        if self.frameFacingLeft and dx > 0 then
            self.frameFacingLeft = false
        elseif not self.frameFacingLeft and dx < 0 then
            self.frameFacingLeft = true
        end
        return true
    end
end

-- Action used by pigeon.lua and ai.lua
Action = {}

Action.move_up = {
    name = 'move_up',
    fn = create_move_action(0, -1),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_down = {
    name = 'move_down',
    fn = create_move_action(0, 1),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_left = {
    name = 'move_left',
    fn = create_move_action(-1, 0),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_right = {
    name = 'move_right',
    fn = create_move_action(1, -0),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_up_left = {
    name = 'move_up_left',
    fn = create_move_action(-1, -1),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_up_right = {
    name = 'move_up_right',
    fn = create_move_action(1, -1),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_down_left = {
    name = 'move_down_left',
    fn = create_move_action(-1, 1),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.move_down_right = {
    name = 'move_down_right',
    fn = create_move_action(1, 1),
    frames = {
        { time = 0.4, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.4, sprite = Game.Sprites.Pigeon.move2 },
    },
}
Action.peck = {
    name = 'peck',
    fn = function(self, dt, other_pigeons)
        return true
    end,
    frames = {
        { time = 0.15, sprite = Game.Sprites.Pigeon.peck },
        { time = 0.1, sprite = Game.Sprites.Pigeon.move1 },
        { time = 0.15, sprite = Game.Sprites.Pigeon.peck },
        { time = 0.3, sprite = Game.Sprites.Pigeon.move1 },
    },
}
Action.flap = {
    name = 'flap',
    fn = function(self, dt, other_pigeons)
        return true
    end,
    frames = {
        { time = 0.1, sprite = Game.Sprites.Pigeon.hop },
        { time = 0.05, sprite = Game.Sprites.Pigeon.move2 },
        { time = 0.1, sprite = Game.Sprites.Pigeon.hop },
        { time = 0.05, sprite = Game.Sprites.Pigeon.move2 },
        { time = 0.1, sprite = Game.Sprites.Pigeon.hop },
        { time = 0.3, sprite = Game.Sprites.Pigeon.move2 },
    },
}

return function(x, y)
    local new_pigeon = setmetatable({
     
        currentState = state.alive,
        action = nil,
        currentActionTime = 0,
        frameTimer = 0,
        frameIndex = 1,
        frameFacingLeft = true,
        x = x,
        y = y,
        foodLevel = 0,
        feeding = false,
        influenceTable = {},

        initialise = function(self, dt)
            -- bounding box
            self.rect = Rect(self.x, self.y, Game.Sprites.Pigeon.move1:getWidth(), Game.Sprites.Pigeon.move1:getHeight())

            -- initialise influence table
            for _, action in pairs(Action) do
                self.influenceTable[action] = 0
            end

            self.ai = AIFactory()
            self:setNextAction()
        end,
        
        update = function(self, dt)

            -- if the pigeon has died return imediately
            if self.currentState == state.dead then
                return
            end

            -- reinforce ai when feeding
            if self.feeding then
                self.ai:reinforce_current_pattern()
                self.feeding = false
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

            -- update the current frame
            local frame = self.action.frames[self.frameIndex]
            self.frameTimer = self.frameTimer + dt
            if self.frameTimer > frame.time then
                self.frameTimer = self.frameTimer - frame.time
                self.frameIndex = self.frameIndex + 1
                while self.frameIndex > #self.action.frames do
                    self.frameIndex = self.frameIndex - #self.action.frames
                end
            end

            -- run the current action (unless it fails)
            local failed = not self.action.fn(self, dt)

            -- decrement current action time
            self.currentActionTime = self.currentActionTime - dt
            if failed or self.currentActionTime <= 0 then
                self.ai:finish_current_action()
                self:setNextAction()
            end
        end,
     
        draw = function(self, Game, dt)

            -- draw pigeon
            local frame = self.action.frames[self.frameIndex]
            local sx, sy, ox, oy;
            if self.frameFacingLeft then
                sx = 1
                ox = 1
            else
                sx = -1
                ox = frame.sprite:getWidth()
            end
            sy = 1
            oy = 0
            love.graphics.draw(frame.sprite, self.x, self.y, 0, sx, sy, ox, oy)

            -- debug output
            if Game.Debug.draw_actions then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(0, 0, 0, 255)
                local action_name = self.action.name
                local action_time = string.format('%0.1f', self.currentActionTime)
                love.graphics.print(action_name .. " " .. action_time, self.x - 10, self.y - 20)
                love.graphics.print("Pattern: " .. tostring(self.ai.active_pattern_name), self.x -10, self.y - 30)
                --love.graphics.print("Food:" .. self.foodLevel, self.x -10, self.y - 30)
                --love.graphics.print("Influence:" .. self.influenceTable[Action.move_down_right], self.x -10, self.y - 40)
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

            self.feeding = true

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

        setNextAction = function(self)
            -- Select the next action for the pigeon
            self.action = self.ai:get_current_action()
            while self.frameIndex > #self.action.frames do
                self.frameIndex = self.frameIndex - #self.action.frames
            end

            -- Create a variying action time
            actionTimeVariance = (math.random() * 1) - 0.5
            self.currentActionTime = pigeonActionTime + actionTimeVariance
        end,
        
    }, {

        -- operators

    })

    new_pigeon:initialise()
    return new_pigeon
end
