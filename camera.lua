function camera_load()
  cameraPos = {x = 0, y = 0}
end
function camera_update(dt)
  if love.keyboard.isDown(controls.panCamera.up) then
    cameraPos.y = cameraPos.y + 1
  end
  if love.keyboard.isDown(controls.panCamera.down) then
    cameraPos.y = cameraPos.y - 1
  end
  if love.keyboard.isDown(controls.panCamera.left) then
    cameraPos.x = cameraPos.x + 1
  end
  if love.keyboard.isDown(controls.panCamera.right) then
    cameraPos.x = cameraPos.x - 1
  end
end

function centerCamOnRoom()
  local x, y = coordToIso(#rooms[currentRoom][1] * 16, #rooms[currentRoom] * 16)
  cameraPos.x = w / 2 - x - tileSize
  cameraPos.y = h / 2 - y - tileSize/2
end
