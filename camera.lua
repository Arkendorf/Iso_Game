function camera_load()
  cameraPos = {x = 0, y = 0, rawX = 0, rawY = 0, xOffset = 0, yOffset = 0}
  cameraSpeed = 60
end

function camera_update(dt)
  if love.keyboard.isDown(controls.panCamera.up) then
    cameraPos.rawY = cameraPos.rawY + dt * cameraSpeed
  end
  if love.keyboard.isDown(controls.panCamera.down) then
    cameraPos.rawY = cameraPos.rawY - dt * cameraSpeed
  end
  if love.keyboard.isDown(controls.panCamera.left) then
    cameraPos.rawX = cameraPos.rawX + dt * cameraSpeed
  end
  if love.keyboard.isDown(controls.panCamera.right) then
    cameraPos.rawX = cameraPos.rawX - dt * cameraSpeed
  end

  --screen shake things
  if cameraPos.shake and cameraPos.shake.t > 0 then
    cameraPos.xOffset = math.random(-cameraPos.shake.v, cameraPos.shake.v)
    cameraPos.yOffset = math.random(-cameraPos.shake.v, cameraPos.shake.v)
    cameraPos.shake.t = cameraPos.shake.t-dt
    if cameraPos.shake.t <= 0 then
      cameraPos.shake = nil
    end
  end

  cameraPos.x = math.floor(cameraPos.rawX + cameraPos.xOffset)
  cameraPos.y = math.floor(cameraPos.rawY + cameraPos.yOffset)
end

function centerCamOnCoords(x, y)
  local x, y = coordToIso(x, y)
  cameraPos.rawX = screen.w / 2 - x - tileSize
  cameraPos.rawY = screen.h / 2 - y - tileSize/2
end

function screenShake(v, t)
  cameraPos.shake = {v = v, t = t}
end
