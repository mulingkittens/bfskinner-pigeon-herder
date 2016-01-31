local level = Game.Level
Pen = require("src/levels/pen")
Goal = require("src/levels/goal")

return {
map = [[
|----------|
|----------|
|-A     B--|
|-   P   --|
|-       --|
|----------|
|----------|
]],

constructors = {
        P = Pen(4, level),
        A = Goal(2, level),
        B = Goal(2, level)
    }
}