function enemychar_load()
  enemyActors = {}
  enemyActors[1] = {}
  enemyActors[1][1] = {speed = 30, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 164, health = 10}
  enemyActors[1][2] = {speed = 120, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 164, health = 10}
  enemyHeight = 32
end

function queueEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    if room == v.room then
      local canvas, oldCanvas = resumeCanvas(v.canvas)

      -- draw enemy
      love.graphics.setColor(200, 100, 100)
      love.graphics.draw(wallImg, -cameraPos.x, 9-cameraPos.y)

      -- draw hud
      if v.dead == false then
        local tX, tY = coordToTile(v.x, v.y)
        if cursorPos.tX == tX and cursorPos.tY == tY and currentActor.mode == 1 then
          if currentActor.target.num == i and currentActor.target.valid == true then
            love.graphics.setColor(gradient(5, palette.health))
            love.graphics.rectangle("fill", -cameraPos.x, 3-cameraPos.y, v.displayHealth/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 2)
            love.graphics.setColor(palette.health)
            local dmgEstimate = getDamage(currentActor, v)
            if (v.displayHealth- dmgEstimate) > 0 then
              love.graphics.rectangle("fill", -cameraPos.x, 3-cameraPos.y, (v.health- dmgEstimate)/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 2)
            end
          else
            love.graphics.setColor(palette.health)
            love.graphics.rectangle("fill", -cameraPos.x, 3-cameraPos.y, v.displayHealth/enemyActors[currentLevel.type][v.actor].health*tileSize*2, 2)
          end
        else
          local x, y = tileToCoord(cursorPos.tX, cursorPos.tY)
          if v.seen[currentActorNum] == true then
            love.graphics.setColor(255, 0, 0)
            love.graphics.draw(spottedImg, tileSize-4-cameraPos.x, -cameraPos.y)
          elseif currentActor.mode == 0 and isPlayerInView(v, {x = x, y = y, dead = currentActor.dead, room = currentActor.room}) == true then
            love.graphics.setColor(255, 127, 0)
            love.graphics.draw(spottedImg, tileSize-4-cameraPos.x, -cameraPos.y)
          elseif currentActor.mode ~= 0 and isPlayerInView(v, currentActor) == true then
            love.graphics.setColor(255, 127, 0)
            love.graphics.draw(spottedImg, tileSize-4-cameraPos.x, -cameraPos.y)
          end
        end
      end

      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z= charHeight-tileSize+9}
    end
  end
end
