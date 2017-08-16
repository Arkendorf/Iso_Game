function enemyactor_load()
  giveEnemyActorsTurnPts()
end

function enemyactor_update(dt)
  local nextTurn = true
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    if v.move == true then
      nextTurn = false -- don't end enemies turn if actors are still moving
      enemyFollowPath(i, v, dt)
    elseif v.turnPts > 0 then
      v.turnPts = 0 -- TEMPORARY UNTIL COMBAT IS ADDED
      nextTurn = false -- dont end enemies turn if orders need to be given
    end
  end

  if nextTurn == true and playerTurn == false then
    startPlayerTurn()
  end
end

function revealPlayers()
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    local tX1, tY1 = coordToTile(v.x, v.y)
    for j, k in ipairs(levels[currentLevel].actors) do
      local tX2, tY2 = coordToTile(k.x, k.y)
      if v.room == k.room and getDistance({x = v.x, y = v.y}, {x = k.x, y = k.y}) <= enemyActors[levels[currentLevel].type][v.actor].eyesight and LoS({x = tX1, y = tY1}, {x = tX2, y = tY2}, rooms[v.room]) == true then
        visiblePlayers[v.room][j] = true
      end
    end
  end
end

function giveEnemyActorsTurnPts()
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    v.turnPts = enemyActors[levels[currentLevel].type][v.actor].turnPts
  end
end

function startEnemyTurn()
  playerTurn = false
  giveEnemyActorsTurnPts()
  revealPlayers()
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    v.path.tiles = findEnemyPath(i, v)
    if #v.path.tiles > 0 then -- if the best course of action is to move
      v.turnPts = v.turnPts - (#v.path.tiles-1)
      v.path.tiles = simplifyPath(v.path.tiles)
      v.move = true
    end
  end
end

function findEnemyPath(i, v)
  local potentialTiles = rankTiles(i, v)
  return chooseTile(i, v, potentialTiles)
end

function enemyFollowPath(i, v, dt)
  local path = {x = (v.path.tiles[1].x-1) * tileSize, y = (v.path.tiles[1].y-1) * tileSize}
  if v.x == path.x and v.y == path.y then
    table.remove(v.path.tiles, 1)
    if #v.path.tiles < 1 then -- stop moving the actor
      v.move = false
    end
  else
    local dir = pathDirection({x = v.x, y = v.y}, path)
    local speed = enemyActors[levels[currentLevel].type][v.actor].speed
    v.x = v.x + dir.x * dt * speed
    v.y = v.y + dir.y * dt * speed
    if (dir.x > 0 and v.x > path.x) or (dir.x < 0 and v.x < path.x) then
      v.x = path.x
    end
    if (dir.y > 0 and v.y > path.y) or (dir.y < 0 and v.y < path.y) then
      v.y = path.y
    end
  end
end
