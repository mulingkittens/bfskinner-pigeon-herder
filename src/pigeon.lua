require("src/util")
pigeonSprite = love.graphics.newImage('src/pigeon.png')
pigeonSpeed = 50;

state = {
    alive = 0,
    dying = 1,
    dead = 2
    }

function create_move_action(dx, dy)
    return function(pigeon, dt)
        new_x = pigeon.x + dx * pigeonSpeed * dt
        new_y = pigeon.x + dy * pigeonSpeed * dt
        -- TODO - check that new_x and new_y don't cause collisions or hit the edge
        -- return false if we can't move
        pigeon.x = new_x
        pigeon.y = new_y
        return true
    end
end

Action = {}
ActionNames = {}

Action.think = function(self, dt)
    -- Pick a random action to do
    local key = random_choice(ActionChoices)
    self.action = Action[key]
    self.currentActionTime = 2
end
ActionNames[Action.think] = "think"

Action.move_up = create_move_action(0, -1)
ActionNames[Action.move_up] = "move_up"

Action.move_down = create_move_action(0, 1)
ActionNames[Action.move_down] = "move_down"

Action.move_left = create_move_action(-1, 0)
ActionNames[Action.move_left] = "move_left"

Action.move_right = create_move_action(1, -0)
ActionNames[Action.move_right] = "move_right"

Action.move_up_left = create_move_action(-1, -1)
ActionNames[Action.move_up_left] = "move_up_left"

Action.move_up_right = create_move_action(1, -1)
ActionNames[Action.move_up_right] = "move_up_right"

Action.move_down_left = create_move_action(-1, 1)
ActionNames[Action.move_down_left] = "move_down_left"

Action.move_down_right = create_move_action(1, 1)
ActionNames[Action.move_down_right] = "move_down_right"

Action.peck = function(self, dt)
end
ActionNames[Action.peck] = "peck"

Action.flap = function(self, dt)
end
ActionNames[Action.flap] = "flap"

ActionChoices = table_index(Action)


return function(x, y)

    return setmetatable({
    
    currentState = state.alive,
    action = Action.think,
    currentActionTime = 0,
    x = x,
    y = y,
    foodLevel = 0,
    foodMaximum = 100,
    influenceTable = {},
    
    initialise = function(self, dt)
        
        -- initialise influence table
        for k in pairs(Action) do
            self.influenceTable[k] = 0
        end
        
    end,
    
    update = function(self, dt)
        
        -- if the pigeon has died return imediately
        if self.currentState == state.dead then     
            return
        end
        
        -- decrement food level
        self.foodLevel = self.foodLevel - 1

        -- run the current action
        self:action(dt)
        
        -- increment current action time
        self.currentActionTime = self.currentActionTime - dt
        if self.currentActionTime <= 0 then
            self.action = Action.think
            self.currentActionTime = 0
        end
        
        -- fix position to be within the bouinds of the level
        if self.x <= 50 then
            self.x = 50
        end
        if self.y <= 50 then
            self.y = 50
        end
        if self.x >= 550 then
            self.x = 550
        end
        if self.y >= 550 then
            self.y = 550
        end
    
    end,
    
    draw = function(self, dt)
        
        -- draw pigeon
        love.graphics.draw(pigeonSprite, self.x, self.y)
        
        -- debug output
        local action_name = ActionNames[self.action]
        love.graphics.print(tostring(action_name), self.x - 10, self.y - 20)
        love.graphics.print(tostring(self.currentActionTime), self.x + 10, self.y - 20)
      
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
    
  }, {

  -- operators

  })

end