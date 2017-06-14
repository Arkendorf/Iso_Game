function actor_load()
    currentActor = 1
end


function newCurrentActor(newActor)
  currentActor = newActor
  if currentRoom ~= levels[currentLevel].actors[newActor].room then
    currentRoom = levels[currentLevel].actors[newActor].room
    local x, y = coordToIso(levels[currentLevel].actors[newActor].x, levels[currentLevel].actors[newActor].y)
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
    if currentActor < #levels[currentLevel].actors then
      newCurrentActor(currentActor + 1)
    else
      newCurrentActor(1)
    end
  end
end
