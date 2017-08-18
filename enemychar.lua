function enemychar_load()
  enemyActors = {}
  enemyActors[1] = {}
  enemyActors[1][1] = {speed = 30, turnPts = 10, ai = 1, eyesight = 164, health = 10}
  enemyActors[1][2] = {speed = 120, turnPts = 20, ai = 1, eyesight = 164, health = 10}
  enemyHeight = 32
end

function queueEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    if room == v.room then
      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {img = wallImg, x = math.floor(x), y = math.floor(y), z= enemyHeight-tileSize, r = 200, g = 100, b = 100}
    end
  end
end

function queueScanEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    if room == v.room then
      canvas = love.graphics.newCanvas(tileSize*2, enemyHeight)
      love.graphics.setCanvas(canvas)
      love.graphics.clear()
      love.graphics.setColor(511, 511, 511)

      love.graphics.draw(wallImg, -cameraPos.x, -cameraPos.y)
      love.graphics.setCanvas()

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {img = canvas, x = math.floor(x), y = math.floor(y), z= charHeight-tileSize, r = palette.red[1], g = palette.red[2], b = palette.red[3]}
    end
  end
end
