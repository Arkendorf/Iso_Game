function actor_load()
    currentActorNum = 1
    currentActor = levels[currentLevel].actors[currentActorNum]
end


function newCurrentActor(newActorNum)
  currentActorNum = newActorNum
  currentActor = levels[currentLevel].actors[newActorNum]
  if currentRoom ~= currentActor.room then
    currentRoom = currentActor.room
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
      if math.abs(v.x - actor.path[i-1].x) == 1 and math.abs(v.x - actor.path[i+1].x) == 1 then
        love.graphics.draw(pathImg, pathQuad[2], tileToIso(v.x-1, v.y-1))
      elseif math.abs(v.y - actor.path[i-1].y) == 1 and math.abs(v.y - actor.path[i+1].y) == 1 then
        love.graphics.draw(pathImg, pathQuad[5], tileToIso(v.x-1, v.y-1))
      elseif (v.x - actor.path[i-1].x == 1 and v.y - actor.path[i+1].y == -1) or (v.y - actor.path[i-1].y == -1 and v.x - actor.path[i+1].x == 1) then
        love.graphics.draw(pathImg, pathQuad[4], tileToIso(v.x-1, v.y-1))
      elseif (v.x - actor.path[i-1].x == 1 and v.y - actor.path[i+1].y == 1) or (v.y - actor.path[i-1].y == 1 and v.x - actor.path[i+1].x == 1) then
        love.graphics.draw(pathImg, pathQuad[6], tileToIso(v.x-1, v.y-1))
      elseif (v.x - actor.path[i-1].x == -1 and v.y - actor.path[i+1].y == -1) or (v.y - actor.path[i-1].y == 1 and v.x - actor.path[i+1].x == 1) then
        love.graphics.draw(pathImg, pathQuad[1], tileToIso(v.x-1, v.y-1))
      else
        love.graphics.draw(pathImg, pathQuad[3], tileToIso(v.x-1, v.y-1))
      end
    end
  end
end

function actor_mousepressed(x, y, button)

end
