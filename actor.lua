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
    cameraPos.x = w / 2 - x - tileSize*2
    cameraPos.y = h / 2 - y - tileSize
    startRoom(currentRoom)
  end
end

function coordToIso(x, y)
  x = x /(tileSize*2)
  y = y /(tileSize*2)
  return (x-y+#rooms[currentRoom]-1)*tileSize*2, (y+x)*tileSize
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
  currentActor.path = newPath({x = math.floor(currentActor.x/tileSize/2)+1, y = math.floor(currentActor.y/tileSize/2)+1}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
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
    end
  end
end

function actor_mousepressed(x, y, button)

end
