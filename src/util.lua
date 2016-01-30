-- Return an indexed table containing all keys in t
function table_index(t)
    local keys = {}
    for k, _ in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

-- Return a table mapping values in t to its keys
function table_key_index(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[v] = k
    end
    return keys
end

-- Return a random choice from the indexed table t
function random_choice(t)
    i = math.random(1, #t) 
    return t[i]
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
