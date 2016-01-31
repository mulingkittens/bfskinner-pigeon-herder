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
    return (love.math.random(-ai_noise_weight * 1000, ai_noise_weight * 1000) / 1000)
end

function reinforce_weak(weight)
    return math.min(math.max(0.01, weight + ai_weak_reinforce_weight), 1.0)
end

function reinforce_strong(weight)
    return math.min(math.max(0.01, weight + ai_strong_reinforce_weight), 1.0)
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
        -- Whether the pattern has been reinforced yet
        active_pattern_reinforced = false,
        -- Whether the current action has been reinforced yet
        current_action_reinforced = false, 

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
                if long_pattern_count >= ai_max_long_patterns_remembered then
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
            strongest_pattern_name = nil
            strongest_weight = 0
            for name, pattern in pairs(self.patterns) do
                if (pattern.length > 1
                    and pattern.weight >= ai_long_pattern_recall_threshold
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
            self.active_pattern_reinforced = false
        end,

        get_current_action = function(self)
            local action = self.active_pattern_actions[1]
            if action == nil then
                local name = self:select_best_pattern()
                self:set_next_pattern(name)
                action = self.active_pattern_actions[1]
                self.current_action_reinforced = false
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
            if not self.current_action_reinforced then
                self.current_action_reinforced = true
                -- Reinforce the current pattern
                local pattern = self.patterns[self.active_pattern_name]
                if pattern.length > 1 then
                    if not self.active_pattern_reinforced then
                        self.active_pattern_reinforced = true
                        -- Strongly if it's a long pattern
                        pattern.weight = reinforce_strong(pattern.weight)
                    end
                else
                    -- Otherwise form a weak pattern if we can
                    local history_length = #self.action_history
                    if history_length > ai_long_pattern_minimum_length then
                        local length = love.math.random(ai_long_pattern_minimum_length, ai_long_pattern_maximum_length)
                        length = math.min(length, history_length)
                        local actions = {}
                        for i = history_length - length, history_length do
                            actions[#actions + 1] = self.action_history[i]
                        end
                        self:add_pattern(actions, nil, reinforce_weak)
                    end
                end
            end
            -- Reinforce the short pattern for the current action weakly
            local current_action = self:get_current_action()
            local current_action_name = current_action.name
            local current_action_pattern = self.patterns[current_action_name]
            current_action_pattern.weight = reinforce_weak(current_action_pattern.weight)
        end,

        perturb_patterns = function(self)
            for name, pattern in pairs(self.patterns) do
                local new_weight = math.min(math.max(0.01, pattern.weight + pattern_noise()), 1.0)
                pattern.weight = new_weight
            end
        end,

        observe_other_pigeons = function(self, pigeons)
            if not ai_can_learn_from_observing then
                return
            end
            -- Find a random other feeding pigeon to observer (if any)
            local feeding_pigeons = {}
            for _, other_pigeon in ipairs(Game.Pigeons) do
                if self ~= other_pigeon then
                    if other_pigeon.feeding then
                        feeding_pigeons[#feeding_pigeons + 1] = other_pigeon
                    end
                end
            end
            if #feeding_pigeons > 0 then
                if not self.current_action_reinforced then
                    self.current_action_reinforced = true
                    -- Form a strong pattern from our behaviour if we can, but with
                    -- the other pigeon's current action on the end.
                    local other_pigeon = random_value(feeding_pigeons)
                    local other_action = other_pigeon.ai:get_current_action()
                    local history_length = #self.action_history
                    if history_length > ai_long_pattern_minimum_length then
                        local length = love.math.random(ai_long_pattern_minimum_length, ai_long_pattern_maximum_length - 1)
                        length = math.min(length, history_length)
                        local actions = {}
                        for i = history_length - length, history_length do
                            actions[#actions + 1] = self.action_history[i]
                        end
                        actions[#actions + 1] = other_action
                        self:add_pattern(actions, nil, reinforce_weak)
                    end
                    -- Reinforce the short pattern for the other pigeon's current action weakly
                    local other_action_name = other_action.name
                    local other_action_pattern = self.patterns[other_action_name]
                    other_action_pattern.weight = reinforce_strong(other_action_pattern.weight)
                end
            end
        end,

        decay_patterns = function(self)
            for name, pattern in pairs(self.patterns) do
                local max_weight
                if pattern.length > 1 then
                    max_weight = ai_long_pattern_maximum_weight
                else
                    max_weight = ai_short_pattern_maximum_weight
                end
                local new_weight = math.min(math.max(0.01, pattern.weight ^ ai_weight_decay_exponent), max_weight)
                pattern.weight = new_weight
            end
        end,
    }

    ai:initialise()
    return ai
end
