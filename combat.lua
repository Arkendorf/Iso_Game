function combat_load()
  weapons = {}
  weapons[1] = {baseDmg = 5, idealDist = 48, rangePenalty = -.04, cost = 1}
  weapons[2] = {baseDmg = 1, idealDist = 48, rangePenalty = -.04, cost = 1}
end

function hitscan(a, b) -- a is shooter, b is target, dmg is damage to deal
  local dmg = getDamage(a, b)
  b.health = b.health - dmg

  -- particle stuff
  local x1, y1 = coordToIso(a.x, a.y)
  local x2, y2 = coordToIso(b.x, b.y)
  local angle = getAngle({x = x1, y = y1}, {x = x2, y = y2})
  local xOffset, yOffset = (tileSize*math.cos(angle)), (tileSize/2*math.sin(angle))
  particles[#particles + 1] = {x = x1+tileSize+xOffset, y = y1+tileSize/2+yOffset, img = muzzleFlashImg, quad = muzzleFlashQuad, time = .3, maxFrame = 3, frame = 1, speed = 10, z = 8, dir = angle}
  particles[#particles + 1] = {x = x2+tileSize-xOffset, y = y2+tileSize/2-yOffset, img = bloodImg, quad = bloodQuad, time = .3, maxFrame = 3, frame = 1, speed = 10, z = 8, dir = angle+math.pi}
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

function combat_update()
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
end
