function char_load()
  playerActors ={}
  playerActors[1] = {speed = 30, turnPts = 10, name = "Luke", health = 20, abilities = {1, 1}, weapon = 1, type = 1, img = 1, vip = false}
  playerActors[2] = {speed = 120, turnPts = 20, name = "Ben", health = 10, abilities = {1, 1}, weapon = 1, type = 2, img = 1, vip = false}
end

function queueChars(room)
  for i, v in ipairs(currentLevel.actors) do
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
        drawActorHud(i, v, img, 24)
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

function drawChar(v, img)
  local r, g, b = nil
  for j = 1, #effects do -- change color based on current effects
    if v.effects[j] and effects[j].r and effects[j].g and effects[j].g then
      if not r then
        r = effects[j].r
      else
        r = r * 0.5 + effects[j].r * 0.5
      end
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
    r, g, b = 255, 255, 255
  end

  if v.anim.quad == 4 then -- draw actor and possibly weapon
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

  return img
end

function drawActorHud(i, v, img, w)
  love.graphics.setFont(smallFont)

  local x = charImgs.width[img]/2-w/2

  -- draw health number and bar
  local health = math.floor(v.futureHealth*10)/10
  if health < 0 then health = 0 end

  love.graphics.setColor(palette.red) -- future health
  love.graphics.print(tostring(health), x+w+1-smallFont:getWidth(tostring(health))-cameraPos.x, -cameraPos.y)
  if v.futureHealth > 0 then
    love.graphics.rectangle("fill", x+9-cameraPos.x, 6-cameraPos.y, v.futureHealth/v.actor.item.health*(w-9), 2)
  end

  -- draw icon
  love.graphics.setColor(palette.green)
  love.graphics.draw(enemyIcon.img, enemyIcon.quad[v.actor.item.type], x-cameraPos.x, -cameraPos.y)

  love.graphics.setFont(font)
end
