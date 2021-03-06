function combat_load()
  weapons = {}
  weapons[1] = {type = 1, targetMode = 1, baseDmg = 5, dist = {range = 3, falloff = 1}, pierce = false, cost = 1, projectile = 1, icon = 1, particle = 1, img = 1}
  weapons[2] = {type = 2, targetMode = 1, baseDmg = 1, dist = {range = 3, falloff = 1}, cost = 1, projectile = 1, icon = 1, particle = 1, img = 1}
  weapons[3] = {type = 3, targetMode = 2, baseDmg = 5, dist = {range = 3, falloff = 1}, cost = 1, projectile = 1, icon = 1, particle = 1, AOE = {range = 3, falloff = 1}, range = 3, img = 1} -- example weapon

  projectiles = {}
  projectiles[1] = {ai = 1, speed = 10, z = 8, img = 1}
  projectiles[2] = {ai = 1, speed = 2, z = 8, img = 1}

  projectileAIs = {}
  projectileAIs[1] = function(v, dt)
    v.x = v.x + v.speed*dt*60*math.cos(v.angle)
    v.y = v.y + v.speed*dt*60*math.sin(v.angle)
  end

  findTargetFuncs = {}

  findTargetFuncs[1] = function (actor, cursorPos, table)
    for i, v in ipairs(table) do
      local tX, tY = coordToTile(v.x, v.y)
      if v.room == actor.room and v.dead == false and cursorPos.tX == tX and cursorPos.tY == tY then
        if not actor.seen or actor.seen[i] == true then -- if enemy is finding target, make sure target is seen
          return v
        end
      end
    end
    return nil
  end

  findTargetFuncs[2] = function (actor, cursorPos, table)
    local x, y = tileToCoord(cursorPos.tX, cursorPos.tY)
    return {x = x, y = y, tX = cursorPos.tX, tY = cursorPos.tY}
  end

  findTargetFuncs[3] = function (actor, cursorPos, table)
    return actor
  end

  targetValidFuncs = {}

  targetValidFuncs[1] = function (enemy, actor, cost)
    if enemy and actor.turnPts >= cost then
      if enemy.room == actor.room and enemy.dead == false and enemy.futureHealth > 0 and LoS({x = actor.x, y = actor.y}, {x = enemy.x, y = enemy.y}, rooms[actor.room]) == true then
        return true
      else
        return false
      end
    else
      return false
    end
  end

  targetValidFuncs[2] = function (enemy, actor, cost)
    if actor.turnPts >= cost and LoS({x = actor.x, y = actor.y}, {x = enemy.x, y = enemy.y}, rooms[actor.room]) == true  then
      return true
    end
    return false
  end

  targetValidFuncs[3] = function (enemy, actor, cost)
    if actor.turnPts >= cost then
      return true
    end
    return false
  end

  rps = {{blood = 2}, {blood = 5}, {blood = 4}}
end

function attack(a, b, table)
  if not weapons[a.actor.item.weapon].type or weapons[a.actor.item.weapon].type == 1 then
    hitscanAttack(a, b, table)
  elseif weapons[a.actor.item.weapon].type > 1 then
    projectileAttack(a, b, table)
  end
end

function hitscanAttack(a, b, table, info) -- a is shooter, b is target, table is who is getting hurt
  if not info then -- if no info is given, default to attacker's weapon info
    info = weapons[a.actor.item.weapon]
  end
  futureDamage(a, b, table, info)
  damage(a, b, table, info)

  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  if info.particle then
    newParticle(a.room, a.x+xOffset, a.y+yOffset, info.particle, displayAngle, charImgs.height[a.actor.item.img]-charImgs.info[a.actor.item.img].center[a.dir].y-tileSize/2)
  else
    newParticle(a.room, a.x+xOffset, a.y+yOffset, 1, displayAngle, charImgs.height[a.actor.item.img]-charImgs.info[a.actor.item.img].center[a.dir].y-tileSize/2)
  end
end

function projectileAttack(a, b, table, info)
  if not info then -- if no info is given, default to attacker's weapon info
    info = weapons[a.actor.item.weapon]
  end
  futureDamage(a, b, table, info)

  -- particles stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})
  local xOffset, yOffset = (tileSize/2*math.cos(angle)), (tileSize/2*math.sin(angle))

  newProjectile(table, info, a, b, a.x+xOffset, a.y+yOffset, b.x-xOffset, b.y-yOffset, displayAngle, charImgs.height[a.actor.item.img]-charImgs.info[a.actor.item.img].center[a.dir].y-tileSize/2)
  if info.particle then
    newParticle(a.room, a.x+xOffset, a.y+yOffset, info.particle, displayAngle, charImgs.height[a.actor.item.img]-charImgs.info[a.actor.item.img].center[a.dir].y-tileSize/2)
  else
    newParticle(a.room, a.x+xOffset, a.y+yOffset, 1, displayAngle, charImgs.height[a.actor.item.img]-charImgs.info[a.actor.item.img].center[a.dir].y-tileSize/2)
  end
end

