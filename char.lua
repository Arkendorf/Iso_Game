function char_load()
  playerActors ={}
  playerActors[1] = {}
  playerActors[1][1] = {speed = 30, turnPts = 10, name = "Luke", health = 20}
  playerActors[1][2] = {speed = 120, turnPts = 20, name = "Ben", health = 10}
  charHeight = 32
end

function queueChars(room)
  for i, v in ipairs(currentLevel.actors) do
    if room == v.room then
      local canvas, oldCanvas = startNewCanvas(tileSize*2, charHeight)
      love.graphics.setCanvas(canvas)
      love.graphics.clear()
      love.graphics.setColor(255, 255, 255)

      love.graphics.draw(wallImg, -cameraPos.x, -cameraPos.y)
      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x), y = math.floor(y), z= charHeight-tileSize, r = 100, g = 200, b = 100}
    end
  end
end




function queueScanChars(room)
  for i, v in ipairs(currentLevel.actors) do
    if room == v.room then
      local canvas, oldCanvas = startNewCanvas(tileSize*2, charHeight)
      love.graphics.setCanvas(canvas)
      love.graphics.clear()
      love.graphics.setColor(511, 511, 511)

      love.graphics.draw(wallImg, -cameraPos.x, -cameraPos.y)
      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x), y = math.floor(y), z= charHeight-tileSize, r = palette.green[1], g = palette.green[2], b = palette.green[3]}
    end
  end
end
