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