function newProjectile(table, info, a, b, x, y, dX, dY, displayAngle, type, z)
  local type = info.projectile
  if not z then
    z = projectiles[type].z
  end
  currentLevel.projectiles[#currentLevel.projectiles + 1] = {table = table, info = info, b = b, a = a, x = x, y = y, z = z, dX = dX, dY = dY, angle = getAngle({x = x, y = y}, {x = dX, y = dY}), displayAngle = displayAngle, type = type, dir = getDirection({x = a.x, y = a.y}, {x = b.x, y = b.y}), speed = projectiles[type].speed}
end

function damage(a, b, table, info)
  for i, v in ipairs(table) do
    if v.dead == false then
      dmg = getDamage(a, v, b, info)
      v.health = v.health - dmg

      if v.health <= 0 then
        v.death = {killer = a, dmg = dmg}
      end

      for i = 1, math.ceil(dmg) do -- bleed
        newParticle(a.room, v.x, v.y, rps[v.actor.item.type].blood, 0, (charImgs.height[v.actor.item.img]-tileSize)/2)
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

function getTotalDamage(a, pos, table, info)
  local dmg = 0
  local kills = 0
  for i, v in ipairs(table) do
    if v.room == a.room then
      local currentDmg = getDamage(a, v, pos, info)
      if v.health - currentDmg <= 0 then
        kills = kills + 1
      end
      dmg = dmg + currentDmg
    end
  end
  return dmg, kills
end

function getDamage(a, b, pos, info)
  if a.room ~= b.room then -- if target isnt in same room, no damage can be dealt
    return 0
  end

  if not info then -- if no info is given, default to attacker's weapon info
    info = weapons[a.actor.item.weapon]
  end

  local dmg = 0
  if info.baseDmg then -- if baseDmg is given, set dmg to baseDmg, otherwise dmg is 0
    dmg = info.baseDmg
  else
    return 0
  end

  if info.AOE then -- if dmg is AOE,
    local dist = getDistance(b, pos)/tileSize
    if dist <= info.AOE.range and LoS({x = pos.x, y = pos.y}, {x = b.x, y = b.y}, rooms[a.room]) == true then
      if info.AOE.falloff then
        dmg = dmg - dist * info.AOE.falloff
      end
    else
      return 0
    end
  elseif b.x ~= pos.x or b.y ~= pos.y then
    return 0
  end

  if info.dist then -- if attack has an ideal range, check if distance is in that range
    local dist = getDistance(a, pos)/tileSize - info.dist.range
    if dist < 0 then
      dist = 0
    end
    dmg = dmg - dist * info.dist.falloff
  end

  if not info.pierce and (isUnderCover(b, a, rooms[a.room]) == true or isUnderCover(b, pos, rooms[a.room]) == true) then -- halve damage if target is behind cover
    dmg = dmg / 2
  end

  if info.type and b.actor.item.type and crit(info.type, b.actor.item.type) then -- check if attack is a crit
    dmg = dmg * 1.2
  end

  if dmg > 0 then -- make sure dmg isn't negative
    return dmg
  else
    return 0
  end
end

function crit(type1, type2)
  return type1 == type2
end

function combat_update(dt)
  for i, v in ipairs(currentLevel.actors) do
    if v.health <= 0 and v.dead == false then
      -- face killer
      local dir = getDirection(v, v.death.killer)
      v.dir = coordToStringDir(dir)
      -- set up ragdoll
      local angle = getAngle({x = v.death.killer.x, y = v.death.killer.y}, {x = v.x, y = v.y})
      local xOffset, yOffset = (v.death.dmg*math.cos(angle))*.2, (v.death.dmg*math.sin(angle))*.2
      v.ragdoll = {xV = xOffset, yV = yOffset}

      v.dead = true
      v.anim.quad = 6 -- draw player as dead
      for j, k in ipairs(currentLevel.enemyActors) do
        k.seen[i] = false
      end
      if v.actor.item.vip then -- if vip dies, end level
        love.event.quit()
      end
      if i == currentActorNum then
        nextActor()
        if i == currentActorNum then
          love.event.quit()
          break
        end
      end

      checkForObstructions()
    end
  end

  for i, v in ipairs(currentLevel.enemyActors) do
    if v.health <= 0 and v.dead == false then
      -- face killer
      local dir = getDirection(v, v.death.killer)
      v.dir = coordToStringDir(dir)
      -- set up ragdoll
      local angle = getAngle({x = v.death.killer.x, y = v.death.killer.y}, {x = v.x, y = v.y})
      local xOffset, yOffset = (v.death.dmg*math.cos(angle))*.2, (v.death.dmg*math.sin(angle))*.2
      v.ragdoll = {xV = xOffset, yV = yOffset}

      v.dead = true
      v.anim.quad = 6 -- draw enemy as dead

      checkForObstructions()
    end
  end

  local removeNils = false
  for i, v in ipairs(currentLevel.projectiles) do
    projectileAIs[projectiles[v.type].ai](v, dt)
    if (v.dX - v.x)*v.dir.x <= 0 and (v.dY - v.y)*v.dir.y <= 0 then
      damage(v.a, v.b, v.table, v.info)
      currentLevel.projectiles[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    currentLevel.projectiles = removeNil(currentLevel.projectiles)
  end
end

function queueProjectiles(room)
  for i, v in ipairs(currentLevel.projectiles) do
    if v.a.room == room then
      local img = projectiles[v.type].img
      local x, y = coordToIso(v.x, v.y)
      if not projectileImgs.quad[img] then
        drawQueue[#drawQueue + 1] = {type = 2, img = projectileImgs.img[img], x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle}
      else
        drawQueue[#drawQueue + 1] = {type = 2, img = projectileImgs.img[img], quad = projectileImgs.img[img][math.floor(v.frame)], x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z = v.z, angle = v.displayAngle}
      end
    end
  end
end
