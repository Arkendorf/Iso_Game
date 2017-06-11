function char_load()
  chars = {}
  chars[1] = {x = 24, y = 24}
end

function drawAChar(y,y2)
  for i, v in ipairs(chars) do
    if v.y >= y and v.y < y2 then
      love.graphics.setColor(100, 100, 200)
      local tX, tY = coordToIso(v.x-1, v.y-1)
      love.graphics.draw(wall, tX, tY - wall:getHeight()+tileSize*2)
      love.graphics.setColor(255, 255, 255)
    end
  end
end

function coordToIso(x, y)
  x = x /(tileSize*2)
  y = y /(tileSize*2)
  return (x-y+#rooms[currentRoom]-1)*tileSize*2+1, (y+x)*tileSize+1 -- 1 is added so players fit nicely with walls
end
