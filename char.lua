function char_load()
  playerActors ={}
  playerActors[1] = {speed = 30, turnPts = 10, name = "Luke", health = 20, abilities = {1, 1}, weapon = 1, type = 1, img = 1, vip = true}
  playerActors[2] = {speed = 120, turnPts = 20, name = "Ben", health = 10, abilities = {1, 1}, weapon = 1, type = 2, img = 1, vip = true}
end

function queueChars(room)
  for i, v in ipairs(currentLevel.actors) do
    if room == v.room then
      local canvas, oldCanvas = resumeCanvas(v.canvas)

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
        r, g, b = 100, 200, 100
      end

      local img = v.actor.item.img -- set img

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

      -- draw health bar / icons
      if v.dead == false then
        drawActorHud(i, v, img, 24)
      end

      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize*2-charImgs.width[img]/2, y = math.floor(y)+tileSize/2, z = charImgs.height[img]-tileSize+9}
    end
  end
end

function drawActorHud(i, v, img, w)
  love.graphics.setFont(smallFont)

  local x = charImgs.width[img]/2-w/2

  -- draw health number and bar
  local health = math.floor(v.futureHealth*10)/10
  if health < 0 then health = 0 end

  love.graphics.setColor(palette.red) -- future health
  love.graphics.rectangle("fill", x+9-cameraPos.x, 6-cameraPos.y, v.futureHealth/v.actor.item.health*(w-9), 2)
  love.graphics.print(tostring(health), x+w+1-smallFont:getWidth(tostring(health))-cameraPos.x, -cameraPos.y)

  -- draw icon
  love.graphics.setColor(palette.green)
  love.graphics.draw(enemyIcon.img, enemyIcon.quad[v.actor.item.type], x-cameraPos.x, -cameraPos.y)

  love.graphics.setFont(font)
end
