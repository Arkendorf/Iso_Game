function mouse_update(dt)
  local mX, mY = love.mouse.getPosition()
  currentNode = 1
  for i, v in ipairs(roomNodes) do
    if distance(v[3], v[4], mX, mY) < distance(roomNodes[currentNode][3], roomNodes[currentNode][4], mX, mY) then
      currentNode = i
    end
  end
  cursorPos = roomNodes[currentNode]
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end

function mouse_draw()
  love.graphics.draw(cursor, tileToIso(cursorPos[1]-1,cursorPos[2]-1))
end
