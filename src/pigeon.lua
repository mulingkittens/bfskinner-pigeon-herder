pigeonSprite = love.graphics.newImage('src/pigeon.png')

return function(xPos, yPos)

    return setmetatable({
    
    m_xPos = xPos,
    m_yPos = yPos,
    m_food = 0,
    
    update = function(self, dt)
      
      -- update  
    
    end,
    
    draw = function(self, dt)
      
      love.graphics.draw(pigeonSprite, self.m_xPos, self.m_yPos)
    
    end,
    
    feed = function(self, value)
      
      self.food = self.food + value
      
    end,
    
  }, {

  -- operators

  })

end