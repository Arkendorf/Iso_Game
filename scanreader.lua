function scanreader_load()
  scanning = false
  scanFloors = {}
end

function drawScannedRoom()
  love.graphics.draw(scanFloors[currentRoom])
  drawDoors(currentRoom) -- draws the door icons
  drawScannedHazards(currentRoom) -- draws hazard icon
  setValidColor(currentActor.path.valid) -- sets color of path indicator
  if currentActor.mode == 0 then
    drawPath(currentActor) -- draws path indicator
  end

  drawQueue = {} -- reset queue
  queueScanChars(currentRoom)
  queueScanEnemyChars(currentRoom)
  table.sort(drawQueue, function(a, b) return a.y < b.y end) -- sort queue to ensure proper layering
  drawItemsInQueue() -- draw items in queue
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

function drawScanFloor(room)
  local canvas = love.graphics.newCanvas((#rooms[room][1]+1)*tileSize*2, (#rooms[room]+1)*tileSize)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      local type = tileType[t]
      if type > 0 then
        love.graphics.setColor(colorFromTileType(type))
        love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromMap(room, j, i, rooms[room], type)], tileToIso(j, i))
        love.graphics.draw(scanIconImg, scanIconQuad[type], tileToIso(j, i))
      end
      if i < #rooms[room] and j > 1 and tileType[rooms[room][i+1][j-1]] > 0 and tileType[rooms[room][i+1][j-1]] ~= type then -- fills in some gaps in border
        love.graphics.setColor(colorFromTileType(tileType[rooms[room][i+1][j-1]]))
        love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(j-1, i+1))
      end
      if i > 1 and j < #rooms[room][i] and tileType[rooms[room][i-1][j+1]] > 0 and tileType[rooms[room][i-1][j+1]] ~= type then -- fills in some gaps in border
        love.graphics.setColor(colorFromTileType(tileType[rooms[room][i-1][j+1]]))
        love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(j+1, i-1))
      end
    end
  end
  for i, v in ipairs(currentLevel.doors) do -- fill in gaps around doors
    if room == v.room1 then
    if v.tY1 < #rooms[room] and v.tX1 > 1 and tileType[rooms[room][v.tY1+1][v.tX1-1]] ~= 0 then -- fills in some gaps in border
        love.graphics.setColor(colorFromTileType(tileType[rooms[room][v.tY1+1][v.tX1-1]]))
        love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX1-1, v.tY1+1))
      end
      if v.tY1 > 1 and v.tX1 < #rooms[room][i] and tileType[rooms[room][v.tY1-1][v.tX1+1]] ~= 0 then -- fills in some gaps in border
        love.graphics.setColor(colorFromTileType(tileType[rooms[room][v.tY1-1][v.tX1+1]]))
        love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX1+1, v.tY1-1))
      end
    elseif room == v.room2 then
      if v.tY2 < #rooms[room] and v.tX2 > 1 and tileType[rooms[room][v.tY2+1][v.tX2-1]] ~= 0 then -- fills in some gaps in border
        love.graphics.setColor(colorFromTileType(tileType[rooms[room][v.tY2+1][v.tX2-1]]))
        love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX2-1, v.tY2+1))
      end
      if v.tY2 > 1 and v.tX2 < #rooms[room][i] and tileType[rooms[room][v.tY2-1][v.tX2+1]] ~= 0 then -- fills in some gaps in border
        love.graphics.setColor(colorFromTileType(tileType[rooms[room][v.tY2-1][v.tX2+1]]))
        love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX2+1, v.tY2-1))
      end
    end
    for i, v in ipairs(currentLevel.hazards) do -- fill in gaps around doors
      if room == v.room then
        if v.tY < #rooms[room] and v.tX > 1 and tileType[rooms[room][v.tY+1][v.tX-1]] ~= 0 then -- fills in some gaps in border
          love.graphics.setColor(colorFromTileType(tileType[rooms[room][v.tY+1][v.tX-1]]))
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX-1, v.tY+1))
        end
        if v.tY > 1 and v.tX < #rooms[room][i] and tileType[rooms[room][v.tY-1][v.tX+1]] ~= 0 then -- fills in some gaps in border
          love.graphics.setColor(colorFromTileType(tileType[rooms[room][v.tY-1][v.tX+1]]))
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX+1, v.tY-1))
        end
      end
    end
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.setCanvas()
  return canvas
end

function colorFromTileType(type)
  if type == 1 then
    return palette.yellow
  elseif type == 2 then
    return palette.blue
  else
    return palette.cyan
  end
end
