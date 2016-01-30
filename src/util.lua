-- Return a table mapping values in t to its keys
function table_key_index(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[v] = k
    end
    return keys
end

-- Return a random value from the table t
function random_value(t)
  count = 0
  for k, v in pairs(t) do
    count = count + 1
  end
  chosen = math.random(1, count)
  index = 0
  for k, v in pairs(t) do
    index = index + 1
    if index == chosen then
      return v
    end
  end
  return -1
end


-- Rectangles

function Rect(x, y, w, h)
  rect = {
    x = x,
    y = y,
    w = w,
    h = h,

    contains = function(self, other)
      return (other.x >= self.x
        and (other.x + other.w) <= (self.x + self.w)
        and other.y >= self.y
        and (other.y + other.h) <= (self.y + self.h))
    end,

    intersects = function(self, other)
      return not (other.x > (self.x + self.w)
        or (other.x + other.w) < self.x
        or other.y > (self.y + self.h)
        or (other.y + other.h) < self.y)
    end,
  }
  return setmetatable(rect, {
    __tostring = function(self)
      return ("Rect(" .. tostring(self.x) .. ", "
        .. tostring(self.y) .. ", "
        .. tostring(self.w) .. ", "
        .. tostring(self.h) .. ")")
    end,
  })
end
