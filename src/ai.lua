--[[
behaviours:
                                    Variables               Can observe
    walk and turn towards target    time, speed             yes
    walk and turn away from target  time, speed             yes
    walk forward                    time, speed             yes
    stop and peck                   time, number of pecks   no
    stop and look                   time                    yes
    stop and shit                   time                    no
    stop and flap                   time                    no

patterns:
    sequences of behaviours, 2, 3, 4, or 5 long.
    up to 4 patterns.

selection:

    evaluate pattern weights:
        'next' behaviour from highest weighted pattern, if weight is above threshold
            (need perturbation to try other patterns from time to time)
    evaluate individual weights:
        select behaviour with highest weight

learning feedback:

    food event for this pigeon:
        if performing behaviour pattern:
            reinforce current behaviour pattern strongly
                if it's already strong, needs to be increasingly cumulative (for a while) (sigmoid?)
            weakly reinforce current individual behaviour
        otherwise:
            add current behaviour plus a little history as a pattern
                reinforce it weakly
            strongly reinforce current individual behaviour

    if can observe:
        pick random pigeon with food event
            add its behaviour to behaviour pool in place of another (current?) behaviour
                weakly reinforce it
        strongly reinforce observed individual behaviour

afterwards:

    perturb all patterns and behaviours with a little noise
    decay all weights
]]


function pattern_noise()
    -- Have to multiply and divide by 1000, because love.math.random works with ints
    return (love.math.random(-0.1 * 1000, 0.1 * 1000) / 1000)
end

function reinforce_weak(weight)
    return math.min(math.max(0.01, weight + 0.05), 1.0)
end

function reinforce_strong(weight)
    return math.min(math.max(0.01, weight + 0.2), 1.0)
end

return function()
    ai = {
        -- All known patterns
        patterns = {},
        -- History of recent actions (for forming patterns)
        action_history = {},
        -- Name of the current pattern (so we can reinforce it)
        active_pattern_name = nil,
        -- Consume actions off the start of this table. When empty, 
        active_pattern_actions = {},

        initialise = function(self)
            -- Set up initial known patterns
            for name, action in pairs(Action) do
                -- Short patterns are single behaviours
                self:add_pattern({action}, name)
                -- Long patterns will be added as food events occur
            end
            local name = self:select_best_pattern()
            self:set_next_pattern(name)
        end,

        add_pattern = function(self, actions, name, reinforce)
            name = name or (#self.patterns + 1)
            new_pattern = {
                length = #actions,
                actions = actions,
                weight = math.abs(pattern_noise()),
            }
            if reinforce ~= nil then
                new_pattern.weight = reinforce(new_pattern.weight)
            end
            -- If the new pattern is long and stronger than an existing long pattern, replace it
            if new_pattern.length > 1 then
                long_pattern_count = 0
                for k, p in pairs(self.patterns) do
                    if p.length > 1 then
                        long_pattern_count = long_pattern_count + 1
                    end
                end
                if long_pattern_count >= 5 then
                    for name, other_pattern in pairs(self.patterns) do
                        if (self.active_pattern_name ~= name
                            and other_pattern.length > 1
                            and other_pattern.weight < new_pattern.weight) then
                            -- Replace the older, weaker weighted long pattern with the new pattern
                            self.patterns[name] = new_pattern
                            return
                        end
                    end
                    -- Can't find a weaker pattern to replace with the new pattern, so don't add it
                    return
                else
                    -- Add a long pattern if there are few already
                    self.patterns[name] = new_pattern
                    return
                end
            else
                -- Always add short patterns
                self.patterns[name] = new_pattern
                return
            end
        end,

        select_best_pattern = function(self)
            -- Select the strongest long pattern that's strong enough to recall
            minimum_long_pattern_weight = 0.05
            strongest_pattern_name = nil
            strongest_weight = 0
            for name, pattern in pairs(self.patterns) do
                if (pattern.length > 1
                    and pattern.weight >= minimum_long_pattern_weight
                    and pattern.weight > strongest_weight) then
                    strongest_pattern_name = name
                    strongest_weight = pattern.weight
                end
            end
            if strongest_pattern == nil then
                -- No suitable long pattern; select a short pattern
                for name, pattern in pairs(self.patterns) do
                    if (pattern.length == 1
                        and pattern.weight > strongest_weight) then
                        strongest_pattern_name = name
                        strongest_weight = pattern.weight
                    end
                end
            end
            return strongest_pattern_name
        end,

        set_next_pattern = function(self, name)
            -- Use the given pattern next
            local upcoming_actions = {}
            for i, action in pairs(self.patterns[name].actions) do
                upcoming_actions[#upcoming_actions + 1] = action
            end
            self.active_pattern_name = name
            self.active_pattern_actions = upcoming_actions
        end,

        get_current_action = function(self)
            local action = self.active_pattern_actions[1]
            if action == nil then
                local name = self:select_best_pattern()
                self:set_next_pattern(name)
                action = self:get_current_action()
            end
            return action
        end,

        finish_current_action = function(self)
            self:perturb_patterns()
            self:decay_patterns()

            local action = self:get_current_action()
            table.remove(self.active_pattern_actions, 1)
            self.action_history[#self.action_history + 1] = action
            if #self.action_history > 5 then
                table.remove(self.action_history, 1)
            end
        end,

        reinforce_current_pattern = function(self)
            -- Reinforce the current pattern
            local pattern = self.patterns[self.active_pattern_name]
            if pattern.length > 1 then
                -- Strongly if it's a long pattern
                pattern.weight = reinforce_strong(pattern.weight)
            else
                -- Otherwise form a weak pattern if we can
                local history_length = #self.action_history
                if history_length > 2 then
                    local length = love.math.random(2, 5)
                    length = math.min(length, history_length)
                    local actions = {}
                    for i = history_length - length, history_length do
                        actions[#actions + 1] = self.action_history[i]
                    end
                    self:add_pattern(actions, nil, reinforce_weak)
                end
            end
            -- Reinforce the short pattern for the current action weakly
            local current_action = self:get_current_action()
            local current_action_name = ActionNames[current_action]
            local current_action_pattern = self.patterns[current_action_name]
            current_action_pattern.weight = reinforce_weak(current_action_pattern.weight)
        end,

        perturb_patterns = function(self)
            for name, pattern in pairs(self.patterns) do
                local new_weight = math.min(math.max(0.01, pattern.weight + pattern_noise()), 1.0)
                pattern.weight = new_weight
            end
        end,

        decay_patterns = function(self)
            for name, pattern in pairs(self.patterns) do
                local max_weight
                if pattern.length > 1 then
                    max_weight = 1.0
                else
                    max_weight = 0.5
                end
                local new_weight = math.min(math.max(0.01, pattern.weight * (pattern.weight ^ 0.1)), max_weight)
                pattern.weight = new_weight
            end
        end,
    }

    ai:initialise()
    return ai
end
