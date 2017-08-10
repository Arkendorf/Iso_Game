function scanreader_load()
  scanning = false
  scanLayers = {}
  palette = {green = {0, 255, 33}, yellow = {255, 216, 0}, blue = {0, 38, 255}, cyan = {0, 200, 255}, purple = {178, 0, 255}, red = {255, 0, 110}}
end

function drawScannedRoom()
  love.graphics.setColor(palette.yellow)
  love.graphics.draw(scanLayers[currentRoom].floor)
  love.graphics.setColor(palette.blue)
  love.graphics.draw(scanLayers[currentRoom].walls)
  love.graphics.setColor(palette.cyan)
  love.graphics.draw(scanLayers[currentRoom].cover)
  drawDoors(currentRoom) -- draws the door icons
  drawScannedHazards(currentRoom) -- draws hazard icon
  setPathColor() -- sets color of path indicator
  drawPath(currentActor) -- draws path indicator
  local charCanvas = charScanCanvas(currentRoom) -- so it can be later greenified
  love.graphics.setColor(palette.green)
  love.graphics.draw(charCanvas, 0, -charHeight)
  local enemyCharCanvas = enemyCharScanCanvas(currentRoom) -- so it can be later redified
  love.graphics.setColor(palette.red)
  love.graphics.draw(enemyCharCanvas, 0, -enemyHeight)
end

function scanreader_keypressed(key)
  if key == controls.scanreader then
    if scanning == false then
      scanning = true
    else
      scanning = false
    end
  end
end

function drawScanLayer(room, type)
  local layer = love.graphics.newCanvas((#rooms[room][1]+1)*tileSize*2, (#rooms[room]+1)*tileSize)
  love.graphics.setCanvas(layer)
  love.graphics.clear()
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == type then
        love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromMap(room, j, i, rooms[room], type)], tileToIso(j, i))
        love.graphics.draw(scanIconImg, scanIconQuad[type], tileToIso(j, i))
      else
        if i < #rooms[room] and j > 1 and tileType[rooms[room][i+1][j-1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(j-1, i+1))
        end
        if i > 1 and j < #rooms[room][i] and tileType[rooms[room][i-1][j+1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(j+1, i-1))
        end
      end
    end

    for i, v in ipairs(levels[currentLevel].doors) do -- fill in gaps around doors
      if room == v.room1 then
        if v.tY1 < #rooms[room] and v.tX1 > 1 and tileType[rooms[room][v.tY1+1][v.tX1-1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX1-1, v.tY1+1))
        end
        if v.tY1 > 1 and v.tX1 < #rooms[room][i] and tileType[rooms[room][v.tY1-1][v.tX1+1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX1+1, v.tY1-1))
        end
      elseif room == v.room2 then
        if v.tY2 < #rooms[room] and v.tX2 > 1 and tileType[rooms[room][v.tY2+1][v.tX2-1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX2-1, v.tY2+1))
        end
        if v.tY2 > 1 and v.tX2 < #rooms[room][i] and tileType[rooms[room][v.tY2-1][v.tX2+1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX2+1, v.tY2-1))
        end
      end
    end
  end
  for i, v in ipairs(levels[currentLevel].hazards) do -- fill in gaps around doors
    if room == v.room then
      if v.tY < #rooms[room] and v.tX > 1 and tileType[rooms[room][v.tY+1][v.tX-1]] == type then -- fills in some gaps in border
        love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX-1, v.tY+1))
      end
      if v.tY > 1 and v.tX < #rooms[room][i] and tileType[rooms[room][v.tY-1][v.tX+1]] == type then -- fills in some gaps in border
        love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX+1, v.tY-1))
      end
    end
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.setCanvas()
  return layer
end
