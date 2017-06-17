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
    love.graphics.draw(tile, tileToIso(v.x-1, v.y-1))
  end
end

function actor_mousepressed(x, y, button)

end
