function combat_load()
  weapons = {}
  weapons[1] = {type = 2, targetMode = 2, baseDmg = 5, idealDist = 48, rangePenalty = .04, cost = 1, projectile = 1, AOE = 4000, falloff = .04}
  weapons[2] = {type = 2, targetMode = 1, baseDmg = 1, idealDist = 48, rangePenalty = .04, cost = 1, projectile = 1, AOE = 0}

  projectiles = {}
  projectiles[1] = {ai = 1, speed = 10, img = laserImg}

  projectileEntities = {}


  projectileAIs = {}
  projectileAIs[1] = function(v, dt)
    v.x = v.x + v.speed*dt*60*math.cos(v.angle)
    v.y = v.y + v.speed*dt*60*math.sin(v.angle)
  end
end

function attack(a, b, table)
  if weapons[a.weapon].type == 1 then
    hitscanAttack(a, b, table)
  elseif weapons[a.weapon].type == 2 then
    projectileAttack(a, b, table)
  end
end

function hitscanAttack(a, b, table) -- a is shooter, b is target, table is who is getting hurt
  local dmg = 0
  futureDamageEnemies(a, b, table)
  damageEnemies(a, b, table)


  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newParticle(a.room, a.x+xOffset, a.y+yOffset, 8, 1, displayAngle)
end

function projectileAttack(a, b, table)
  futureDamageEnemies(a, b, table)

  -- particles stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newProjectile(table, a, b, a.x+xOffset, a.y+yOffset, 8, b.x-xOffset, b.y-yOffset, displayAngle)
  newParticle(a.room, a.x+xOffset, a.y+yOffset, 8, 1, displayAngle)
end

function newProjectile(table, a, b, x, y, z, dX, dY, displayAngle)
  local type = weapons[a.weapon].projectile
  projectileEntities[#projectileEntities + 1] = {table = table, b = b, a = a, x = x, y = y, z = z, dX = dX, dY = dY, angle = getAngle({x = x, y = y}, {x = dX, y = dY}), displayAngle = displayAngle, type = type, dir = getDirection({x = a.x, y = a.y}, {x = b.x, y = b.y}), speed = projectiles[type].speed}
end

function damageEnemies(a, b, table)
  for i, v in ipairs(table) do
    if v.dead == false then
      dmg = getDamage(a, v, b, weapons[a.weapon].AOE, weapons[a.weapon].falloff)
      v.health = v.health - dmg
      local angle = getAngle({x = a.x, y = a.y}, {x = v.x, y = v.y})
      local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

      for i = 1, math.floor(dmg) do
        newParticle(a.room, v.x-xOffset, v.y-yOffset, 8, 2, 0)
      end
    end
  end
end

function futureDamageEnemies(a, b, table)
  for i, v in ipairs(table) do
    if v.dead == false then
      dmg = getDamage(a, v, b, weapons[a.weapon].AOE, weapons[a.weapon].falloff)
      v.futureHealth = v.futureHealth - dmg
    end
  end
end

function getWeaponDamage(a, b) -- entity a is attacking entity b
  local dmg = weapons[a.weapon].baseDmg
  if weapons[a.weapon].idealDist ~= nil and weapons[a.weapon].rangePenalty ~= nil then
    local dist = getDistance(a, b) - weapons[a.weapon].idealDist
    if dist < 0 then
      dist = 0
    end
    dmg = dmg - dist * weapons[a.weapon].rangePenalty
  end
  if isUnderCover(b, a, rooms[a.room]) == true then
    dmg = dmg / 2
  end
  if dmg > 0 then
    return dmg
  else
    return 0
  end
end


function getDamage(a, b, pos, r, falloff)
  local dmg = weapons[a.weapon].baseDmg
  if weapons[a.weapon].idealDist ~= nil and weapons[a.weapon].rangePenalty ~= nil then
    local dist = getDistance(a, pos) - weapons[a.weapon].idealDist
    if dist < 0 then
      dist = 0
    end
    dmg = dmg - dist * weapons[a.weapon].rangePenalty
  end
  if isUnderCover(b, a, rooms[a.room]) == true or isUnderCover(b, pos, rooms[a.room]) == true then
    dmg = dmg / 2
  end
  local dist = getDistance(b, pos)
  if dist <= r and LoS({x = pos.x, y = pos.y}, {x = b.x, y = b.y}, rooms[a.room]) == true then
    if falloff ~= nil then
      dmg = dmg - dist * falloff
    end
  else
    dmg = 0
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
      damageEnemies(v.a, v.b, v.table)
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
