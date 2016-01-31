local level = Game.Level
Pen = require("src/levels/pen")
Goal = require("src/levels/goal")

return {
map = [[
|----------|
|----------|
|--     G--|
|--      --|
|--P     --|
|----------|
|----------|
]],

constructors = {
        P = Pen(4, level),
        G = Goal(4, level)
    }
}