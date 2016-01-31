-- game variables

pigeonPenSpawnTime = 5
pigeonPenSpawnTimerDecrement = 0.1

pigeonFeedByRadius = true
pigeonFeedRadius = 150
pigeonFeedRadiusDisplayTime = 0.2

pigeonSpeed = 50

pigeonActionTime = 1
pigeonActionVariance = 0.5

pigeonFoodMaximum = 100
pigeonFoodPerFeed = 10
pigeonFoodDecrement = 0.1

pigeonInfluencePerClick = 20
pigeonInfluenceMax = 100
pigeonInfluenceUpperThreshold = 75
pigeonInfluenceLowerThreshold = 25
pigeonInfluenceDecrement = 0.1

-- Audio junk
maxAudioQueueTime = 0.25
maxAudioQueueEvents = 4
fallbackAmbiantAudioFile = "assets/audio/birdchatter.wav"

ai_noise_weight = 0.1
ai_weak_reinforce_weight = 0.05
ai_strong_reinforce_weight = 0.2
ai_max_long_patterns_remembered = 5
ai_long_pattern_recall_threshold = 0.05
ai_long_pattern_minimum_length = 2
ai_long_pattern_maximum_length = 5
ai_long_pattern_maximum_weight = 1.0
ai_short_pattern_maximum_weight = 0.5
ai_weight_decay_exponent = 1.1
ai_can_learn_from_observing = true