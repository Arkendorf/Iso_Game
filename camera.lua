function camera_load()
  cameraPos = {x = 0, y = 0, rawX = 0, rawY = 0}
  cameraSpeed = 60
end

function camera_update(dt)
  -- if love.keyboard.isDown(controls.panCamera.up) then
  --   cameraPos.rawY = cameraPos.rawY + dt * cameraSpeed
  -- end
  -- if love.keyboard.isDown(controls.panCamera.down) then
  --   cameraPos.rawY = cameraPos.rawY - dt * cameraSpeed
  -- end
  -- if love.keyboard.isDown(controls.panCamera.left) then
  --   cameraPos.rawX = cameraPos.rawX + dt * cameraSpeed
  -- end
  -- if love.keyboard.isDown(controls.panCamera.right) then
  --   cameraPos.rawX = cameraPos.rawX - dt * cameraSpeed
  -- end
  cameraPos.x = math.floor(cameraPos.rawX)
  cameraPos.y = math.floor(cameraPos.rawY)
end

function centerCamOnCoords(x, y)
  local x, y = coordToIso(x, y)
  cameraPos.rawX = screen.w / 2 - x - tileSize
  cameraPos.rawY = screen.h / 2 - y - tileSize/2
end
