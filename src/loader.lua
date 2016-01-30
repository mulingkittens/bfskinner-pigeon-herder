--
-- Level loader for "B.F. Skinner, Pigeon Fodder"
-- Sat 30 Jan 05:25:33 GMT 2016

--[[
--This details the level map format

   A map is a simple ASCII grid, layed out as follows

   ^-------------
   |             
   |             
   |      S      
   |   B         
   |P            
   --------------

For each square on the grid in the map, The given ASCII character is looked up in the engine's `map_items` module,
and indexed for the given character.
If the given character's key exists in the table its value (any callable) is called with the tuple (x, y, existing_constructors).
The called function is expected to return a new Game object which is the placed on a new grid at the same coordinate

The following items are predefined and can be overriden:

    | or -: Wall. It's a wall.
    Pen: Spawns Pigeons.
    O: Pit. Probably bottomless. Fuck you.
    $: Powerup. A steaming hot babe with huge money.
    *: Whirling blades of death. Fuck you again.
]]


local function parse_map(map_s)
    -- given a map string `map_s` parse as a multidimensional array
    -- with the origin at the top-left.
    local lines = {}
    local grid = {}
    nonempty = false
    map_s:gsub('(.-)\r?\n', function(line)
        if nonempty or line:find("[^%S]") then
            nonempty = true
            lines[#lines + 1] = line
        end
    end)
    for i, line in ipairs(lines) do
        local t = {}
        grid[i] = t
        for char in line:gmatch("(.)") do
            t[#t + 1] = char
        end
    end
    return grid
end


local function load_level_file(level_name, fs)
    -- load a level file and return a level object which contains the raw
    -- lua chunk
    local fs = fs or love and love.filesystem or nil
    print(fs)
    local predefined = predefined or {}
    local path = "assets/levels/" .. level_name .. ".lua"
    local success, chunk = pcall(fs.load, path)

    if not success then return false, "Couldn't load " .. path end
    print("success", success, chunk)

    return chunk()
end


local function construct_level(level_cfg, map_grid)
    local default_constructors = Game.Objects.default_constructors
    level_cfg.constructors = level_cfg.constructors or default_constructors
    local level = {}
    for x, row in ipairs(map_grid) do
        level[x] = {}
        for y, char in ipairs(row) do
            if level_cfg.constructors[char] then
                level[x][y] = level_cfg.constructors[char](x, y, default_constructors)
            end
        end
    end
    return level
end


return function(level_name)
    local level_cfg = load_level_file(level_name)
    print("89", success, level_cfg)
    print("WHAT", level_cfg)
    for k, v in pairs(level_cfg) do print(k, v) end
    local map_grid = parse_map(level_cfg.map)
    return construct_level(level_cfg, map_grid)
end
