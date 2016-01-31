local audio_manager = false -- private scoped singleton
local newSource = love.audio.newSource

local function DefaultDict(default_constructor)
    return setmetatable({}, {
        __index = function(self, idx)
            local v = rawget(self, assert(idx))
            if v == nil then
                v = default_constructor()
                rawset(self, idx, v)
            end
            return v
        end
    })
end

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
                -- prefer new events
                self:pop()
            end
        end,

        pop = function(self)
            local time = love.timer.getTime()
            local pair = self[head]
            if pair == nil then return nil end
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

local GetAudioManager = function()
    -- Returns the audio manager singleton that manages loading, events
    -- and playing streams
    if audio_manager then
        return audio_manager
    else
        local audio_sources = DefaultDict(function() return {} end)
        local pending_events = DefaultDict(DeadlineMaxQueue)

        audio_manager = setmetatable({
            registerEvents = function(self, obj, event_triples)
                -- events should be a triple of
                -- (audiofile, event_name, audio_action_name)
                -- event_triple = {"file.wav", "peck", "play"}
                assert(obj)
                for _, triple in ipairs(event_triples) do
                    local file, event, action = unpack(triple)
                    local source = assert(newSource("assets/audio/" .. file))
                    if not obj.AudioSources then
                        obj.AudioSources = {}
                    end
                    obj.AudioSources[file] = source
                    audio_sources[obj][event] = {
                        source = source,
                        callback = function()
                            source:setDirection(obj.x or 0.5, obj.y or 0.5)
                            self[action](self, obj.AudioSources[file])
                        end
                    }
                end
            end,

            stop = function(self, source)
                love.audio.stop(source)
            end,

            start = function(self, source)
                love.audio.play(source)
            end,

            play = function(self, source)
                love.audio.play(source)
            end,

            rewind = function(self, source)
                love.audio.rewind(source)
            end,

            update = function(self)
                for obj, ev in pairs(pending_events) do
                    local event = ev:pop()
                    if type(event) == 'string' then
                        audio_sources[obj][event].callback()
                    elseif type(event) == 'table' then
                        error("notimplemented", 2)
                        --FIXME lookup Volume and position in the table here
                    end
                end
            end,

            sendEvent = function(self, obj, event)
            --    print("sendEvent", obj, event)
                pending_events[obj]:push(event)
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
