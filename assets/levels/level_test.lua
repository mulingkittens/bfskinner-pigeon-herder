return {
map = [[
------------
|P         |
|          |
|   P      |
|      S   |
|          |
------------
]],

constructors = {
    --S = function(x, y, parent_constructor) print("This is an S") return true end,
    --["|"] = function(x, y, parent_constructor) print("This is a wall") return true end,
    --["-"] = function(x, y, parent_constructor) print("This is a wall") return true end,
    -- our pigeons
}
}
