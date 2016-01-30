-- Return an indexed table containing all keys in t
function table_index(t)
    local keys = {}
    for k, _ in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

-- Return a random choice from the indexed table t
function random_choice(t)
    i = math.random(1, #t) 
    return t[i]
end
