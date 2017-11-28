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

    if weapons[enemy.actor.item.weapon].dist then
      local averageDist = 0
      for i, v in ipairs(distanceToPlayers) do
        averageDist = averageDist + (v/tileSize)/#distanceToPlayers
      end
      local distDiffPoints = weapons[enemy.actor.item.weapon].dist.falloff
      local idealDist = weapons[enemy.actor.item.weapon].dist.range
      score = score - math.abs(idealDist - averageDist) * distDiffPoints-- subtrace points based on how close it is to desired distance
    end

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

  enemyCombatAIs[1] = function (enemyNum, enemy, target, info) -- for normal weapons
    local dmg, kills = getTotalDamage(enemy, target, currentLevel.actors, info)
    return dmg + kills*killPoints
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

function rankTargets(enemyNum, enemy, func, info)
  local xMin, xMax, yMin, yMax = nil
  local room = rooms[enemy.room]
  if info and info.dist then
    local tX, tY = coordToTile(enemy.x, enemy.y)
    local range = info.dist.range + info.baseDmg/info.dist.falloff

    xMin = tX - range
    if xMin < 1 then xMin = 1 end
    xMax = tX + range
    if xMax > #room[1] then xMax = #room[1] end
    yMin = tY - range
    if yMin < 1 then yMin = 1 end
    yMax = tY + range
    if yMax > #room then yMax = #room end
  else
    xMin = 1
    xMax = #room[1]
    yMin = 1
    yMax = #room
  end

  local potentialTargets = {}
  for down = yMin, yMax do -- search room within range for potential targets
    for across = xMin, xMax do
      if tileType[room[down][across]] == 1 then
        local target = findTargetFuncs[enemy.targetMode](enemy, {tX = across, tY = down}, currentLevel.actors) -- find target based on weapon targetMode
        if target then
          potentialTargets[#potentialTargets+1] = {item = target, score = func(enemyNum, enemy, target, info)} -- score target based on weapon targetMode
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

function chooseTarget(enemyNum, enemy, targets, cost, minScore)
  table.sort(targets, function (a, b) return a.score > b.score end)
  for i, v in ipairs(targets) do
    if (minScore and v.score < minScore) or v.score <= 0 then -- if score is less than minimum end search, or if less than or equal to 0
      return nil
    end
    if targetValidFuncs[enemy.targetMode](v.item, enemy, cost) == true then
      return v.item
    end
  end
  return nil
end

function chooseTile(enemyNum, enemy, tiles, minScore)
  table.sort(tiles, function (a, b) return a.score > b.score end)
  local tX, tY = coordToTile(enemy.x, enemy.y)
  if tX == tiles[1].tX and tY == tiles[1].tY then -- if current tile is top-scoring tile return no path
    return {}
  end
  for i, v in ipairs(tiles) do
    if minScore and v.score < minScore then -- if score is less than minimum end search
      return nil
    end
    local path = newPath({x = tX, y = tY}, {x = v.tX, y = v.tY}, rooms[enemy.room])
    if pathIsValid(path, enemy) then
      return path
    end
  end
  return {}
end
