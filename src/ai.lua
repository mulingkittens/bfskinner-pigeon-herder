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
  return (love.math.random(-0.05 * 1000, 0.05 * 1000) / 1000)
end


ai = {
  -- All known patterns
  patterns = {},
  -- History of recent actions (for forming patterns)
  action_history = {},
  -- Key or index of the current pattern (so we can reinforce it)
  active_pattern = nil,
  -- Consume actions off the start of this table. When empty, 
  active_pattern_actions = {},

  initialise = function(self)
    -- Set up initial known patterns
    for name, action in pairs(Action) do
      -- Should phase out Action.think, cause it's not an action, it's the selection
      if name ~= 'think' then
        -- Short patterns are single behaviours
        self.patterns[name] = {
          length = 1,
          actions = {action},
          weight = math.abs(pattern_noise()),
        }
        -- Long patterns will be added as food events occur
      end
    end

    for i, pattern in pairs(self.patterns) do
      print(i, pattern.weight)
    end
  end,

  select_best_pattern = function(self)
    -- Select the strongest long pattern that's strong enough to recall
    minimum_long_pattern_weight = 0.3
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
    return self.active_pattern_actions[1]
  end,

  finish_current_action = function(self)
    table.remove(self.active_pattern_actions, 1)
  end,

  perturb_patterns = function(self)
    for name, pattern in pairs(self.patterns) do
      local new_weight = math.min(math.max(0.01, pattern.weight + pattern_noise()), 1.0)
      --print("reweighting", name, pattern.weight, new_weight)
      pattern.weight = new_weight
    end
  end,

  decay_patterns = function(self)
    for name, pattern in pairs(self.patterns) do
      local new_weight = math.min(math.max(0.01, pattern.weight * (pattern.weight ^ 0.1)), 1.0)
      --print("decaying", name, pattern.weight, new_weight)
      pattern.weight = new_weight
    end
  end,
}

Action = {
  hop = 'hop',
  skip = 'skip',
  jump = 'jump',
}


----------------------------------

love.math.setRandomSeed(love.timer.getTime())

ai:initialise()

for i = 1,30 do
  -- Determine current action
  local action = ai:get_current_action()
                                            print(i)
  if action == nil then
    local name = ai:select_best_pattern()
                                            print('best_pattern:', name, ai.patterns[name].weight)
    ai:set_next_pattern(name)
    action = ai:get_current_action()
  end
  print('action:', action)
  ai:finish_current_action()

  ai:perturb_patterns()
  ai:decay_patterns()

  print "------------------------------------------------------------"
end
