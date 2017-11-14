function enemychar_load()
  enemyActors = {}
  enemyActors[1] = {speed = 30, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 5, health = 10, abilities = {1, 1}, weapon = 2, type = 1, img = 1}
  enemyActors[2] = {speed = 120, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 5, health = 10, abilities = {1, 1}, weapon = 2, type = 2, img = 1}
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

      local img = v.actor.item.img -- set img

      if v.anim.quad == 4 then -- draw enemy and possibly weapon
        if v.dir == "l" or v.dir == "u" then
          love.graphics.setColor(255, 255, 255)
          love.graphics.draw(weaponImgs.img[v.weapon], weaponImgs.quad[v.weapon][v.dir][v.anim.weaponQuad][math.floor(v.anim.weaponFrame)], charImgs.info[img].center[v.dir].x-weaponImgs.info[v.weapon].center[v.dir].x-cameraPos.x, 9+charImgs.info[img].center[v.dir].y-weaponImgs.info[v.weapon].center[v.dir].y-cameraPos.y)
        end
        love.graphics.setColor(r, g, b)
        love.graphics.draw(charImgs.img[img], charImgs.quad[img][v.dir][v.anim.quad][math.floor(v.anim.frame)], -cameraPos.x, 9-cameraPos.y) -- draw corpse
        if v.dir == "r" or v.dir == "d" then
          love.graphics.setColor(255, 255, 255)
          love.graphics.draw(weaponImgs.img[v.weapon], weaponImgs.quad[v.weapon][v.dir][v.anim.weaponQuad][math.floor(v.anim.weaponFrame)], charImgs.info[img].center[v.dir].x-weaponImgs.info[v.weapon].center[v.dir].x-cameraPos.x, 9+charImgs.info[img].center[v.dir].y-weaponImgs.info[v.weapon].center[v.dir].y-cameraPos.y)
        end
      else
        love.graphics.setColor(r, g, b)
        love.graphics.draw(charImgs.img[img], charImgs.quad[img][v.dir][v.anim.quad][math.floor(v.anim.frame)], -cameraPos.x, 9-cameraPos.y) -- draw corpse
      end

      -- draw health bar / icons
      if v.dead == false then
        drawEnemyActorHud(i, v, img, 24)
      end

      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize*2-charImgs.width[img]/2, y = math.floor(y)+tileSize/2, z = charImgs.height[img]-tileSize+9}
    end
  end
end

function drawEnemyActorHud(i, v, img, w)
  love.graphics.setFont(smallFont)

  local x = charImgs.width[img]/2-w/2

  local dmg = 0
  local color = palette.red
  if currentActor.mode == 1 and currentActor.target.item and currentActor.target.valid then
    local info = weapons[currentActor.actor.item.weapon]
    dmg = getDamage(currentActor, v, currentActor.target.item)
    if dmg > 0 and info.type and v.actor.item.type and crit(info.type, v.actor.item.type) then -- check if attack is a crit
      color = palette.orange
    end
  elseif currentActor.mode > 1 and currentActor.target.item and currentActor.target.valid then
    local info = abilities[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo
    dmg = getDamage(currentActor, v, currentActor.target.item, info)
    if dmg > 0 and info.type and crit(info.type, v.actor.item.type) then -- check if attack is a crit
      color = palette.orange
    end
  end

  -- draw health number and bar
  local health = math.floor((v.futureHealth-dmg)*10)/10
  if health < 0 then health = 0 end
  if dmg > 0 then
    love.graphics.setColor(gradient(5, color)) -- current health
    love.graphics.rectangle("fill", x+9-cameraPos.x, 6-cameraPos.y, v.displayHealth/v.actor.item.health*(w-9), 2)
    love.graphics.print(tostring(health), x+w+1-smallFont:getWidth(tostring(health))-cameraPos.x, -cameraPos.y)
  end
  love.graphics.setColor(color) -- future health
  if (v.futureHealth - dmg) > 0 then
    love.graphics.rectangle("fill", x+9-cameraPos.x, 6-cameraPos.y, (v.futureHealth-dmg)/v.actor.item.health*(w-9), 2)
  end
  if dmg <= 0 then
    love.graphics.print(tostring(health), x+w+1-smallFont:getWidth(tostring(health))-cameraPos.x, -cameraPos.y)
  end

  -- set visibility cover
  if v.seen[currentActorNum] == true then
    love.graphics.setColor(palette.red)
  elseif (currentActor.mode == 0 and newMove.seers[i]) or (currentActor.mode > 0 and v.willSee[currentActorNum]) then
    love.graphics.setColor(palette.orange)
  else
    love.graphics.setColor(200, 200, 200)
  end
  -- draw icon
  love.graphics.draw(enemyIcon.img, enemyIcon.quad[v.actor.item.type], x-cameraPos.x, -cameraPos.y)

  love.graphics.setFont(font)
end
