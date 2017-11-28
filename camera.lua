function camera_load()
  cameraPos = {x = 0, y = 0, rawX = 0, rawY = 0, newX = 0, newY = 0, xOffset = 0, yOffset = 0}
  cameraSpeed = 60
end

function camera_update(dt)
  if love.keyboard.isDown(controls.panCamera.up) then
    cameraPos.newY = cameraPos.newY + dt * cameraSpeed
  end
  if love.keyboard.isDown(controls.panCamera.down) then
    cameraPos.newY = cameraPos.newY - dt * cameraSpeed
  end
  if love.keyboard.isDown(controls.panCamera.left) then
    cameraPos.newX = cameraPos.newX + dt * cameraSpeed
  end
  if love.keyboard.isDown(controls.panCamera.right) then
    cameraPos.newX = cameraPos.newX - dt * cameraSpeed
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

  -- set raw to go towards new
  cameraPos.rawX = cameraPos.rawX + (cameraPos.newX - cameraPos.rawX) * 0.2
  cameraPos.rawY = cameraPos.rawY + (cameraPos.newY - cameraPos.rawY) * 0.2
  -- set normal to be pixel-perfect raw plus offset
  cameraPos.x = math.floor(cameraPos.rawX + cameraPos.xOffset)
  cameraPos.y = math.floor(cameraPos.rawY + cameraPos.yOffset)
end

function centerCamOnCoords(x, y)
  local x, y = coordToIso(x, y)
  cameraPos.rawX = screen.w / 2 - x - tileSize
  cameraPos.rawY = screen.h / 2 - y - tileSize/2
  -- prevent wierd jerks after centering cam
  cameraPos.newX = cameraPos.rawX
  cameraPos.newY = cameraPos.rawY
end

function driftCamToCoords(x, y)
  local x, y = coordToIso(x, y)
  cameraPos.newX = screen.w / 2 - x - tileSize
  cameraPos.newY = screen.h / 2 - y - tileSize/2
end

function screenShake(v, t)
  cameraPos.shake = {v = v, t = t}
end
