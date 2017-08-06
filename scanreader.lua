function scanreader_load()
  scanning = false
  scanLayers = {}
  palette = {green = {0, 255, 33}, yellow = {255, 216, 0}, blue = {0, 38, 255}, cyan = {0, 200, 255}, purple = {178, 0, 255}, red = {255, 0, 110}}
  scanFlicker = {0, 0, 0, 0, 0, 0}
end

function drawScannedRoom()
  if scanFlicker[1] == 0 then
    love.graphics.setColor(palette.yellow)
  else
    love.graphics.setColor(palette.yellow[1]/2, palette.yellow[2]/2, palette.yellow[3]/2)
  end
  love.graphics.draw(scanLayers[currentRoom].floor)
  if scanFlicker[2] == 0 then
    love.graphics.setColor(palette.blue)
  else
    love.graphics.setColor(palette.blue[1]/2, palette.blue[2]/2, palette.blue[3]/2)
  end
  love.graphics.draw(scanLayers[currentRoom].walls)
  if scanFlicker[3] == 0 then
    love.graphics.setColor(palette.cyan)
  else
    love.graphics.setColor(palette.cyan[1]/2, palette.cyan[2]/2, palette.cyan[3]/2)
  end
  love.graphics.draw(scanLayers[currentRoom].cover)
  drawDoors(currentRoom) -- draws the door icons
  drawScannedHazards(currentRoom) -- draws hazard icon
  setPathColor() -- sets color of path indicator
  drawPath(currentActor) -- draws path indicator
  local charCanvas = charScanCanvas(currentRoom)
  if scanFlicker[6] == 0 then
    love.graphics.setColor(palette.green)
  else
    love.graphics.setColor(palette.green[1]/2, palette.green[2]/2, palette.green[3]/2)
  end
  love.graphics.draw(charCanvas, 0, -charHeight)
end

function scanreader_update(dt)
  for i = 1, #scanFlicker do
    if scanFlicker[i] == 0 then
      if math.random(0, 500) == 1 then
        scanFlicker[i] = math.random(0.1, 1)
      end
    else
      scanFlicker[i] = scanFlicker[i] - dt
      if scanFlicker[i] < 0 then
        scanFlicker[i] = 0
      end
    end
  end
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
        love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromMap(room, j, i, rooms[room], type)], tileToIso(j-1, i-1))
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

    for i, v in ipairs(levels[currentLevel].doors) do -- fill in gaps around doors
      if room == v.room1 then
        if v.tY1 < #rooms[room] and v.tX1 > 1 and tileType[rooms[room][v.tY1+1][v.tX1-1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX1-2, v.tY1))
        end
        if v.tY1 > 1 and v.tX1 < #rooms[room][i] and tileType[rooms[room][v.tY1-1][v.tX1+1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX1, v.tY1-2))
        end
      elseif room == v.room2 then
        if v.tY2 < #rooms[room] and v.tX2 > 1 and tileType[rooms[room][v.tY2+1][v.tX2-1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX2-2, v.tY2))
        end
        if v.tY2 > 1 and v.tX2 < #rooms[room][i] and tileType[rooms[room][v.tY2-1][v.tX2+1]] == type then -- fills in some gaps in border
          love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX2, v.tY2-2))
        end
      end
    end
  end
  for i, v in ipairs(levels[currentLevel].hazards) do -- fill in gaps around doors
    if room == v.room then
      if v.tY < #rooms[room] and v.tX > 1 and tileType[rooms[room][v.tY+1][v.tX-1]] == type then -- fills in some gaps in border
        love.graphics.draw(scanBorderImg, scanBorderQuad[18], tileToIso(v.tX-2, v.tY))
      end
      if v.tY > 1 and v.tX < #rooms[room][i] and tileType[rooms[room][v.t1-1][v.tX+1]] == type then -- fills in some gaps in border
        love.graphics.draw(scanBorderImg, scanBorderQuad[17], tileToIso(v.tX, v.tY-2))
      end
    end
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.setCanvas()
  return layer
end
