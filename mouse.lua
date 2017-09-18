function mouse_load()
  mouse= {}
end

function mouse_update(dt)
  mouse.x = love.mouse.getX() / screen.scale
  mouse.y = love.mouse.getY() / screen.scale
  mouse.transX, mouse.transY = mouse.x, mouse.y
  mouse.transX = mouse.transX-cameraPos.x
  mouse.transY = mouse.transY-cameraPos.y
  cursorPos = roomNodes[1]
  if currentActor.targetMode == 4 then -- if targetMode == 4, only allow tiles Adjacent to player
    for i, v in ipairs(roomNodes) do
      local tX, tY = coordToTile(currentActor.x, currentActor.y)
      if neighbors({x = v.tX, y = v.tY}, {x = tX, y = tY}) == true and distance(v.x, v.y, mouse.transX, mouse.transY) < distance(cursorPos.x, cursorPos.y, mouse.transX, mouse.transY) then
        cursorPos = v
      end
    end
  else
    for i, v in ipairs(roomNodes) do
      if distance(v.x, v.y, mouse.transX, mouse.transY) < distance(cursorPos.x, cursorPos.y, mouse.transX, mouse.transY) then
        cursorPos = v
      end
    end
  end
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end

function mouse_draw()
  if currentActor.targetMode == 0 then
    setValidColor(currentActor.path.valid)
    love.graphics.draw(cursorImg, tileToIso(cursorPos.tX,cursorPos.tY))
  elseif currentActor.targetMode ~= 3 then
    setValidColor(currentActor.target.valid)
    love.graphics.draw(targetImg, tileToIso(cursorPos.tX,cursorPos.tY))
  end
end
