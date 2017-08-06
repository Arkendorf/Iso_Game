function scanreader_load()
  scanning = false
end

function scanreader_keypressed(key)
  if key == "q" then
    if scanning == false then
      scanning = true
    else
      scanning = false
    end
  end
end

function drawScannedFloor(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        love.graphics.draw(scanFloorImg, scanFloorQuad[bitmaskFromMap(j, i, rooms[room], 1)], tileToIso(j-1, i-1))
      end
    end
  end
end

function drawScannedWall(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 2 then
        love.graphics.draw(scanWallImg, scanWallQuad[bitmaskFromMap(j, i, rooms[room], 2)], tileToIso(j-1, i-1))
      end
    end
  end
end

function drawScannedCover(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 3 then
        love.graphics.draw(scanCoverImg, scanCoverQuad[bitmaskFromMap(j, i, rooms[room], 3)], tileToIso(j-1, i-1))
      end
    end
  end
end

function drawScanLayer(room, type)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == type then
        love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromMap(j, i, rooms[room], type)], tileToIso(j-1, i-1))
        love.graphics.draw(scanIconImg, scanIconQuad[type], tileToIso(j-1, i-1))
      else
        if i < #rooms[room] and j > 1 and tileType[rooms[room][i+1][j-1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(j-2, i))
        end
        if i > 1 and j < #rooms[room][i] and tileType[rooms[room][i-1][j+1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(j, i-2))
        end
      end
    end
  end
end
