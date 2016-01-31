local level = Game.Level
Pen = require("src/levels/pen")
Goal = require("src/levels/goal")

return {
map = [[
|----------|
|  A --  F |
|    --    |
|    --    |
|    --    |
| E  -- B  |
|----------|
]],

constructors = {
        A = Pen(4, level),
        B = Pen(4, level),
        E = Goal(2, level),
        F = Goal(2, level)
    }
}