pigeonSprite = love.graphics.newImage('src/pigeon.png')

state = {
    alive = 0,
    dying = 1,
    dead = 2
    }

action = {
    none = 0,
    move_up = 1,
    move_down = 2,
    move_left = 3,
    move_right = 4,
    move_up_left = 5,
    move_up_right = 6,
    move_down_left = 7,
    move_down_right = 8,
    peck = 9,
    flap = 10,
    }

return function(xPos, yPos)

    return setmetatable({
    
    currentState = state.alive,
    currentAction = action.none,
    currentActionTime = 0,
    xPos = xPos,
    yPos = yPos,
    foodLevel = 0,
    foodMaximum = 100,
    influenceTable = {},
    
    initialise = function(self, dt)
        
        -- initialise influence table
        for k in pairs(action) do
            self.influenceTable[k] = 0
        end
        
    end,
    
    update = function(self, dt)
        
        -- if the pigeon has died return imediately
        if self.currentState ~= state.alive then     
            return
        end
        
        -- decrement food level
        self.foodLevel = self.foodLevel - 1
        
        -- increment current action time
        self.currentActionTime = self.currentActionTime - dt
        if self.currentActionTime <= 0 then
            self.currentAction = action.none
            self.currentActionTime = 0
        end
        
        -- perform relative functionality for current action
        local currentAction = self.currentAction
        
        local switch = ({
            [action.none] = function()
                -- if pigeon has no action, assign one
                if self.currentAction == action.none then
                    self.currentAction = math.floor((math.random() * 5) + 1)
                    self.currentActionTime = 10
                end
            end,
            [action.move_up] = function()
                -- move_up
            end,
            [action.move_down] = function()
                -- move_down
            end,
            [action.move_left] = function()
                -- move_left
            end,
            [action.move_right] = function()
                -- move_right
            end,
            [action.move_up_left] = function()
                -- move_up_left
            end,
            [action.move_up_right] = function()
                -- move_up_right
            end,
            [action.move_down_left] = function()
                -- move_down_left
            end,
            [action.move_down_right] = function()
                -- move_down_right
            end,
            [action.peck] = function()
                -- peck
            end,
            [action.flap] = function()
                -- flap
            end
        })
    
        switch[currentAction]()
    
    end,
    
    draw = function(self, dt)
        
        -- draw pigeon
        love.graphics.draw(pigeonSprite, self.xPos, self.yPos)
        
        -- debug output
        love.graphics.print(tostring(self.currentAction), self.xPos - 10, self.yPos - 20)
        love.graphics.print(tostring(self.currentActionTime), self.xPos + 10, self.yPos - 20)
      
    end,
    
    feed = function(self, value)
        
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