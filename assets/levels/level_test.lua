return {
map = [[
------------
| P        |
|          |
|   P      |
|      S   |
|          |
------------
]],

constructors = {
    S = function() print("This is an S") return true end,
    ["|"] = function() print("This is a wall") return true end,
    ["-"] = function() print("This is a wall") return true end,
    -- our pigeons
}
}
