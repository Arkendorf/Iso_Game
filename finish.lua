function drawFinish(room)
  if room == currentLevel.start.room then -- draw start of level
    love.graphics.setColor(palette.purple)
    for i = 0, 2 do
      for j = 0, 2 do
        local x, y = tileToIso(currentLevel.start.x+j, currentLevel.start.y+i)
        love.graphics.draw(finishImg, finishQuad[i*3+j+1], x, y)
      end
    end
  end

  if room == currentLevel.finish.room then -- draw end of level
  love.graphics.setColor(palette.yellow)
    for i = 0, 2 do
      for j = 0, 2 do
        local x, y = tileToIso(currentLevel.finish.x+j, currentLevel.finish.y+i)
        love.graphics.draw(finishImg, finishQuad[i*3+j+1], x, y)
      end
    end
  end
end

function safe(v)
  local tX, tY = coordToTile(v.x, v.y)
  if v.room == currentLevel.finish.room and tX >= currentLevel.finish.x and tX <= currentLevel.finish.x + 2 and tY >= currentLevel.finish.y and tY <= currentLevel.finish.y + 2 then
    return true
  else
    return false
  end
end


function VIPsSafe()
  for i, v in ipairs(currentLevel.actors) do
    if v.actor.item.vip and not safe(v) then
      return false
    end
  end
  return true
end
