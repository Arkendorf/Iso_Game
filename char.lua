function char_load()
  chars = {}
  chars[1] = {}
end

function drawAChar(y,y2)
  for i, v in ipairs(levels[currentLevel].actors) do
    if currentRoom == v.room and v.y >= y and v.y < y2 then
      local tX, tY = coordToIso(v.x-1, v.y-1)
      if i == currentActor then
        love.graphics.draw(cursor, tX, tY)
      end

      love.graphics.setColor(100, 100, 200)
      love.graphics.draw(wall, tX, tY - wall:getHeight()+tileSize*2)
      love.graphics.setColor(255, 255, 255)
    end
  end
end
