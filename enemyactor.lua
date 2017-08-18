function enemyactor_load()
end

function enemyactor_update(dt)
  local nextTurn = true
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.move == true then
      nextTurn = false -- don't end enemies turn if actors are still moving
      enemyFollowPath(i, v, dt)
    elseif v.turnPts > 0 then
      if isRoomOccupied(v) == false then -- use a door if on one and the current room is unoccupied
        newPos = useDoor(tileDoorInfo(v.room, coordToTile(v.x, v.y)))
        if newPos ~= nil then
          v.room, v.x, v.y = newPos.room, newPos.x, newPos.y
          v.turnPts = v.turnPts - 1
          moveEnemy(i, v) -- check if enemy should move once in new room
        end
      end
      v.turnPts = 0 -- TEMPORARY UNTIL COMBAT IS ADDED
      nextTurn = false -- dont end enemies turn if orders need to be given
    end
  end

  if nextTurn == true and playerTurn == false then
    startPlayerTurn()
  end
end

function isRoomOccupied(enemy)
  for i, v in ipairs(currentLevel.actors) do -- sees if any players are in the room
    if v.room == enemy.room and enemy.seen[i] == true then
      return true
    end
  end
  return false
end

function arePlayersSeen(enemy)
  for i = 1, #currentLevel.actors do
    if enemy.seen[i] == true then
      return true
    end
  end
  return false
end

function revealPlayers()
  local occupiedRooms = {}
  for i, v in ipairs(currentLevel.enemyActors) do
    local tX1, tY1 = coordToTile(v.x, v.y)
    for j, k in ipairs(currentLevel.actors) do
      local tX2, tY2 = coordToTile(k.x, k.y)
      if v.room == k.room and getDistance({x = v.x, y = v.y}, {x = k.x, y = k.y}) <= enemyActors[currentLevel.type][v.actor].eyesight and LoS({x = tX1, y = tY1}, {x = tX2, y = tY2}, rooms[v.room]) == true then
        v.seen[j] = true
      end
    end
    sharePlayerLocation(v)
  end
end

function sharePlayerLocation(enemy) -- share seen players with rest of room
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.room == enemy.room then
      for j = 1, #currentLevel.actors do
        if enemy.seen[j] == true then
          v.seen[j] = true
        end
      end
    end
  end
end

function isPlayerVisible(player, num)
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.room == player.room and v.seen[num] == true then
      return true
    end
  end
  return false
end

function giveEnemyActorsTurnPts()
  for i, v in ipairs(currentLevel.enemyActors) do
    v.turnPts = enemyActors[currentLevel.type][v.actor].turnPts
  end
end

function moveEnemy(enemyNum, enemy)
  enemy.path.tiles = findEnemyPath(enemyNum, enemy)
  if #enemy.path.tiles > 0 then -- if the best course of action is to move
    enemy.turnPts = enemy.turnPts - (#enemy.path.tiles-1)
    enemy.path.tiles = simplifyPath(enemy.path.tiles)
    enemy.move = true
  end
end

function startEnemyTurn()
  playerTurn = false
  giveEnemyActorsTurnPts()
  revealPlayers()
  for i, v in ipairs(currentLevel.enemyActors) do
    if arePlayersSeen(v) == true then
      moveEnemy(i, v)
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
    local speed = enemyActors[currentLevel.type][v.actor].speed
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
