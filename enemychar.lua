function enemychar_load()
  enemyActors = {}
  enemyActors[1] = {speed = 30, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 5, health = 10, abilities = {1, 1}, weapon = 2, type = 1, img = 2}
  enemyActors[2] = {speed = 120, turnPts = 10, moveAI = 1, combatAI = 1, eyesight = 5, health = 10, abilities = {1, 1}, weapon = 2, type = 2, img = 2}
end

function queueEnemyChars(room)
  for i, v in ipairs(currentLevel.enemyActors) do
    local img = v.actor.item.img -- set img to use for char
    if v.room == room then
      local canvas, oldCanvas = resumeCanvas(v.canvas) -- set canvas to normal canvas
      if v.warp.active == true then -- if player is warping, add the effect
        love.graphics.setShader(shaders.warpIn)
        shaders.warpIn:send("a", v.warp.alpha/255)
      end
      drawChar(v, img) -- draw the player
      love.graphics.setShader() -- clear the shader (if any)
      if v.dead == false then-- draw health bar / icons
        drawEnemyActorHud(i, v, img, 24)
      end
      love.graphics.setCanvas(oldCanvas) -- return to main canvas
      local x, y = coordToIso(v.x, v.y) -- calculate where to draw the player
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize*2-charImgs.width[img]/2, y = math.floor(y)+tileSize/2, z = charImgs.height[img]-tileSize+9} -- add player to queue
    end
    if v.warp.active == true and v.warp.room == room then -- if player is warping, draw it in previous location
      local canvas, oldCanvas = resumeCanvas(v.warp.canvas) -- set canvas to 'warp' canvas
      love.graphics.setShader(shaders.warpOut) -- apply warp effect
      shaders.warpOut:send("a", v.warp.alpha/255)
      drawChar(v, img) -- draw the player
      love.graphics.setShader() -- remove the shader
      love.graphics.setCanvas(oldCanvas) -- return to main canvas
      local x, y = coordToIso(v.warp.x, v.warp.y) -- calculate position of 'warping' player
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize*2-charImgs.width[img]/2, y = math.floor(y)+tileSize/2, z = charImgs.height[img]-tileSize+9} -- add to queue
    end
  end
end


function drawEnemyActorHud(i, v, img, w)
  love.graphics.setFont(smallFont)

  local x = charImgs.width[img]/2-w/2

  local dmg = 0
  local color = palette.red
  if currentActor.mode == 1 and newMove.target.item and newMove.target.valid then
    local info = weapons[currentActor.actor.item.weapon]
    dmg = getDamage(currentActor, v, newMove.target.item)
    if dmg > 0 and info.type and v.actor.item.type and crit(info.type, v.actor.item.type) then -- check if attack is a crit
      color = palette.orange
    end
  elseif currentActor.mode > 1 and cnewMove.target.item and newMove.target.valid then
    local info = abilities[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo
    dmg = getDamage(currentActor, v, newMove.target.item, info)
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
