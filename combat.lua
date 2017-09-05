function combat_load()
  weapons = {}
  weapons[1] = {type = 2, baseDmg = 5, idealDist = 48, rangePenalty = -.04, cost = 1, projectile = 1}
  weapons[2] = {type = 2, baseDmg = 1, idealDist = 48, rangePenalty = -.04, cost = 1, projectile = 1}

  projectiles = {}
  projectiles[1] = {ai = 1, speed = 10, img = laserImg}

  projectileEntities = {}


  projectileAIs = {}
  projectileAIs[1] = function(v, dt)
    v.x = v.x + v.speed*dt*60*math.cos(v.angle)
    v.y = v.y + v.speed*dt*60*math.sin(v.angle)
  end
end

function attack(a, b)
  if weapons[a.weapon].type == 1 then
    hitscanAttack(a, b)
  elseif weapons[a.weapon].type == 2 then
    projectileAttack(a, b)
  end
end

function hitscanAttack(a, b) -- a is shooter, b is target, dmg is damage to deal
  local dmg = getDamage(a, b)
  b.futureHealth = b.futureHealth - dmg
  damage(dmg, a, b)

  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newParticle(a.room, a.x+xOffset, a.y+yOffset, 8, 1, displayAngle)
end

function projectileAttack(a, b)
  local dmg = getDamage(a, b)
  b.futureHealth = b.futureHealth - dmg

  -- particles stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newProjectile(dmg, a, b, a.x+xOffset, a.y+yOffset, 8, b.x-xOffset, b.y-yOffset, displayAngle)
  newParticle(a.room, a.x+xOffset, a.y+yOffset, 8, 1, displayAngle)
end

function newProjectile(dmg, a, b, x, y, z, dX, dY, displayAngle)
  local type = weapons[a.weapon].projectile
  projectileEntities[#projectileEntities + 1] = {dmg = dmg, b = b, a = a, x = x, y = y, z = z, dX = dX, dY = dY, angle = getAngle({x = x, y = y}, {x = dX, y = dY}), displayAngle = displayAngle, type = type, dir = getDirection({x = a.x, y = a.y}, {x = b.x, y = b.y}), speed = projectiles[type].speed}
end

function damage(dmg, a, b) -- a is damaging b
  b.health = b.health - dmg
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  for i = 1, math.floor(dmg) do
    newParticle(a.room, b.x-xOffset, b.y-yOffset, 8, 2, 0)
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
  for i, v in ipairs(projectileEntities) do
    projectileAIs[projectiles[v.type].ai](v, dt)
    if (v.dX - v.x)*v.dir.x <= 0 and (v.dY - v.y)*v.dir.y <= 0 then
      damage(v.dmg, v.a, v.b)
      projectileEntities[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    projectileEntities = removeNil(projectileEntities)
  end
end


function queueProjectiles(room)
  for i, v in ipairs(projectileEntities) do
    if v.a.room == room then
      local x, y = coordToIso(v.x, v.y)
      if projectiles[v.type].quad == nil then
        drawQueue[#drawQueue + 1] = {type = 2, img = projectiles[v.type].img, x = x+tileSize, y = y+tileSize/2, z = v.z, angle = v.displayAngle}
      else
        drawQueue[#drawQueue + 1] = {type = 2, img = projectiles[v.type].img, quad = projectiles[v.type].quad, x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle}
      end
    end
  end
end
