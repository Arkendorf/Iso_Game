function combat_load()
  weapons = {}
  weapons[1] = {type = 2, baseDmg = 5, idealDist = 48, rangePenalty = -.04, cost = 1, speed = 3}
  weapons[2] = {type = 1, baseDmg = 1, idealDist = 48, rangePenalty = -.04, cost = 1}
  projectiles = {}
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
  b.health = b.health - dmg

  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local xOffset, yOffset = (tileSize*math.cos(displayAngle)), (tileSize/2*math.sin(displayAngle))
  particles[#particles + 1] = {room = a.room, x = x1+tileSize+xOffset, y = y1+tileSize/2+yOffset, img = muzzleFlashImg, quad = muzzleFlashQuad, time = .3, maxFrame = 3, frame = 1, speed = 10, z = 8, dir = displayAngle}
  particles[#particles + 1] = {room = a.room, x = x2+tileSize-xOffset, y = y2+tileSize/2-yOffset, img = bloodImg, quad = bloodQuad, time = .3, maxFrame = 3, frame = 1, speed = 10, z = 8, dir = displayAngle+math.pi}
end

function projectile(a, b)
  local dmg = getDamage(a, b)
  b.health = b.health - dmg

  local speed = weapons[a.weapon].speed
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local displayAngle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local xOffset, yOffset = (tileSize*math.cos(displayAngle)), (tileSize/2*math.sin(displayAngle))

  projectiles[#projectiles + 1] = {room = a.room, x = a.x, y = a.y, z = 8, dX = b.x, dY = b.y, speed = speed, dir = displayAngle, angle = getAngle({x = a.x, y = a.y}, {x = b.x, y = b.y})}
  particles[#particles + 1] = {room = a.room, x = x1+tileSize+xOffset, y = y1+tileSize/2+yOffset, img = muzzleFlashImg, quad = muzzleFlashQuad, time = .3, maxFrame = 3, frame = 1, speed = 10, z = 8, dir = displayAngle}
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

  for i, v in ipairs(projectiles) do
    local distance = getDistance({x = v.x, y = v.y}, {x = v.dX, y = v.dY})
    if distance <= v.speed or v.x < 0 or v.x > #rooms[v.room][1]*tileSize or v.y < 0 or v.y > #rooms[v.room]*tileSize then
      projectiles[i] = nil
    else
      v.x = v.x + v.speed*dt*60*math.cos(v.angle)
      v.y = v.y + v.speed*dt*60*math.sin(v.angle)
    end
  end
  projectiles = removeNil(projectiles)
end


function queueProjectiles(room)
  for i, v in ipairs(projectiles) do
    if v.room == room then
      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 2, img = bloodImg, quad = bloodQuad[2], x = x+tileSize, y = y+tileSize/2, z = v.z, dir = v.dir}
    end
  end
end
