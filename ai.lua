function ai_load()
  local coverPoints = 1
  local effectiveCoverPoints = 1
  local singlePlayerPoints = 2
  local extraPlayerPoints = -1
  enemyMoveAIs = {}

  enemyMoveAIs[1] = function (enemyNum, enemy, across, down) -- basic AI 1: goes behind cover, wants only one player in LoS
    local x, y = tileToCoord(across, down)
    local map = rooms[enemy.room]
    local score = 0

    local playersInSight = 0
    for i, v in ipairs(levels[currentLevel].actors) do
      if v.room == enemy.room and visiblePlayers[enemy.room][i] == true then
        local tX, tY = coordToTile(v.x, v.y)
        if LoS({x = across, y = down}, {x = tX, y = tY}, map) == true then
          playersInSight = playersInSight + 1
          if isUnderCover({x = x, y = y}, {x = v.x, y = v.y}, map) == true then -- add a point if enemy is under cover from player
            score = score + effectiveCoverPoints
          end
        end
      end
    end

    if playersInSight == 1 then -- add points based on how exposed enemy is
      score = score + singlePlayerPoints
    elseif playersInSight > 1 then
      score = score + singlePlayerPoints + playersInSight*extraPlayerPoints
    end

    if across < #map[1] and tileType[map[down][across+1]] == 3 then
      score = score +  coverPoints
    end
    if across > 1 and tileType[map[down][across-1]] == 3 then
      score = score + coverPoints
    end
    if down < #map and tileType[map[down+1][across]] == 3 then
      score = score + coverPoints
    end
    if down > 1 and tileType[map[down-1][across]] == 3 then
      score = score +  coverPoints
    end
    return score
  end

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
  for down = yMin, yMax do -- search room within range for potential tile
    for across = xMin, xMax do
      if tileType[room[down][across]] == 1 then
        potentialTiles[#potentialTiles + 1] = {tX = across, tY = down, score = enemyMoveAIs[enemyActors[levels[currentLevel].type][enemy.actor].ai](enemyNum, enemy, across, down)}
      end
    end
  end
  return potentialTiles
end

function chooseTile(enemyNum, enemy, tiles)
  local currentTile = {}
  for i, v in ipairs(tiles) do
    local tX, tY = coordToTile(enemy.x, enemy.y)
    v.path = newPath({x = tX, y = tY}, {x = v.tX, y = v.tY}, rooms[enemy.room])
    if #v.path == 1 or (#v.path > 0 and pathIsValid(v.path, enemy.room, enemy.turnPts)) then
      if currentTile.path == nil or v.score - #v.path/6 > currentTile.score - #currentTile.path/4 then
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
