return function(x, y)
    local particle_sprite = defaultParticleSprite
    local colours = {200, 200, 200, 128, 180, 180, 180, 128, 140, 140, 140, 50}
    local pr = love.graphics.newParticleSystem(
        love.graphics.newImage(particle_sprite),
        20 -- maxparticles in buffer
    )

    pr:setEmitterLifetime(1 + math.random(), 2 + math.random()) -- spit out a small number of "feather " particles
    pr:setColors(unpack(colours))

    return {
        emitted = false,
        pr = pr,
        rotation = math.random() * 1000 % math.pi,
        update = function(self, dt)
            if not self.emitted then
                self.emitted = true
                -- send out a puff on the first time
                self.pr:emit(20)
            end
            self.pr:update(dt)
        end,

        draw = function(self)
            love.graphics.draw(self.pr, x, y)
        end
    }
end
