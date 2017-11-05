function enemychar_load()
  enemyActors = {}
  enemyActors[1] = {speed = 30, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 164, health = 10, abilities = {1, 1}, weapon = 2, type = 1, img = 1}
  enemyActors[2] = {speed = 120, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 164, health = 10, abilities = {1, 1}, weapon = 2, type = 2, img = 1}
end

function queueEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    if room == v.room then
      local canvas, oldCanvas = resumeCanvas(v.canvas)

      -- draw enemy
      local r, g, b = nil
      for j = 1, #effects do -- change color based on current effects
        if v.effects[j] and effects[j].r and effects[j].g and effects[j].g then
          if not g then
            g = effects[j].g
          else
            g = g * 0.5 + effects[j].g * 0.5
          end
          if not b then
            b = effects[j].b
          else
             b = b * 0.5 + effects[j].b * 0.5
          end
        end
      end
      if not r or not g or not b then -- set color to effect color if it exists
        r, g, b = 200, 100, 100
      end

      if v.anim.quad == 4 then -- draw enemy and possibly weapon
        if v.dir == "l" or v.dir == "u" then
          love.graphics.setColor(255, 255, 255)
          love.graphics.draw(weaponImgs.img[v.weapon], weaponImgs.quad[v.weapon][v.dir][v.anim.weaponQuad][math.floor(v.anim.weaponFrame)], charImgs.info[v.actor.item.img].center[v.dir].x-weaponImgs.info[v.weapon].center[v.dir].x-cameraPos.x, charImgs.info[v.actor.item.img].center[v.dir].y-weaponImgs.info[v.weapon].center[v.dir].y-cameraPos.y)
        end
        love.graphics.setColor(r, g, b)
        love.graphics.draw(charImgs.img[v.actor.item.img], charImgs.quad[v.actor.item.img][v.dir][v.anim.quad][math.floor(v.anim.frame)], -cameraPos.x, 12-cameraPos.y) -- draw corpse
        if v.dir == "r" or v.dir == "d" then
          love.graphics.setColor(255, 255, 255)
          love.graphics.draw(weaponImgs.img[v.weapon], weaponImgs.quad[v.weapon][v.dir][v.anim.weaponQuad][math.floor(v.anim.weaponFrame)], charImgs.info[v.actor.item.img].center[v.dir].x-weaponImgs.info[v.weapon].center[v.dir].x-cameraPos.x, charImgs.info[v.actor.item.img].center[v.dir].y-weaponImgs.info[v.weapon].center[v.dir].y-cameraPos.y)
        end
      else
        love.graphics.setColor(r, g, b)
        love.graphics.draw(charImgs.img[v.actor.item.img], charImgs.quad[v.actor.item.img][v.dir][v.anim.quad][math.floor(v.anim.frame)], -cameraPos.x, 12-cameraPos.y) -- draw corpse
      end

      -- draw hud and char
      if v.dead == false then
        local dmgEstimate = 0
        local color = palette.red
        if currentActor.target.item then -- check if player target is this enemy
          if currentActor.target.valid == true and currentActor.mode == 1 then
            dmgEstimate = getDamage(currentActor, v, currentActor.target.item)
            if crit(weapons[currentActor.actor.item.weapon].type, v.actor.item.type) then -- if attack will crit, change color
              color = palette.orange
            end
          elseif currentActor.target.valid == true and currentActor.mode > 1 then
            dmgEstimate = getDamage(currentActor, v, currentActor.target.item, abilities[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo)
            if crit(abilities[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo.type, v.actor.item.type) then -- if attack will crit, change color
              color = palette.orange
            end
          end
        end
        if dmgEstimate > 0 then -- if attack will effect this enemy, signal it by flashing the health color
          love.graphics.setColor(gradient(5, color)) -- current health
          love.graphics.rectangle("fill", charImgs.width[v.actor.item.img]/2-4-cameraPos.x, 10-cameraPos.y, v.displayHealth/v.actor.item.health*8, 2)
          love.graphics.setColor(color) -- future health
          if (v.futureHealth- dmgEstimate) > 0 then
            love.graphics.rectangle("fill", charImgs.width[v.actor.item.img]/2-4-cameraPos.x, 10-cameraPos.y, (v.futureHealth-dmgEstimate)/v.actor.item.health*8, 2)
          end
        else
          love.graphics.setColor(color)
          if (v.displayHealth- dmgEstimate) > 0 then -- health after projectiles and possible current attack deal damage
            love.graphics.rectangle("fill", charImgs.width[v.actor.item.img]/2-4-cameraPos.x, 10-cameraPos.y, v.displayHealth/v.actor.item.health*8, 2)
          end
        end

        local x, y = tileToCoord(cursorPos.tX, cursorPos.tY)
        if v.seen[currentActorNum] == true then
          love.graphics.setColor(palette.red)
        elseif (currentActor.mode == 0 and isPlayerInView(v, {x = x, y = y, dead = currentActor.dead, room = currentActor.room}) == true) or (currentActor.mode ~= 0 and isPlayerInView(v, currentActor) == true) then
          love.graphics.setColor(palette.orange)
        else
          love.graphics.setColor(200, 200, 200)
        end
        love.graphics.draw(enemyIcon.img, enemyIcon.quad[v.actor.item.type], charImgs.width[v.actor.item.img]/2-4-cameraPos.x, 1-cameraPos.y)
      end

      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize*2-charImgs.width[v.actor.item.img]/2, y = math.floor(y)+tileSize/2, z= charImgs.height[v.actor.item.img]-tileSize+12}
    end
  end
end
