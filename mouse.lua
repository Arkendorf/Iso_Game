function mouse_load()
  mouse= {}
end

function mouse_update(dt)
  mouse.x, mouse.y = love.mouse.getPosition()
  cursorPos = roomNodes[1]
  for i, v in ipairs(roomNodes) do
    if distance(v.x, v.y, mouse.x, mouse.y) < distance(cursorPos.x, cursorPos.y, mouse.x, mouse.y) then
      cursorPos = v
    end
  end
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end

function mouse_draw()
  love.graphics.draw(cursor, tileToIso(cursorPos.tX-1,cursorPos.tY-1))
end
