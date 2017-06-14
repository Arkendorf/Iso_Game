function mouse_update(dt)
  local mX, mY = love.mouse.getPosition()
  cursorPos = roomNodes[1]
  for i, v in ipairs(roomNodes) do
    if distance(v[3], v[4], mX, mY) < distance(cursorPos[3], cursorPos[4], mX, mY) then
      cursorPos = v
    end
  end
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end

function mouse_draw()
  love.graphics.draw(cursor, tileToIso(cursorPos[1]-1,cursorPos[2]-1))
end
