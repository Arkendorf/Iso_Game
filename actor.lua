function actor_load()
    targetActor = 1
end


function newTargetActor(newActor)
  targetActor = newActor
  if currentRoom ~= levels[currentLevel].actors[newActor].room then
    currentRoom = levels[currentLevel].actors[newActor].room
    startRoom(currentRoom)
  end
end


function coordToIso(x, y)
  x = x /(tileSize*2)
  y = y /(tileSize*2)
  return (x-y+#rooms[currentRoom]-1)*tileSize*2+1, (y+x)*tileSize+1 -- 1 is added so players fit nicely with walls
end

function actor_keypressed(key)
  if key == "tab" then
    if targetActor < #levels[currentLevel].actors then
      newTargetActor(targetActor + 1)
    else
      newTargetActor(1)
    end
  end
end
