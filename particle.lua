function particle_load()
  particles = {}
  particles[1] = {ai = 1, startAI = 1, z = 8, time = .3, speed = 10, maxFrame = 3, img = muzzleFlashImg, quad = muzzleFlashQuad}
  particles[2] = {ai = 2, startAI = 2, z = 8, time = 10, zV = 2, xV = 3, yV = 3, img = bloodImg, quad = bloodQuad}
  particles[3] = {ai = 2, startAI = 2, z = 16, time = 10, zV = 0, xV = 1.5, yV = 1.5, img = goopImg, quad = goopQuad}

  particleEntities = {}

  particleAIs = {}

  particleAIs[1] = function(v, dt)
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
  end

  particleAIs[2] = function(v, dt)
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
      elseif x >= 1 and x <= #rooms[v.room][1] and y >= 1 and y <= #rooms[v.room] then
        if tileType[rooms[v.room][y][x]] ~= 1 then
          v.move = false
          v.frame = 3
        end
      end
    end
    v.alpha = (v.time/particles[v.type].time)*255
  end

  particleStartAIs = {}

  particleStartAIs[1] = function (v)
    v.speed = particles[v.type].speed
    v.maxFrame = particles[v.type].maxFrame
  end

  particleStartAIs[2] = function (v)
    v.move = true
    v.zV = particles[v.type].zV
    v.xV = math.random(-particles[v.type].xV*10, particles[v.type].xV*10)/10
    v.yV = math.random(-particles[v.type].yV*10, particles[v.type].yV*10)/10
  end
end

function newParticle(room, x, y, type, displayAngle)
  particleEntities[#particleEntities + 1] = {room = room, x = x, y = y, type = type, z = particles[type].z, displayAngle = displayAngle, time = particles[type].time, frame = 1, alpha = 255}
  particleStartAIs[particles[type].startAI](particleEntities[#particleEntities])
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
      drawQueue[#drawQueue + 1] = {type = 2, img = particles[v.type].img, quad = particles[v.type].quad[math.floor(v.frame)], x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle, alpha = v.alpha}
    end
  end
end
