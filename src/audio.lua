local audio_manager = false -- private scoped singleton
local newSource = love.Audio.newSource

local function DeadlineMaxQueue(max_len, max_wait)
    local max_len = max_len or maxAudioQueueEvents
    local max_wait = max_wait or maxAudioQueueEvents
    local head = 1
    local tail = 1
    return {
        push = function(self, item)
            self[tail] = {
                time = love.timer.getTime(),
                item = item
            }
            tail = tail + 1
            if tail - head > max_len then
                self:pop()
            end
        end,
        pop = function(self)
            local time = love.timer.getTime()
            print("HEAD", head)
            local pair = self[head]
            assert(pair)
            self[head] = nil
            head = head + 1

            if time - pair.time > max_wait then
                return self:pop()
            else
                return pair.item
            end
        end,
        peek = function(self, idx)
            return self[head].item
        end
    }
end

GetAudioManager = function()
    -- Returns the audio manager singleton that manages loading, events
    -- and playing streams
    if audio_manager then
        return audio_manager
    else
        local audio_sources = setmetatable({}, {
            __index = function(self, idx)
                print("audio_sources.__index", self, idx)
                local t = rawget(self, assert(idx))
                if t == nil then
                    t = {}
                    rawset(self, idx, t)
                    print("Set default dict")
                end
                print("returning!")
                return t
            end
        })

        local pending_events = setmetatable({}, {
            __index = function(self, idx)
                local t = rawget(self, assert(idx))
                if t == nil then
                    t = DeadlineMaxQueue()
                    rawset(self, idx, t)
                end
                return t
            end
        })

        audio_manager = setmetatable({
            registerEvents = function(self, obj, event_triples)
                -- events should be a table of named-event keys, with
                -- audio source file values
                -- when an audio event is received from the given

                -- (audiofile, event_name, audio_action_name)
                -- event_triple = {"file.wav", "peck", "play"}
                assert(obj)
                for _, triple in ipairs(event_triples) do
                    local file, event_name, action = unpack(triple)
                    local source = assert(newSource("assets/audio/" .. file))
                    audio_sources[obj][event_name] = source
                    -- Now the audiofile is loaded we can
                    -- replace the third item with the obj
                    triple[1] = obj
                end
            end,

            stop = function(self, obj, event_name)
                love.audio.stop(audio_sources[obj][event_name])
            end,

            start = function(self, obj, event_name)
                love.audio.play(audio_sources[obj][event_name])
            end,

            rewind = function(self, obj, event)
                love.audio.rewind(audio_sources[obj][event_name])
            end,

            update = function(self)
                for k, v in pairs(pending_events) do
                    local event_triple = v:pop()
                    self[event_triple[2]](event_triple[1], audio_sources[obj])
                end
            end,

            sendEvent = function(self, obj, event_triple)

                pending_events[obj]:push(assert(event_triple))
            end
        }, {
            __tostring = function(self)
                return "audiomanager"
            end
        })

    end
    return audio_manager
end
return GetAudioManager
