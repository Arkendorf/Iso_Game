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
