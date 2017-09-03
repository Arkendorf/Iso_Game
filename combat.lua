function combat_load()
  weapons = {}
  weapons[1] = {type = 2, baseDmg = 5, idealDist = 48, rangePenalty = -.04, cost = 1, projectileType = 1}
  weapons[2] = {type = 2, baseDmg = 1, idealDist = 48, rangePenalty = -.04, cost = 1, projectileType = 1}
  projectiles = {}
  projectileTypes = {}
  projectileTypes[1] = {ai = 1, speed = .2, img = laserImg}

  projectileAIs = {}
  projectileAIs[1] = function(v, dt)
    if v.dir == nil then
      v.dir = getDirection({x = v.x, y = v.y}, {x = v.dX, y = v.dY})
    end
    if v.speed == nil then
      v.speed = projectileTypes[v.type].speed
    end
    v.x = v.x + v.speed*dt*60*math.cos(v.angle)
    v.y = v.y + v.speed*dt*60*math.sin(v.angle)
  end
end

function attack(a, b)
  if weapons[a.weapon].type == 1 then
    hitscan(a, b)
  elseif weapons[a.weapon].type == 2 then
    projectile(a, b)
  end
end

function hitscan(a, b) -- a is shooter, b is target, dmg is damage to deal
  local dmg = getDamage(a, b)
  b.futureHealth = b.futureHealth - dmg
  damage(dmg, a, b)

  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  particles[#particles + 1] = {room = a.room, x = a.x+xOffset, y = a.y+yOffset, type = 1, z = 8, displayAngle = displayAngle}
end

function projectile(a, b)
  local dmg = getDamage(a, b)
  b.futureHealth = b.futureHealth - dmg

  -- particles stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  projectiles[#projectiles + 1] = {dmg = dmg, b = b, a = a, x = a.x+xOffset, y = a.y+yOffset, z = 8, dX = b.x-xOffset, dY = b.y-yOffset, angle = angle, displayAngle = displayAngle}
  particles[#particles + 1] = {room = a.room, x = a.x+xOffset, y = a.y+yOffset, type = 1, z = 8, displayAngle = displayAngle}
end

function damage(dmg, a, b) -- a is damaging b
  b.health = b.health - dmg
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  for i = 1, math.floor(dmg) do
    particles[#particles + 1] = {room = a.room, x = b.x-xOffset, y = b.y-yOffset, type = 2, z = 8, displayAngle = 0}
  end
end

function getDamage(a, b) -- entity a is attacking entity b
  local dmg = weapons[a.weapon].baseDmg
  local dist = getDistance(a, b) -  weapons[a.weapon].idealDist
  if dist < 0 then
    dist = 0
  end
  dmg = dmg + dist * weapons[a.weapon].rangePenalty
  if isUnderCover(b, a, rooms[a.room]) == true then
    dmg = dmg / 2
  end
  if dmg > 0 then
    return dmg
  else
    return 0
  end
end

function combat_update(dt)
  for i, v in ipairs(currentLevel.actors) do
    if v.health <= 0 then
      v.dead = true
      for j, k in ipairs(currentLevel.enemyActors) do
        k.seen[i] = false
      end
      if i == currentActorNum then
        nextActor()
        if i == currentActorNum then
          love.event.quit()
          break
        end
      end
    end
  end

  for i, v in ipairs(currentLevel.enemyActors) do
    if v.health <= 0 then
      v.dead = true
    end
  end

  local removeNils = false
  for i, v in ipairs(projectiles) do
    if v.type == nil then
      v.type = weapons[v.a.weapon].projectileType
    end
    projectileAIs[projectileTypes[v.type].ai](v, dt)
    if (v.dX - v.x)*v.dir.x <= 0 and (v.dY - v.y)*v.dir.y <= 0 then
      damage(v.dmg, v.a, v.b)
      projectiles[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    projectiles = removeNil(projectiles)
  end
end


function queueProjectiles(room)
  for i, v in ipairs(projectiles) do
    if v.a.room == room then
      local x, y = coordToIso(v.x, v.y)
      if projectileTypes[v.type].quad == nil then
        drawQueue[#drawQueue + 1] = {type = 2, img = projectileTypes[v.type].img, x = x+tileSize, y = y+tileSize/2, z = v.z, angle = v.displayAngle}
      else
        drawQueue[#drawQueue + 1] = {type = 2, img = projectileTypes[v.type].img, quad = projectileTypes[v.type].quad, x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle}
      end
    end
  end
end
