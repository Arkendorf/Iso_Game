function drawScannedHazards(room)
  for i, v in ipairs(levels[currentLevel].hazards) do
    if v.room == room then
      if scanFlicker[5] == 0 then
        love.graphics.setColor(palette.red)
      else
        love.graphics.setColor(palette.red[1]/2, palette.red[2]/2, palette.red[3]/2)
      end
      love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromHazards(room, v.tX, v.tY)], tileToIso(v.tX-1, v.tY-1))
      love.graphics.draw(scanIconImg, scanIconQuad[5], tileToIso(v.tX-1, v.tY-1))
    end
  end
end
