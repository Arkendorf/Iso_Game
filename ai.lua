function ai_load()
  local coverPoints = .5
  local effectiveCoverPoints = 2
  local singlePlayerPoints =4
  local extraPlayerPoints = -1

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
    local distDiffPoints = weapons[enemy.weapon].rangePenalty
    local idealDist = weapons[enemy.weapon].idealDist
    score = score + math.abs(idealDist - averageDist) * distDiffPoints-- subtrace points based on how close it is to desired distance

    if playersInSight > 0 then -- add points based on how exposed enemy is
      score = score + singlePlayerPoints + (playersInSight-1)*extraPlayerPoints
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

  enemyCombatAIs[1] = function (enemyNum, enemy, target)
    local score = 0
    local dmg = getDamage(enemy, target)
    score = score + dmg
    if target.health - dmg <= 0 then -- if enemy kills target, add damage target would have done to enemy to score
      score = score + getDamage(target, enemy)
    end
    return score
  end

end

function goToDoor(enemyNum, enemy)
  local potentialTiles = {}
  local tX, tY = coordToTile(enemy.x, enemy.y)
  for i, v in ipairs(currentLevel.doors) do
    if enemy.room == v.room1 then
      for j, k in ipairs(currentLevel.actors) do
        if k.room == v.room2 then
          local path = newPath({x = tX, y = tY}, {x = v.tX1, y = v.tY1}, rooms[enemy.room])
          for l, m in ipairs(path) do
            potentialTiles[#potentialTiles + 1] = {tX = m.x, tY = m.y, score = l}
          end
          break
        end
      end
    elseif enemy.room == v.room2 then
      for j, k in ipairs(currentLevel.actors) do
        if k.room == v.room1 then
          local path = newPath({x = tX, y = tY}, {x = v.tX2, y = v.tY2}, rooms[enemy.room])
          for l, m in ipairs(path) do
            potentialTiles[#potentialTiles + 1] = {tX = m.x, tY = m.y, score = l}
          end
          break
        end
      end
    end
  end
  return potentialTiles
end

function rankTargets(enemyNum, enemy)
  local potentialTargets = {}
  for i, v in ipairs(currentLevel.actors) do
    if v.room == enemy.room and enemy.seen[i] == true then
      potentialTargets[#potentialTargets+1] = {num = i, score = enemyCombatAIs[enemyActors[currentLevel.type][enemy.actor].combatAI](enemyNum, enemy, v)}
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
  if isRoomOccupied(enemy.room, enemy.seen) == true then -- if room has a player in it, perform normal AI behavior
    for down = yMin, yMax do -- search room within range for potential tiles
      for across = xMin, xMax do
        if tileType[room[down][across]] == 1 then
          potentialTiles[#potentialTiles + 1] = {tX = across, tY = down, score = enemyMoveAIs[enemyActors[currentLevel.type][enemy.actor].moveAI](enemyNum, enemy, across, down)}
        end
      end
    end
  else -- otherwise, find a door to a room with a player in it
    potentialTiles = goToDoor(enemyNum, enemy)
  end
  return potentialTiles
end

function chooseTarget(enemyNum, enemy, targets)
  local currentTarget = {num = 0, score = 0}
  for i, v in ipairs(targets) do
    if v.score > currentTarget.score and enemyTargetIsValid(v.num, enemy) then
      currentTarget = v
    end
  end
  return currentTarget.num
end

function chooseTile(enemyNum, enemy, tiles)
  local currentTile = {}
  for i, v in ipairs(tiles) do
    local tX, tY = coordToTile(enemy.x, enemy.y)
    v.path = newPath({x = tX, y = tY}, {x = v.tX, y = v.tY}, rooms[enemy.room])
    if #v.path == 1 or (#v.path > 0 and pathIsValid(v.path, enemy.room, enemy.turnPts)) then
      local lengthPenalty = enemyActors[currentLevel.type][enemy.actor].turnPts / 2
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
