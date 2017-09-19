function enemyactor_load()
  enemyTurnSpeed = 1
end

function enemyTargetIsValid(num, actor)
  if num > 0 and actor.turnPts >= weapons[actor.actor.item.weapon].cost then
    local player = currentLevel.actors[num]
    if player.room == actor.room and player.dead == false and player.futureHealth > 0 and LoS({x = actor.x, y = actor.y}, {x = player.x, y = player.y}, rooms[actor.room]) == true then
      return true
    else
      return false
    end
  else
    return false
  end
end

function enemyactor_update(dt)
  if playerTurn == false then
    local nextTurn = true
    for i, v in ipairs(currentLevel.enemyActors) do
      if v.dead == false then
        if v.wait == true then
          nextTurn = false
        elseif v.move == true then
          nextTurn = false -- don't end enemies turn if actors are still moving
          enemyFollowPath(i, v, dt)
        elseif v.turnPts > 0 then
          if isRoomOccupied(v.room, v.seen) == false and arePlayersSeen(v) then -- use a door if on one and the current room is unoccupied
            local newPos = useDoor(tileDoorInfo(v.room, coordToTile(v.x, v.y)))
            if newPos ~= nil then
              v.room, v.x, v.y = newPos.room, newPos.x, newPos.y
              v.turnPts = v.turnPts - 1
              moveEnemy(i, v, 0) -- check if enemy should move once in new room
            end
          end
          local result = enemyAttack(i, v)
          if result == false then
            v.turnPts = 0
          else
            nextTurn = false -- dont end enemies turn if orders need to be given
            v.wait = true
            newDelay(1/enemyTurnSpeed*.5, function (enemy) enemy.wait = false end, {v})
          end
        end
      end
    end

    if nextTurn == true and #projectileEntities == 0 then
      startPlayerTurn()
    end
  end
end

function isRoomOccupied(room, seen)
  for i, v in ipairs(currentLevel.actors) do -- sees if any players are in the room
    if v.room == room and seen[i] == true and v.dead == false then
      return true
    end
  end
  return false
end

function arePlayersSeen(enemy)
  for i, v in ipairs(currentLevel.actors) do
    if enemy.seen[i] == true and v.dead == false then
      return true
    end
  end
  return false
end

function revealPlayers()
  for i, v in ipairs(currentLevel.enemyActors) do
    for j, k in ipairs(currentLevel.actors) do
      if isPlayerInView(v, k) == true then
        v.seen[j] = true
      end
    end
    sharePlayerLocation(v)
  end
end

function isPlayerInView(enemy, player)
  if enemy.room == player.room and player.dead == false and enemy.dead == false and getDistance({x = enemy.x, y = enemy.y}, {x = player.x, y = player.y}) <= enemy.actor.item.eyesight and LoS({x = enemy.x, y = enemy.y}, {x = player.x, y = player.y}, rooms[enemy.room]) == true then
    return true
  else
    return false
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
    if v.seen[num] == true and player.dead == false then
      return true
    end
  end
  return false
end

function moveEnemy(enemyNum, enemy, delay)
  enemy.wait = false
  local move = false
  if arePlayersSeen(enemy) == true and isRoomOccupied(enemy.room, enemy.seen) == true then -- if known players are in the room, perform normal behavior
    enemy.path.tiles = chooseTile(enemyNum, enemy, rankTiles(enemyNum, enemy))
    enemy.wait = true
    newDelay(delay/enemyTurnSpeed*3, function (enemy) enemy.wait = false end, {enemy})
  elseif arePlayersSeen(enemy) == true and isRoomOccupied(enemy.room, enemy.seen) == false then -- if no known players are in the room, but are elsewhere, find a door to them
    enemy.path.tiles = chooseTile(enemyNum, enemy, goToDoor(enemyNum, enemy))
  elseif enemy.patrol ~= nil and enemy.room == enemy.patrol.room then -- if there are no known players, patrol if enemy has a patrol
    enemy.path.tiles = chooseTile(enemyNum, enemy, patrol(enemyNum, enemy))
  else
    enemy.path.tiles = {}
  end
  if #enemy.path.tiles > 0 then -- if the best course of action is to move
    enemy.turnPts = enemy.turnPts - (#enemy.path.tiles-1)
    enemy.path.tiles = simplifyPath(enemy.path.tiles)
    enemy.move = true
  end
end

function enemyAttack(enemyNum, enemy) -- damages player, returns true if it attacks, false if it doesn't
  local target = findEnemyTarget(enemyNum, enemy)
  if target ~= nil then
    attack(enemy, target, currentLevel.actors)
    enemy.turnPts = enemy.turnPts - weapons[enemy.actor.item.weapon].cost
    return true
  else
    return false
  end
end

function startEnemyTurn()
  playerTurn = false
  giveTurnPts(currentLevel.enemyActors)
  updateEffects(currentLevel.enemyActors)
  revealPlayers()
  local delay = 0
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.dead == false then
      moveEnemy(i, v, delay)
      delay = delay + 1
    end
  end
  startEnemyHud()
end

function findEnemyTarget(i, v)
  local potentialTargets = rankTargets(i, v)
  return chooseTarget(i, v, potentialTargets)
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
    local speed = v.actor.item.speed*enemyTurnSpeed
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
