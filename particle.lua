function particle_load()
  particles = {}
  particles[1] = {ai = 1, startAI = 1, z = 8, time = .3, speed = 10, maxFrame = 3, img = 1}
  particles[2] = {ai = 2, startAI = 2, z = 8, time = 10, zV = 2, xV = 3, yV = 3, img = 2}
  particles[3] = {ai = 2, startAI = 2, z = 16, time = 10, zV = 0, xV = 1.5, yV = 1.5, img = 3}
  particles[4] = {ai = 2, startAI = 2, z = 8, time = 10, zV = 2, xV = 3, yV = 3, img = 4}
  particles[5] = {ai = 3, startAI = 3, z = 8, time = .3, speed = 10, maxFrame = 3, xV = 1.5, yV = 1.5, img = 5}


  particleAIs = {}

  particleAIs[1] = function(v, dt)
    v.frame = v.frame + dt * v.speed
    if v.frame >= v.maxFrame+1 then
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

  particleAIs[3] = function(v, dt)
    v.x = v.x + v.xV
    v.xV = v.xV * 0.9
    v.y = v.y + v.yV
    v.yV = v.yV * 0.9
    v.frame = v.frame + dt * v.speed
    if v.frame >= v.maxFrame+1 then
      v.frame = 1
    end
  end

  particleStartAIs = {}

  particleStartAIs[1] = function (v)
    v.speed = particles[v.type].speed
    v.maxFrame = particles[v.type].maxFrame
  end

  particleStartAIs[2] = function (v)
    v.displayAngle = 0
    v.move = true
    v.zV = math.random(0, particles[v.type].zV*10)/10
    v.xV = math.random(-particles[v.type].xV*10, particles[v.type].xV*10)/10
    v.yV = math.random(-particles[v.type].yV*10, particles[v.type].yV*10)/10
  end

  particleStartAIs[3] = function (v)
    v.speed = particles[v.type].speed
    v.maxFrame = particles[v.type].maxFrame
    v.xV = math.random(-particles[v.type].yV*10, particles[v.type].yV*10)/10
    v.yV = math.random(-particles[v.type].yV*10, particles[v.type].yV*10)/10
    v.displayAngle = math.atan2(v.yV, v.xV) + math.rad(45)
  end
end

function newParticle(room, x, y, type, displayAngle, z)
  if not z then
    z = particles[type].z
  end
  currentLevel.particles[#currentLevel.particles + 1] = {room = room, x = x, y = y, type = type, z = z, displayAngle = displayAngle, time = particles[type].time, frame = 1, alpha = 255}
  particleStartAIs[particles[type].startAI](currentLevel.particles[#currentLevel.particles])
end

function particle_update(dt)
  local removeNils = false
  for i, v in ipairs(currentLevel.particles) do
    particleAIs[particles[v.type].ai](v, dt)

    v.time = v.time - dt
    if v.time <= 0 then
      currentLevel.particles[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    currentLevel.particles = removeNil(currentLevel.particles)
  end
end

function drawFlatParticles(room)
  for i, v in ipairs(currentLevel.particles) do
    if v.room == room and v.z <= 0 then
      local img = particles[v.type].img
      local x, y = coordToIso(v.x, v.y)
      love.graphics.setShader(shaders.pixelFade) -- if particle is partially transparent, set shader accordingly
      shaders.pixelFade:send("a", v.alpha/255)
      if not particleImgs.quad[img] then
        local w, h = particleImgs.width[img], particleImgs.height[img]
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(particleImgs.img[img], math.floor(x)+tileSize, math.floor(y)+tileSize/2, v.displayAngle, 1, 1, math.floor(w/2), math.floor(h/2))
      else
        local w, h = particleImgs.width[img], particleImgs.height[img]
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(particleImgs.img[img], particleImgs.quad[img][math.floor(v.frame)], math.floor(x)+tileSize, math.floor(y)+tileSize/2, v.displayAngle, 1, 1, math.floor(w/2), math.floor(h/2))
      end
      love.graphics.setShader() -- reset shader
    end
  end
end

function queueParticles(room)
  for i, v in ipairs(currentLevel.particles) do
    if v.room == room and v.z > 0 then
      local img = particles[v.type].img
      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 2, img = particleImgs.img[img], quad = particleImgs.quad[img][math.floor(v.frame)], x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle, alpha = v.alpha, w = particleImgs.width[img], h = particleImgs.height[img]}
    end
  end
end
