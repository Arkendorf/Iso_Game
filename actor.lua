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
  end
  for i, v in ipairs(levels[currentLevel].actors) do
    if v.move == true then
      local path = {x = (v.path[1].x-1) * tileSize, y = (v.path[1].y-1) * tileSize}
      if v.x == path.x and v.y == path.y then
        table.remove(v.path, 1)
        if #v.path < 1 then -- stop moving the actor
          v.move = false
        end
      else

          local speed = chars[v.actor].speed -- will need to be changed when level mode 2 is added

        if v.x > path.x then -- move left
          if v.x - dt * speed < path.x then
            v.x = path.x
          else
            v.x = v.x - dt * speed
          end
        elseif v.x < path.x then -- move right
          if v.x + dt * speed > path.x then
            v.x = path.x
          else
            v.x = v.x + dt * speed
          end
        elseif v.y > path.y then -- move up
          if v.y - dt * speed < path.y then
            v.y = path.y
          else
            v.y = v.y - dt * speed
          end
        elseif v.y < path.y then -- move down
          if v.y + dt * speed > path.y then
            v.y = path.y
          else
            v.y = v.y + dt * speed
          end
        end
      end
    end
  end
end

function actor_mousepressed(x, y, button)
  if button == 1 and currentActor.path ~= nil and currentActor.move == false then
    currentActor.move = true
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
