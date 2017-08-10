function drawScannedHazards(room)
  for i, v in ipairs(levels[currentLevel].hazards) do
    if v.room == room then
      love.graphics.setColor(palette.red)
      love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromHazards(room, v.tX, v.tY)], tileToIso(v.tX, v.tY))
      love.graphics.draw(scanIconImg, scanIconQuad[5], tileToIso(v.tX, v.tY))
    end
  end
end

function queueHazards(room)
  for i, v in ipairs(levels[currentLevel].hazards) do
    if v.room == room then
      local x, y = tileToIso(v.tX, v.tY)
      drawQueue[#drawQueue + 1] = {img = hazardImg, x = x, y = y, z= hazardImg:getHeight()-tileSize}
    end
  end
end
