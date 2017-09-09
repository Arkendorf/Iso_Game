function combat_load()
  weapons = {}
  weapons[1] = {type = 2, targetMode = 2, baseDmg = 5, idealDist = 48, rangePenalty = .04, cost = 1, projectile = 1, AOE = 4000, falloff = .04, icon = 1}
  weapons[2] = {type = 2, targetMode = 1, baseDmg = 1, idealDist = 48, rangePenalty = .04, cost = 1, projectile = 1, AOE = 0, icon = 1}

  projectiles = {}
  projectiles[1] = {ai = 1, speed = 10, z = 8, img = laserImg}

  projectileEntities = {}


  projectileAIs = {}
  projectileAIs[1] = function(v, dt)
    v.x = v.x + v.speed*dt*60*math.cos(v.angle)
    v.y = v.y + v.speed*dt*60*math.sin(v.angle)
  end
end

function attack(a, b, table)
  if weapons[a.actor.item.weapon].type == 1 then
    hitscanAttack(a, b, table)
  elseif weapons[a.actor.item.weapon].type == 2 then
    projectileAttack(a, b, table)
  end
end

function hitscanAttack(a, b, table, info) -- a is shooter, b is target, table is who is getting hurt
  local dmg = 0
  futureDamage(a, b, table, info)
  damage(a, b, table, info)


  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newParticle(a.room, a.x+xOffset, a.y+yOffset, 1, displayAngle)
end

function projectileAttack(a, b, table, info)
  futureDamage(a, b, table, info)

  -- particles stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newProjectile(table, info, a, b, a.x+xOffset, a.y+yOffset, b.x-xOffset, b.y-yOffset, displayAngle)
  newParticle(a.room, a.x+xOffset, a.y+yOffset, 1, displayAngle)
end

function newProjectile(table, info, a, b, x, y, dX, dY, displayAngle)
  local type = weapons[a.actor.item.weapon].projectile
  projectileEntities[#projectileEntities + 1] = {table = table, info = info, b = b, a = a, x = x, y = y, z = projectiles[type].z, dX = dX, dY = dY, angle = getAngle({x = x, y = y}, {x = dX, y = dY}), displayAngle = displayAngle, type = type, dir = getDirection({x = a.x, y = a.y}, {x = b.x, y = b.y}), speed = projectiles[type].speed}
end

function damage(a, b, table, info)
  for i, v in ipairs(table) do
    if v.dead == false then
      dmg = getDamage(a, v, b, info)
      v.health = v.health - dmg
      local angle = getAngle({x = a.x, y = a.y}, {x = v.x, y = v.y})
      local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

      for i = 1, math.floor(dmg) do
        newParticle(a.room, v.x-xOffset, v.y-yOffset, 2, 0)
      end
    end
  end
end

function futureDamage(a, b, table, info)
  for i, v in ipairs(table) do
    if v.dead == false then
      dmg = getDamage(a, v, b, info)
      v.futureHealth = v.futureHealth - dmg
    end
  end
end

function getDamage(a, b, pos, info)
  if a.room ~= b.room then -- if target isnt in same room, no damage can be dealt
    return 0
  end

  if info == nil then -- if no info is given, default to attacker's weapon info
    info = weapons[a.actor.item.weapon]
  end

  local dmg = 0
  if info.baseDmg ~= nil then -- if baseDmg is given, set dmg to baseDmg, otherwise dmg is 0
    dmg = info.baseDmg
  else
    return 0
  end

  if info.AOE ~= nil then -- if dmg is AOE,
    local dist = getDistance(b, pos)
    if dist <= info.AOE and LoS({x = pos.x, y = pos.y}, {x = b.x, y = b.y}, rooms[a.room]) == true then
      if info.falloff ~= nil then
        dmg = dmg - dist * info.falloff
      end
    else
      return 0
    end
  elseif b.x ~= pos.x or b.y ~= pos.y then
    return 0
  end

  if info.idealDist ~= nil and info.rangePenalty ~= nil then -- if attack has an ideal range, check if distance is in that range
    local dist = getDistance(a, pos) - info.idealDist
    if dist < 0 then
      dist = 0
    end
    dmg = dmg - dist * info.rangePenalty
  end

  if isUnderCover(b, a, rooms[a.room]) == true or isUnderCover(b, pos, rooms[a.room]) == true then -- halve damage if target is behind cover
    dmg = dmg / 2
  end

  if dmg > 0 then -- make sure dmg isn't negative
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
      damage(v.a, v.b, v.table, v.info)
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
      drawQueue[#drawQueue + 1] = {type = 2, img = projectiles[v.type].img, quad = projectiles[v.type].quad, x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle}
    end
  end
end
