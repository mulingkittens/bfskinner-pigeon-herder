require("src/util")
pigeonSpeed = 50;

debug_draw_actions = true
debug_draw_bounding_boxes = true

state = {
    alive = 0,
    dying = 1,
    dead = 2
    }

function create_move_action(dx, dy)
    return function(self, Game, dt)
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
        -- Looks like we won't hit anything
        self.x = new_x
        self.y = new_y
        self.rect = new_rect
        return true
    end
end

Action = {}

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

ActionNames = table_key_index(Action)
ActionChoices = table_index(Action)


return function(x, y)

    local new_pigeon = setmetatable({
    
    currentState = state.alive,
    action = Action.think,
    currentActionTime = 0,
    x = x,
    y = y,
    foodLevel = 0,
    foodMaximum = 100,
    influenceTable = {},
    influenceThreshold = 50,
    
    initialise = function(self, dt)
        -- bounding box
        self.rect = Rect(self.x, self.y, Game.Sprites.Pigeon:getWidth(), Game.Sprites.Pigeon:getHeight())

        -- initialise influence table
        for _, action in pairs(Action) do
            self.influenceTable[action] = 0
        end
        
    end,
    
    update = function(self, Game, dt)
        
        -- if the pigeon has died return imediately
        if self.currentState == state.dead then     
            return
        end
        
        -- decrement food level
        self.foodLevel = self.foodLevel - 1

        -- run the current action (unless it fails)
        local failed = not self:action(Game, dt)

        -- increment current action time
        self.currentActionTime = self.currentActionTime - dt
        if failed or self.currentActionTime <= 0 then
            self.action = Action.think
            self.currentActionTime = 0
        end
    end,
    
    draw = function(self, Game, dt)
        
        -- draw pigeon
        love.graphics.draw(Game.Sprites.Pigeon, self.x, self.y)

        -- debug output
        if debug_draw_actions then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(0, 0, 0, 255)
            local action_name = ActionNames[self.action]
            local action_time = string.format('%0.1f', self.currentActionTime)
            love.graphics.print(action_name .. " " .. action_time, self.x - 10, self.y - 20)
            love.graphics.setColor(r, g, b, a)
        end
        if debug_draw_bounding_boxes then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(255, 0, 0, 255)
            love.graphics.rectangle('line', self.rect.x, self.rect.y, self.rect.w, self.rect.h)
            love.graphics.setColor(r, g, b, a)
        end
    end,
    
    feed = function(self, value)
        
        -- increment the influence table for the current action
        self.influenceTable[self.currentAction] = self.influenceTable[self.currentAction] + 20
        
        -- increment the food level
        self.foodLevel = self.foodLevel + value
        
        -- if the food level exceeds the maximum, kill the pigeon
        if foodLevel > fooMaximum then
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
    
        -- TODO(Gordon): Add different levels of threshold for a more gradual change in behaviour
    
        local influenceHighEnough = false
        local highestInfluence = 0
        local highestInfluenceAction = 0
    
        --iterate through the influence table and select the highest
        for action, influence in ipairs(self.influenceTable) do
            if influence > highestInfluence then
                highestInfluence = influence
                highestInfluenceAction = action
            end
        end
        
        -- if the highest influence is over the threshold select that action
        if highestInfluence >= self.influenceThreshold then
            return highestInfluenceAction
        end
    
        -- otherwise return a random action
        local key = random_choice(ActionChoices)
        return Action[key]
    
    end,
    
  }, {

  -- operators

  })

  new_pigeon:initialise()
  return new_pigeon
end