local level = Game.Level
Pen = require("src/levels/pen")
Goal = require("src/levels/goal")

return {
map = [[
|----------|
|P         |
|-------   |
|          |
|    ------|
|         G|
|----------|
]],

constructors = {
        P = Pen(2, level),
        G = Goal(2, level)
    }
}