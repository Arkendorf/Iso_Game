function combat_load()
  weapons = {}
  weapons[1] = {baseDmg = 5, idealDist = 48, rangePenalty = -.5, cost = 1}
end

function hitscan(a, b) -- a is shooter, b is target, dmg is damage to deal
  local dmg = getDamage(a, b)
  b.health = b.health - dmg
end

function getDamage(a, b) -- entity a is attacking entity b
  local dmg = weapons[a.weapon].baseDmg
  dmg = dmg + math.abs(weapons[a.weapon].idealDist - getDistance(a, b))/tileSize * weapons[a.weapon].rangePenalty
  if isUnderCover(b, a, rooms[a.room]) == true then
    dmg = dmg / 2
  end
  return dmg
end

function combat_update()
  for i, v in ipairs(currentLevel.actors) do
    if v.health <= 0 then
      currentLevel.actors[i] = nil
    end
  end
  currentLevel.actors = removeNil(currentLevel.actors)
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.health <= 0 then
      currentLevel.enemyActors[i] = nil
    end
  end
  currentLevel.enemyActors = removeNil(currentLevel.enemyActors)
end
