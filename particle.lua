function particle_load()
  particles = {}
  particles[1] = {ai = 1, speed = 10, maxFrame = 3, time = .3, img = muzzleFlashImg, quad = muzzleFlashQuad}
  particles[2] = {ai = 2, zV = 2, xV = 3, yV = 3, time = 10, img = bloodImg, quad = bloodQuad}
  
  particleEntities = {}

  particleAIs = {}

  particleAIs[1] = function(v, dt)
    -- set things to default if unspecified
    if v.maxFrame == nil then
      v.maxFrame = particles[v.type].maxFrame
    end
    if v.speed == nil then
      v.speed = particles[v.type].speed
    end
    if v.time == nil then
      v.time = particles[v.type].time
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
      v.zV = particles[v.type].zV
    end
    if v.xV == nil then
      v.xV = math.random(-particles[v.type].xV*10, particles[v.type].xV*10)/10
    end
    if v.yV == nil then
      v.yV = math.random(-particles[v.type].yV*10, particles[v.type].yV*10)/10
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
    v.alpha = (v.time/particles[v.type].time)*255
  end
end

function newParticle(room, x, y, z, type, displayAngle, time, frame, alpha)
  local i = #particleEntities + 1
  particleEntities[i] = {room = room, x = x, y = y, type = type, z = z, displayAngle = displayAngle, time = time, frame = frame, alpha = alpha}
  if alpha == nil then
    particleEntities[i].alpha = 255
  end
  if time == nil then
    particleEntities[i].time = particles[particleEntities[i].type].time
  end
  if frame == nil then
    particleEntities[i].frame = 1
  end
end

function particle_update(dt)
  local removeNils = false
  for i, v in ipairs(particleEntities) do
    particleAIs[particles[v.type].ai](v, dt)

    v.time = v.time - dt
    if v.time <= 0 then
      particleEntities[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    particleEntities = removeNil(particleEntities)
  end
end

function queueParticles(room)
  for i, v in ipairs(particleEntities) do
    if v.room == room then
      local x, y = coordToIso(v.x, v.y)
      if particles[v.type].quad == nil then
        drawQueue[#drawQueue + 1] = {type = 2, img = particles[v.type].img, x = x + tileSize, y = y+tileSize/2, z = v.z, angle = v.displayAngle, alpha = v.alpha}
      else
        drawQueue[#drawQueue + 1] = {type = 2, img = particles[v.type].img, quad = particles[v.type].quad[math.floor(v.frame)], x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle, alpha = v.alpha}
      end
    end
  end
end
