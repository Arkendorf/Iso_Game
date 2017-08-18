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
      local canvas = love.graphics.newCanvas(tileSize*2, enemyHeight+4)
      love.graphics.setCanvas(canvas)
      love.graphics.clear()

      local tX, tY = coordToTile(v.x, v.y)
      if cursorPos.tX == tX and cursorPos.tY == tY and currentActor.mode == 1 and currentActor.move == false then
        if currentActor.target.num == i and currentActor.target.valid == true then
          love.graphics.setColor(gradient({200, 0, 0}, {100, 0, 0}, 5))
          love.graphics.rectangle("fill", -cameraPos.x, -cameraPos.y, v.health/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 3)
          love.graphics.setColor(255, 0, 0)
          local dmgEstimate = getDamage(currentActor, v)
          if (v.health- dmgEstimate) > 0 then
            love.graphics.rectangle("fill", -cameraPos.x, -cameraPos.y, (v.health- dmgEstimate)/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 3)
          end
        else
          love.graphics.setColor(255, 0, 0)
          love.graphics.rectangle("fill", -cameraPos.x, -cameraPos.y, v.health/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 3)
        end
      end

      love.graphics.setColor(200, 100, 100)
      love.graphics.draw(wallImg, -cameraPos.x, 4-cameraPos.y)
      love.graphics.setCanvas()

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {img = canvas, x = math.floor(x), y = math.floor(y), z= charHeight-tileSize+4}
    end
  end
end

function queueScanEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    if room == v.room then
      local canvas = love.graphics.newCanvas(tileSize*2, enemyHeight+4)
      love.graphics.setCanvas(canvas)
      love.graphics.clear()

      if currentActor.mode == 1 and currentActor.target.num == i and currentActor.target.valid == true then
        love.graphics.setColor(gradient({200, 0, 0}, {100, 0, 0}, 5))
        love.graphics.rectangle("fill", -cameraPos.x, -cameraPos.y, v.health/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 3)
        love.graphics.setColor(255, 0, 0)
        local dmgEstimate = getDamage(currentActor, v)
        if (v.health-dmgEstimate) > 0 then
          love.graphics.rectangle("fill", -cameraPos.x, -cameraPos.y, (v.health-dmgEstimate)/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 3)
        end
      else
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", -cameraPos.x, -cameraPos.y, v.health/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 3)
      end

      local canvas2 = love.graphics.newCanvas(tileSize*2, enemyHeight)
      love.graphics.setCanvas(canvas2)
      love.graphics.clear()
      love.graphics.setColor(511, 511, 511)
      love.graphics.draw(wallImg, -cameraPos.x, -cameraPos.y)

      love.graphics.setCanvas(canvas)
      love.graphics.setColor(palette.red)
      love.graphics.draw(canvas2, -cameraPos.x, 4-cameraPos.y)
      love.graphics.setCanvas()

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {img = canvas, x = math.floor(x), y = math.floor(y), z= charHeight-tileSize+4}
    end
  end
end
