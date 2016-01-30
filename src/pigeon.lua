pigeonSprite = love.graphics.newImage('src/pigeon.png')

action = {
    none = 0,
    move = 1,
    turn_left = 2,
    turn_right = 3,
    peck = 4,
    flap = 5,
    }

return function(xPos, yPos)

    return setmetatable({
    
    currentAction = action.none,
    xPos = xPos,
    yPos = yPos,
    isAlive = true,
    foodLevel = 0,
    foodMaximum = 100,
    
    update = function(self, dt)
        
        -- if the pigeon has died return imediately
        if self.isAlive == false then
            
            return
        
        end
        
        -- decrement foo level
        self.foodLevel = self.foodLevel - 1
        
        -- perform relative functionality for current action
        local currentAction = self.currentAction
        
        local switch = ({
            [action.none] = function()
                -- if pigeon has no action, assign one
                if action == action.none then
                    action = math.floor((math.random() * 4) + 1)
                end
            end,
            [action.move] = function()
                -- move
            end,
            [action.turn_left] = function()
                -- turn_left
            end,
            [action.turn_right] = function()
                -- turn_right
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
      
    end,
    
    feed = function(self, value)
        
        -- increment the food level
        self.foodLevel = self.foodLevel + value
        
        -- if the food level exceeds the maximum, kill the pigeon
        if foodLevel > fooMaximum then
        
            self.isAlive = false
            
        end
    
    end,
    
    isAlive = function(self)
        
        return isAlive
        
    end,
    
  }, {

  -- operators

  })

end