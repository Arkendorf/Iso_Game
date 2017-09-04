function particle_load()
  particles = {}
  particleTypes = {}
  particleTypes[1] = {ai = 1, speed = 10, maxFrame = 3, time = .3, img = muzzleFlashImg, quad = muzzleFlashQuad}
  particleTypes[2] = {ai = 2, zV = 2, xV = 3, yV = 3, time = 10, img = bloodImg, quad = bloodQuad}
  particleAIs = {}

  particleAIs[1] = function(v, dt)
    -- set things to default if unspecified
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
  end

  particleAIs[2] = function(v, dt)
    if v.move == nil then
      v.move = true
    end

    if v.zV == nil then
      v.zV = particleTypes[v.type].zV
    end
    if v.xV == nil then
      v.xV = math.random(-particleTypes[v.type].xV*10, particleTypes[v.type].xV*10)/10
    end
    if v.yV == nil then
      v.yV = math.random(-particleTypes[v.type].yV*10, particleTypes[v.type].yV*10)/10
    end

    if v.move == true then
      v.z = v.z + v.zV
      v.zV = v.zV - 0.2*dt*60
      v.x = v.x + v.xV
      v.xV = v.xV * 0.9
      v.y = v.y + v.yV
      v.yV = v.yV * 0.9

      local x, y = coordToTile(v.x+tileSize/2, v.y+tileSize/2)
      if v.z < 0 then
        v.move = false
        v.frame = 2
      elseif x >= 1 and x <= #rooms[v.room][1] and y >= 1 and y <= #rooms[v.room] and tileType[rooms[v.room][y][x]] ~= 1 then
        v.move = false
        v.frame = 3
      end
    end
    v.alpha = (v.time/particleTypes[v.type].time)*255
  end
end

function particle_update(dt)
  local removeNils = false
  for i, v in ipairs(particles) do
    if v.alpha == nil then
      v.alpha = 255
    end
    if v.time == nil then
      v.time = particleTypes[v.type].time
    end
    if v.frame == nil then
      v.frame = 1
    end

    particleAIs[particleTypes[v.type].ai](v, dt)

    v.time = v.time - dt
    if v.time <= 0 then
      particles[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    particles = removeNil(particles)
  end
end

function queueParticles(room)
  for i, v in ipairs(particles) do
    if v.room == room then
      local x, y = coordToIso(v.x, v.y)
      if particleTypes[v.type].quad == nil then
        drawQueue[#drawQueue + 1] = {type = 2, img = particleTypes[v.type].img, x = x + tileSize, y = y+tileSize/2, z = v.z, angle = v.displayAngle, alpha = v.alpha}
      else
        drawQueue[#drawQueue + 1] = {type = 2, img = particleTypes[v.type].img, quad = particleTypes[v.type].quad[math.floor(v.frame)], x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle, alpha = v.alpha}
      end
    end
  end
end
