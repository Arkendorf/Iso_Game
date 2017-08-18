function mouse_load()
  mouse= {}
end

function mouse_update(dt)
  mouse.x, mouse.y = love.mouse.getPosition()
  mouse.transX, mouse.transY = love.mouse.getPosition()
  mouse.transX = mouse.transX-cameraPos.x
  mouse.transY = mouse.transY-cameraPos.y
  cursorPos = roomNodes[1]
  for i, v in ipairs(roomNodes) do
    if distance(v.x, v.y, mouse.transX, mouse.transY) < distance(cursorPos.x, cursorPos.y, mouse.transX, mouse.transY) then
      cursorPos = v
    end
  end
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end

function mouse_draw()
  if currentActor.mode == 0 then
    setValidColor(currentActor.path.valid)
    love.graphics.draw(cursorImg, tileToIso(cursorPos.tX,cursorPos.tY))
  else
    setValidColor(currentActor.target.valid)
    love.graphics.draw(targetImg, tileToIso(cursorPos.tX,cursorPos.tY))
  end
end
