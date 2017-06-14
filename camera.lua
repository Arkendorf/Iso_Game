function camera_load()
  cameraPos = {x = 0, y = 0}
end
function camera_update(dt)
  if love.keyboard.isDown("w") then
    cameraPos.y = cameraPos.y + 1
  end
  if love.keyboard.isDown("s") then
    cameraPos.y = cameraPos.y - 1
  end
  if love.keyboard.isDown("a") then
    cameraPos.x = cameraPos.x + 1
  end
  if love.keyboard.isDown("d") then
    cameraPos.x = cameraPos.x - 1
  end
end

function centerCamOnRoom()
  local x, y = coordToIso(#rooms[currentRoom][1] * 16, #rooms[currentRoom] * 16)
  cameraPos.x = w / 2 - x - tileSize*2
  cameraPos.y = h / 2 - y - tileSize
end
