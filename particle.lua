function particle_load()
  particles = {}
  particleTypes = {}
  particleTypes[1] = {ai = 1, speed = 10, maxFrame = 3, time = .3, img = muzzleFlashImg, quad = muzzleFlashQuad}
  particleTypes[2] = {ai = 1, speed = 10, maxFrame = 3, time = .3, img = bloodImg, quad = bloodQuad}
  particleAIs = {}

  particleAIs[1] = function(v, dt)
    -- set things to default if unspecified
    if v.frame == nil then
      v.frame = 1
    end
    if v.maxFrame == nil then
      v.maxFrame = particleTypes[v.type].maxFrame
    end
    if v.speed == nil then
      v.speed = particleTypes[v.type].speed
    end
    if v.time == nil then
      v.time = particleTypes[v.type].time
    end

    -- ai stuff
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
    v.time = v.time - dt
  end
end

function particle_update(dt)
  for i, v in ipairs(particles) do
    particleAIs[particleTypes[v.type].ai](v, dt)
    if v.time <= 0 then
      particles[i] = nil
    end
  end
  particles = removeNil(particles)
end

function queueParticles(room)
  for i, v in ipairs(particles) do
    if v.room == room then
      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 2, img = particleTypes[v.type].img, quad = particleTypes[v.type].quad[math.floor(v.frame)], x = x + tileSize, y = y+tileSize/2, z = v.z, angle = v.displayAngle}
    end
  end
end
