function finish_draw()
  if currentActor.room == currentLevel.start.room then -- draw start of level
    for i = 0, 2 do
      for j = 0, 2 do
        local x, y = tileToIso(currentLevel.start.x+j, currentLevel.start.y+i)
        love.graphics.draw(startTileImg, x, y)
      end
    end
  end

  if currentActor.room == currentLevel.finish.room then -- draw end of level
    for i = 0, 2 do
      for j = 0, 2 do
        local x, y = tileToIso(currentLevel.finish.x+j, currentLevel.finish.y+i)
        love.graphics.draw(startTileImg, x, y)
      end
    end
  end
end
