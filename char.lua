function char_load()
  chars = {}
  chars[1] = {speed = 30, turnPts = 10}
  chars[2] = {speed = 120, turnPts = 20}
end

function queueChars()
  for i, v in ipairs(levels[currentLevel].actors) do
      if currentRoom == v.room then
        local x, y = coordToIso(v.x, v.y)
        drawQueue[#drawQueue + 1] = {img = wall, x = x, y = y, z= wall:getHeight()-tileSize, r = 100, g = 100, b = 200}
      end
  end
end
