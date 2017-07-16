function actor_load()
    currentActorNum = 1
    currentActor = levels[currentLevel].actors[currentActorNum]
end


function newCurrentActor(newActorNum)
  currentActorNum = newActorNum
  currentActor = levels[currentLevel].actors[newActorNum]
  if currentRoom ~= levels[currentLevel].rooms[currentActor.room] then
    currentRoom = levels[currentLevel].rooms[currentActor.room]
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

function actor_keypressed(key)
  if key == "tab" then
    if currentActorNum < #levels[currentLevel].actors then
      newCurrentActor(currentActorNum + 1)
    else
      newCurrentActor(1)
    end
  elseif key == "space" then
    currentActor.turnPts = 0
  end
end

function actor_update(dt)
  if currentActor.move == false then
    currentActor.path = newPath({x = math.floor(currentActor.x/tileSize)+1, y = math.floor(currentActor.y/tileSize)+1}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
  end
  local nextTurn = true
  for i, v in ipairs(levels[currentLevel].actors) do
    if v.move == true then
      nextTurn = false -- don't end players turn if actors are still moving
      followPath(v, dt)
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

function followPath(v, dt)
  local path = {x = (v.path[1].x-1) * tileSize, y = (v.path[1].y-1) * tileSize}
  if v.x == path.x and v.y == path.y then
    table.remove(v.path, 1)
    if #v.path < 1 then -- stop moving the actor
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
  if button == 1 and currentActor.path ~= nil and currentActor.move == false and #currentActor.path > 1 and pathIsValid(currentActor) then
    currentActor.turnPts = currentActor.turnPts - (#currentActor.path-1) -- reduce turnPts based on how far the actor is moving
    currentActor.move = true
    currentActor.path = simplifyPath(currentActor.path)
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
    for i, v in ipairs(actor.path) do
      if i > 1 and i < #actor.path then
        local oldTile = {x = actor.path[i-1].x - v.x, y = actor.path[i-1].y - v.y}
        local newTile = {x = actor.path[i+1].x - v.x, y = actor.path[i+1].y - v.y}

        if math.abs(oldTile.x) == 1 and math.abs(newTile.x) == 1 then
          love.graphics.draw(pathImg, pathQuad[2], tileToIso(v.x-1, v.y-1))
        elseif math.abs(oldTile.y) == 1 and math.abs(newTile.y) == 1 then
          love.graphics.draw(pathImg, pathQuad[5], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == -1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[4], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == 1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[1], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == -1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[6], tileToIso(v.x-1, v.y-1))
        elseif (oldTile.x == 1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[3], tileToIso(v.x-1, v.y-1))
        end
      else
        love.graphics.draw(cursor, tileToIso(v.x-1, v.y-1))
      end
    end
  end
end

function giveActorsTurnPts()
  for i, v in ipairs(levels[currentLevel].actors) do
    v.turnPts = chars[v.actor].turnPts -- will need to be changed when level mode 2 is added
  end
end

function pathIsValid(actor)
  if #actor.path-1 > actor.turnPts then -- get rid of path if destination is too far away
    return false
  end
  for i, v in ipairs(levels[currentLevel].actors) do
    if v.move == true then
      if actor.path[#actor.path].x == v.path[#v.path].x and actor.path[#actor.path].y == v.path[#v.path].y then
        return false
      end
    elseif  #actor.path > 0 then
      if (actor.path[#actor.path].x-1)*tileSize == v.x and (actor.path[#actor.path].y-1)*tileSize == v.y then
        return false
      end
    end
  end
  return true
end
