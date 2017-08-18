function actor_load()
  currentActorNum = 1
  currentActor = currentLevel.actors[currentActorNum]
  playerTurn = true
end


function newCurrentActor(newActorNum)
  currentActorNum = newActorNum
  currentActor = currentLevel.actors[newActorNum]
  syncRooms()
end

function syncRooms()
  if currentRoom ~= currentActor.room then
    currentRoom = currentActor.room
    local x, y = coordToIso(currentActor.x, currentActor.y)
    cameraPos.rawX = screen.w / 2 - x - tileSize
    cameraPos.rawY = screen.h / 2 - y - tileSize/2
    startRoom(currentRoom)
  end
end

function actor_keypressed(key)
  if key == controls.switchActor then
    if currentActorNum < #currentLevel.actors then
      newCurrentActor(currentActorNum + 1)
    else
      newCurrentActor(1)
    end
  elseif key == controls.endTurn then
    currentActor.turnPts = 0
  elseif key == controls.use and currentActor.move == false and currentActor.turnPts > 0 then
    newPos = useDoor(tileDoorInfo(currentActor.room, coordToTile(currentActor.x, currentActor.y)))
    if newPos ~= nil then
      currentActor.room, currentActor.x, currentActor.y = newPos.room, newPos.x, newPos.y
      syncRooms()
      currentActor.turnPts = currentActor.turnPts - 1
    end
  elseif key == controls.mode1 then
    if currentActor.mode == 1 then
      currentActor.mode = 0
    else
      currentActor.mode = 1
    end
  end
end

function findTarget(tX1, tY1, room, table)
  for i, v in ipairs(table) do
    tX2, tY2 = coordToTile(v.x, v.y)
    if v.room == room and tX1 == tX2 and tY1 == tY2 then
      return i
    end
  end
  return 0
end

function targetIsValid(target, actor)
  if target > 0 and actor.turnPts >= weapons[actor.weapon].cost then
    local enemy = currentLevel.enemyActors[target]
    if enemy.room == actor.room and LoS({x = actor.x, y = actor.y}, {x = enemy.x, y = enemy.y}, rooms[actor.room]) == true then
      return true
    else
      return false
    end
  else
    return false
  end
end

function actor_update(dt)
  if currentActor.move == false then
    if currentActor.mode == 0 then
      local tX, tY = coordToTile(currentActor.x, currentActor.y)
      currentActor.path.tiles = newPath({x = tX, y = tY}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
      currentActor.path.valid = pathIsValid(currentActor.path.tiles, currentActor.room, currentActor.turnPts)
    elseif currentActor.mode == 1 then
      currentActor.target.num = findTarget(cursorPos.tX, cursorPos.tY, currentActor.room, currentLevel.enemyActors)
      currentActor.target.valid = targetIsValid(currentActor.target.num, currentActor)
    end
  end
  local nextTurn = true
  for i, v in ipairs(currentLevel.actors) do
    if v.move == true then
      nextTurn = false -- don't end players turn if actors are still moving
      followPath(i, v, dt)
    elseif v.turnPts > 0 then
      nextTurn = false -- dont end players turn if orders need to be given
    end
  end

  if nextTurn == true and playerTurn == true then
    startEnemyTurn()
  end
end

function startPlayerTurn()
  playerTurn = true
  giveActorsTurnPts()
end

function actor_mousepressed(x, y, button)
  if button == 1 and currentActor.mode == 0 and currentActor.move == false and #currentActor.path.tiles > 1 and currentActor.path.valid then
    currentActor.turnPts = currentActor.turnPts - (#currentActor.path.tiles-1) -- reduce turnPts based on how far the actor is moving
    currentActor.move = true
    currentActor.path.tiles = simplifyPath(currentActor.path.tiles)
    currentActor.path.valid = false
  elseif button == 1 and currentActor.mode == 1 and currentActor.target.valid == true then
    hitscan(currentActor, currentLevel.enemyActors[currentActor.target.num])
    currentActor.turnPts = currentActor.turnPts - weapons[currentActor.weapon].cost
  end
end

function followPath(i, v, dt)
  local path = {x = (v.path.tiles[1].x-1) * tileSize, y = (v.path.tiles[1].y-1) * tileSize}
  if v.x == path.x and v.y == path.y then
    table.remove(v.path.tiles, 1)
    if #v.path.tiles < 1 then -- stop moving the actor
      v.move = false
    end
  else
    local dir = pathDirection({x = v.x, y = v.y}, path)
    local speed = playerActors[currentLevel.type][v.actor].speed
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

function drawPath(actor)
  if actor.move == false then -- only draw the path if the actor isn't moving along it
    for i, v in ipairs(actor.path.tiles) do
      if i > 1 and i < #actor.path.tiles then
        local oldTile = {x = actor.path.tiles[i-1].x - v.x, y = actor.path.tiles[i-1].y - v.y}
        local newTile = {x = actor.path.tiles[i+1].x - v.x, y = actor.path.tiles[i+1].y - v.y}

        if math.abs(oldTile.x) == 1 and math.abs(newTile.x) == 1 then
          love.graphics.draw(pathImg, pathQuad[3], tileToIso(v.x, v.y))
        elseif math.abs(oldTile.y) == 1 and math.abs(newTile.y) == 1 then
          love.graphics.draw(pathImg, pathQuad[4], tileToIso(v.x, v.y))
        elseif (oldTile.x == -1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[2], tileToIso(v.x, v.y))
        elseif (oldTile.x == 1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[1], tileToIso(v.x, v.y))
        elseif (oldTile.x == -1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[6], tileToIso(v.x, v.y))
        elseif (oldTile.x == 1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[5], tileToIso(v.x, v.y))
        end
      else
        love.graphics.draw(cursorImg, tileToIso(v.x, v.y))
      end
    end
  end
end

function giveActorsTurnPts()
  for i, v in ipairs(currentLevel.actors) do
    v.turnPts = playerActors[currentLevel.type][v.actor].turnPts
  end
end
