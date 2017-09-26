function enemychar_load()
  enemyActors = {}
  enemyActors[1] = {speed = 30, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 164, health = 10, abilities = {1, 1}, weapon = 2, type = 1}
  enemyActors[2] = {speed = 120, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 164, health = 10, abilities = {1, 1}, weapon = 2, type = 2}
  enemyHeight = 32
end

function queueEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    if room == v.room then
      local canvas, oldCanvas = resumeCanvas(v.canvas)

      -- draw enemy
      local r, g, b = nil
      for j = 1, #effects do -- change color based on current effects
        if v.effects[j] ~= nil and effects[j].r ~= nil and effects[j].g ~= nil and effects[j].g ~= nil then
          if r == nil then
            r = effects[j].r
          else
            r = r * 0.5 + effects[j].r * 0.5
          end
          if g == nil then
            g = effects[j].g
          else
            g = g * 0.5 + effects[j].g * 0.5
          end
          if b == nil then
            b = effects[j].b
          else
             b = b * 0.5 + effects[j].b * 0.5
          end
        end
      end
      if r ~= nil and g ~= nil and g ~= nil then -- set color to effect color if it exists
        love.graphics.setColor(r, g, b)
      else
        love.graphics.setColor(200, 100, 100)
      end

      love.graphics.draw(wallImg, -cameraPos.x, 9-cameraPos.y)

      -- draw hud
      if v.dead == false then
        local dmgEstimate = 0
        local color = palette.red
        if currentActor.target.item ~= nil and currentActor.target.item.x == v.x and currentActor.target.item.y == v.y then -- check if player target is this enemy
          if currentActor.target.valid == true and currentActor.mode == 1 then
            dmgEstimate = getDamage(currentActor, v, currentActor.target.item)
            if crit(weapons[currentActor.actor.item.weapon].type, v.actor.item.type) then -- if attack will crit, change color
              color = {255, 127, 0}
            end
          elseif currentActor.target.valid == true and currentActor.mode > 1 then
            dmgEstimate = getDamage(currentActor, v, currentActor.target.item, abilities[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo)
            if crit(abilities[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo.type, v.actor.item.type) then -- if attack will crit, change color
              color = {255, 127, 0}
            end
          end
        end
        if dmgEstimate > 0 then -- if attack will effect this enemy, signal it by flashing the health color
          love.graphics.setColor(gradient(5, color)) -- current health
          love.graphics.rectangle("fill", -cameraPos.x, 10-cameraPos.y, v.displayHealth/v.actor.item.health*tileSize*2, 2)
          love.graphics.setColor(color) -- future health
          love.graphics.rectangle("fill", -cameraPos.x, 10-cameraPos.y, (v.futureHealth-dmgEstimate)/v.actor.item.health*tileSize*2, 2)
        else
          love.graphics.setColor(color)
          if (v.displayHealth- dmgEstimate) > 0 then -- health after projectiles and possible current attack deal damage
            love.graphics.rectangle("fill", -cameraPos.x, 10-cameraPos.y, v.displayHealth/v.actor.item.health*tileSize*2, 2)
          end
        end

        local x, y = tileToCoord(cursorPos.tX, cursorPos.tY)
        if v.seen[currentActorNum] == true then
          love.graphics.setColor(255, 0, 0)
        elseif (currentActor.mode == 0 and isPlayerInView(v, {x = x, y = y, dead = currentActor.dead, room = currentActor.room}) == true) or (currentActor.mode ~= 0 and isPlayerInView(v, currentActor) == true) then
          love.graphics.setColor(255, 127, 0)
        else
          love.graphics.setColor(200, 200, 200)
        end
        love.graphics.draw(enemyIcon.img, enemyIcon.quad[v.actor.item.type], 1-cameraPos.x, 1-cameraPos.y)
      end

      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z= enemyHeight-tileSize+9}
    end
  end
end
