function enemyactor_load()
  giveEnemyActorsTurnPts()
end

function enemyactor_update(dt)
  -- if currentActor.move == false then
  --   currentActor.path.tiles = newPath({x = math.floor(currentActor.x/tileSize)+1, y = math.floor(currentActor.y/tileSize)+1}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
  --   currentActor.path.valid = pathIsValid(currentActor)
  -- end
  local nextTurn = true
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    if v.move == true then
      nextTurn = false -- don't end players turn if actors are still moving
      enemyFollowPath(i, v, dt)
    elseif v.turnPts > 0 then
      nextTurn = false -- dont end players turn if orders need to be given
    end
  end

  if nextTurn == true then
    startPlayerTurn()
  end
end

function giveEnemyActorsTurnPts()
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    v.turnPts = enemyChars[v.actor].turnPts -- will need to be changed when level mode 2 is added
  end
end

function startEnemyTurn()
  playerTurn = false
  giveEnemyActorsTurnPts()
  for i, v in ipairs(levels[currentLevel].enemyActors) do
    v.path.tiles = findEnemyPath(i, v)
    v.turnPts = v.turnPts - (#v.path.tiles-1)
    v.path.tiles = simplifyPath(v.path.tiles)
    v.move = true
  end
end

function findEnemyPath(i, v)
  return newPath({x = 6, y = 6}, {x = 4, y = 4}, rooms[v.room])
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
    local speed = enemyChars[v.actor].speed -- will need to be changed when level mode 2 is added
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
