function actor_load()
    currentActorNum = 1
    currentActor = levels[currentLevel].actors[currentActorNum]
end


function newCurrentActor(newActorNum)
  currentActorNum = newActorNum
  currentActor = levels[currentLevel].actors[newActorNum]
  syncRooms()
end

function syncRooms()
  if currentRoom ~= currentActor.room then
    currentRoom = currentActor.room
    local x, y = coordToIso(currentActor.x, currentActor.y)
    cameraPos.x = w / 2 - x - tileSize
    cameraPos.y = h / 2 - y - tileSize/2
    startRoom(currentRoom)
  end
end

function coordToIso(x, y)
  x = x /tileSize
  y = y /tileSize
  return (x-y+#rooms[currentRoom]-1)*tileSize, (y+x)*tileSize/2
end

function tileToCoord(x, y)
  return (x-1)*tileSize, (y-1)*tileSize
end

function coordToTile(x, y)
  return math.floor(x/tileSize)+1, math.floor(y/tileSize)+1
end

function actor_keypressed(key)
  if key == "tab" then
    if currentActorNum < #levels[currentLevel].actors then
      newCurrentActor(currentActorNum + 1)
    else
      newCurrentActor(1)
    end
  elseif key == "space" then
    currentActor.turnPts = 0
  elseif key == "e" and currentActor.move == false and currentActor.turnPts > 0 then
    newPos = useDoor(tileDoorInfo(currentActor.room, coordToTile(currentActor.x, currentActor.y)))
    if newPos ~= nil then currentActor.room, currentActor.x, currentActor.y = newPos.room, newPos.x, newPos.y end
    syncRooms()
    currentActor.turnPts = currentActor.turnPts - 1
  end
end

function actor_update(dt)
  if currentActor.move == false then
    currentActor.path.tiles = newPath({x = math.floor(currentActor.x/tileSize)+1, y = math.floor(currentActor.y/tileSize)+1}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
    currentActor.path.valid = pathIsValid(currentActor)
  end
  local nextTurn = true
  for i, v in ipairs(levels[currentLevel].actors) do
    if v.move == true then
      nextTurn = false -- don't end players turn if actors are still moving
      followPath(i, v, dt)
    end
    if v.turnPts > 0 then
      nextTurn = false -- dont end players turn if orders need to be given
    end
  end

  if nextTurn == true then
    -- do stuff if players turn is over
    giveActorsTurnPts()
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
    local speed = chars[v.actor].speed -- will need to be changed when level mode 2 is added
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

function actor_mousepressed(x, y, button)
  if button == 1 and currentActor.move == false and #currentActor.path.tiles > 1 and currentActor.path.valid then
    currentActor.turnPts = currentActor.turnPts - (#currentActor.path.tiles-1) -- reduce turnPts based on how far the actor is moving
    currentActor.move = true
    currentActor.path.tiles = simplifyPath(currentActor.path.tiles)
  end
end

function simplifyPath(path)
  local simplePath = {path[1]}
  local oldDir = pathDirection(path[1], path[2])
  for i = 2, #path-1 do
    newDir = pathDirection(path[i], path[i+1]) -- find new direction
    if newDir.x ~= oldDir.x or newDir.y ~= oldDir.y then -- check if path is going in same direction
      simplePath[#simplePath + 1] = path[i]
      oldDir = newDir
    end
  end
  simplePath[#simplePath + 1] = path[#path]
  return simplePath
end

function pathDirection(a, b)
  if a.x > b.x then
    return {x = -1, y = 0}
  elseif a.x < b.x then
    return {x = 1, y = 0}
  elseif a.y > b.y then
    return {x = 0, y = -1}
  else
    return {x = 0, y = 1}
  end
end

function drawPath(actor)
  if actor.move == false then -- only draw the path if the actor isn't moving along it
    for i, v in ipairs(actor.path.tiles) do
      if i > 1 and i < #actor.path.tiles then
        local oldTile = {x = actor.path.tiles[i-1].x - v.x, y = actor.path.tiles[i-1].y - v.y}
        local newTile = {x = actor.path.tiles[i+1].x - v.x, y = actor.path.tiles[i+1].y - v.y}

        if math.abs(oldTile.x) == 1 and math.abs(newTile.x) == 1 then
          love.graphics.draw(pathImg, pathQuad[3], tileToIso(v.x-1, v.y-1))
        elseif math.abs(oldTile.y) == 1 and math.abs(newTile.y) == 1 then
          love.graphics.draw(pathImg, pathQuad[4], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == -1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[2], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == 1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[1], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == -1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[6], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == 1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[5], tileToIso(v.x-1, v.y-1))
        end
      else
        love.graphics.draw(cursor, tileToIso(v.x-1, v.y-1))
      end
    end
  end
end

function setPathColor()
  if currentActor.path.valid then
    if scanFlicker[6] == 0 then
      love.graphics.setColor(palette.green)
    else
      love.graphics.setColor(palette.green[1]/2, palette.green[2]/2, palette.green[3]/2)
    end
  else
    if scanFlicker[5] == 0 then
      love.graphics.setColor(palette.red)
    else
      love.graphics.setColor(palette.red[1]/2, palette.red[2]/2, palette.red[3]/2)
    end
  end
end

function giveActorsTurnPts()
  for i, v in ipairs(levels[currentLevel].actors) do
    v.turnPts = chars[v.actor].turnPts -- will need to be changed when level mode 2 is added
  end
end

function pathIsValid(actor)
  if #actor.path.tiles-1 > actor.turnPts then -- get rid of path if destination is too far away
    return false
  else
    for i, v in ipairs(levels[currentLevel].actors) do
      if actor.room == v.room then
        if v.move == true then
          if actor.path.tiles[#actor.path.tiles].x == v.path.tiles[#v.path.tiles].x and actor.path.tiles[#actor.path.tiles].y == v.path.tiles[#v.path.tiles].y then
            return false
          end
        elseif  #actor.path.tiles > 0 then
          local x, y = tileToCoord(actor.path.tiles[#actor.path.tiles].x, actor.path.tiles[#actor.path.tiles].y)
          if x == v.x and y == v.y then
            return false
          end
        end
      end
    end
  end
  return true
end
