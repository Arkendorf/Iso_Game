function combat_load()
  weapons = {}
  weapons[1] = {baseDmg = 5, idealDist = 48, rangePenalty = -.04, cost = 1}
  weapons[2] = {baseDmg = 1, idealDist = 48, rangePenalty = -.04, cost = 1}
end

function hitscan(a, b) -- a is shooter, b is target, dmg is damage to deal
  local dmg = getDamage(a, b)
  b.health = b.health - dmg
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
  currentLevel.actors = removeNil(currentLevel.actors)
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.health <= 0 then
      v.dead = true
    end
  end
  currentLevel.enemyActors = removeNil(currentLevel.enemyActors)
end
