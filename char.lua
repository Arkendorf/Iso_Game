function char_load()
  playerActors ={}
  playerActors[1] = {}
  playerActors[1][1] = {speed = 30, turnPts = 10, name = "Luke"}
  playerActors[1][2] = {speed = 120, turnPts = 20, name = "Ben"}
  charHeight = 32
end

function queueChars(room)
  for i, v in ipairs(levels[currentLevel].actors) do
    if room == v.room then
      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {img = wallImg, x = math.floor(x), y = math.floor(y), z= charHeight-tileSize, r = 100, g = 100, b = 200}
    end
  end
end

function charScanCanvas(room)
  local layer = love.graphics.newCanvas((#rooms[room][1]+1)*tileSize*2, (#rooms[room]+1)*tileSize+charHeight)
  love.graphics.setCanvas(layer)
  love.graphics.clear()
  love.graphics.setColor(511, 511, 511)
  for i, v in ipairs(levels[currentLevel].actors) do
    if room == v.room then
      local x, y = coordToIso(v.x, v.y)
      love.graphics.draw(wallImg, math.floor(x)-cameraPos.x, math.floor(y)+16-cameraPos.y) -- cameraPos is subtracted because this function is called in room_draw() which causes it to be translated twice
    end
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.setCanvas()
  return layer
end
