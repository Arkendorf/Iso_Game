function particle_load()
  particles = {}
end

function particle_update(dt)
  for i, v in ipairs(particles) do
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
    v.time = v.time - dt
    if v.time <= 0 then
      particles[i] = nil
    end
  end
  particles = removeNil(particles)
end

function queueParticles(room)
  for i, v in ipairs(particles) do
    if v.room == room then
      drawQueue[#drawQueue + 1] = {type = 2, img = v.img, quad = v.quad[math.floor(v.frame)], x = v.x, y = v.y, z = v.z, angle = v.angle}
    end
  end
end
