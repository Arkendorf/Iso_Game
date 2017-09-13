function ai_load()
  local coverPoints = .5
  local effectiveCoverPoints = 2
  local singlePlayerPoints =4
  local extraPlayerPoints = -1
  local killPoints = 5
  local hazardPoints = -4

  enemyMoveAIs = {}

  enemyMoveAIs[1] = function (enemyNum, enemy, across, down) -- basic AI 1: goes behind cover, wants only one player in LoS, and wants a certain distance between players and enemy
    local x, y = tileToCoord(across, down)
    local map = rooms[enemy.room]
    local score = 0

    local playersInSight = 0
    local distanceToPlayers = {}
    for i, v in ipairs(currentLevel.actors) do
      if v.room == enemy.room and v.dead == false and enemy.seen[i] == true then
        if LoS({x = x, y = y}, {x = v.x, y = v.y}, map) == true then
          playersInSight = playersInSight + 1
          distanceToPlayers[#distanceToPlayers + 1] = getDistance({x = x, y = y}, {x = v.x, y = v.y}) -- gets distance from tile to player
          if isUnderCover({x = x, y = y}, {x = v.x, y = v.y}, map) == true then -- add points if enemy is under cover from player
            score = score + effectiveCoverPoints
          end
        end
      end
    end

    local averageDist = 0
    for i, v in ipairs(distanceToPlayers) do
      averageDist = averageDist + v/#distanceToPlayers
    end
    averageDist = averageDist
    local distDiffPoints = weapons[enemy.actor.item.weapon].rangePenalty
    local idealDist = weapons[enemy.actor.item.weapon].idealDist
    score = score - math.abs(idealDist - averageDist) * distDiffPoints-- subtrace points based on how close it is to desired distance

    if playersInSight > 0 then -- add points based on how exposed enemy is
      score = score + singlePlayerPoints + (playersInSight-1)*extraPlayerPoints
    end

    for i, v in ipairs(currentLevel.hazards) do
      if v.tX == across and v.tY == down then
        score = score + hazardPoints
      end
    end

    -- add points based on how much cover and walls are nearby
    if across < #map[1] and (tileType[map[down][across+1]] == 3 or tileType[map[down][across+1]] == 2) then
      score = score +  coverPoints
    end
    if across > 1 and (tileType[map[down][across-1]] == 3 or tileType[map[down][across-1]] == 2) then
      score = score + coverPoints
    end
    if down < #map and (tileType[map[down+1][across]] == 3 or tileType[map[down+1][across]] == 2) then
      score = score + coverPoints
    end
    if down > 1 and (tileType[map[down-1][across]] == 3 or tileType[map[down-1][across]] == 2) then
      score = score +  coverPoints
    end
    return score
  end

  enemyCombatAIs = {}

  enemyCombatAIs[1] = function (enemyNum, enemy, target) -- for normal weapons
    local score = 0
    if weapons[enemy.actor.item.weapon].AOE ~= nil then
      for i, v in ipairs(currentLevel.actors) do
        if v.dead == false and enemy.seen[i] == true then
          local dmg = getDamage(enemy, v, target)
          score = score + dmg
          if v.health - dmg <= 0 then -- if enemy kills target, add a bonus
            score = score + killPoints
          end
        end
      end
    else
      local dmg = getDamage(enemy, target, target)
      score = score + dmg
      if target.health - dmg <= 0 then -- if enemy kills target, add a bonus
        score = score + killPoints
      end
    end
    return score
  end

end

function rankPathToTile(enemyNum, enemy, list, x, y)
  local map = rooms[enemy.room]
  local tX, tY = coordToTile(enemy.x, enemy.y)
  local path = newPath({x = tX, y = tY}, {x = x, y = y}, map)
  for i, v in ipairs(path) do
    list[#list + 1] = {tX = v.x, tY = v.y, score = #map[1]*#map-#path+i}
  end
  return list
end

function patrol(enemyNum, enemy)
  local potentialTiles = {}
  local tX, tY = coordToTile(enemy.x, enemy.y)
  for i, v in ipairs(enemy.patrol.tiles) do
    if v.x == tX and v.y == tY then
      if i + 1 > #enemy.patrol.tiles then
        potentialTiles = rankPathToTile(enemyNum, enemy, {}, enemy.patrol.tiles[1].x, enemy.patrol.tiles[1].y)
      else
        potentialTiles = rankPathToTile(enemyNum, enemy, {}, enemy.patrol.tiles[i+1].x, enemy.patrol.tiles[i+1].y)
      end
      break
    else
      potentialTiles = rankPathToTile(enemyNum, enemy, potentialTiles, v.x, v.y)
    end
  end
  return potentialTiles
end

function goToDoor(enemyNum, enemy)
  local potentialTiles = {}
  for i, v in ipairs(currentLevel.doors) do
    if enemy.room == v.room1 then
      for j, k in ipairs(currentLevel.actors) do
        if k.room == v.room2 and enemy.seen[j] == true then
          potentialTiles = rankPathToTile(enemyNum, enemy, potentialTiles, v.tX1, v.tX2)
          break
        end
      end
    elseif enemy.room == v.room2 then
      for j, k in ipairs(currentLevel.actors) do
        if k.room == v.room1 and enemy.seen[j] == true then
          potentialTiles = rankPathToTile(enemyNum, enemy, potentialTiles, v.tX1, v.tX2)
          break
        end
      end
    end
  end
  return potentialTiles
end

function rankTargets(enemyNum, enemy)
  local potentialTargets = {}
  for i, v in ipairs(rooms[enemy.room]) do -- go through every tile and see if it is a valid target
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        local target = findTargetFuncs[enemy.targetMode](enemy, {tX = j, tY = i}, currentLevel.actors) -- find target based on weapon targetMode
        if target ~= nil then
          potentialTargets[#potentialTargets+1] = {item = target, score = enemyCombatAIs[enemy.actor.item.combatAI](enemyNum, enemy, target)} -- score target based on weapon targetMode
        end
      end
    end
  end
  return potentialTargets
end

function rankTiles(enemyNum, enemy)
  local tX, tY = coordToTile(enemy.x, enemy.y)
  local room = rooms[enemy.room]

  local xMin = tX - enemy.turnPts
  if xMin < 1 then xMin = 1 end
  local xMax = tX + enemy.turnPts
  if xMax > #room[1] then xMax = #room[1] end
  local yMin = tY - enemy.turnPts
  if yMin < 1 then yMin = 1 end
  local yMax = tY + enemy.turnPts
  if yMax > #room then yMax = #room end


  local potentialTiles = {}
  for down = yMin, yMax do -- search room within range for potential tiles
    for across = xMin, xMax do
      if tileType[room[down][across]] == 1 then
        potentialTiles[#potentialTiles + 1] = {tX = across, tY = down, score = enemyMoveAIs[enemy.actor.item.moveAI](enemyNum, enemy, across, down)}
      end
    end
  end
  return potentialTiles
end

function chooseTarget(enemyNum, enemy, targets)
  local currentTarget = {item = nil, score = 0}
  for i, v in ipairs(targets) do
    if v.score > currentTarget.score and targetValidFuncs[enemy.targetMode](v.item, enemy, 0) == true then
      currentTarget = v
    end
  end
  return currentTarget.item
end

function chooseTile(enemyNum, enemy, tiles)
  local currentTile = {}
  for i, v in ipairs(tiles) do
    local tX, tY = coordToTile(enemy.x, enemy.y)
    v.path = newPath({x = tX, y = tY}, {x = v.tX, y = v.tY}, rooms[enemy.room])
    if #v.path == 1 or (#v.path > 0 and pathIsValid(v.path, enemy)) then
      local lengthPenalty = enemy.actor.item.turnPts / 2
      if currentTile.path == nil or v.score - #v.path/lengthPenalty > currentTile.score - #currentTile.path/lengthPenalty then
        currentTile = v
      end
    end
  end
  if currentTile.path == nil or #currentTile.path == 1 then
    return {}
  else
    return currentTile.path
  end
end
