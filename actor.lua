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
  end
end

function actor_update(dt)
  if currentActor.move == false then
    currentActor.path = newPath({x = math.floor(currentActor.x/tileSize)+1, y = math.floor(currentActor.y/tileSize)+1}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
  else
    if currentActor.x - currentActor.path[1].x * tileSize > 0 then

    elseif currentActor.x - currentActor.path[1].x * tileSize < 0 then
    elseif currentActor.y - currentActor.path[1].y * tileSize > 0 then
    elseif currentActor.y - currentActor.path[1].y * tileSize < 0 then
    else
    end
  end
end

function actor_mousepressed(x, y, button)
  if button == 1 and currentActor.move == false then
    currentActor.move = true
    table.remove(currentActor.path, 1)
  end
end

function drawPath(actor)
  love.graphics.setColor(255, 0, 0)
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
