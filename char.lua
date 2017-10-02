function char_load()
  playerActors ={}
  playerActors[1] = {speed = 30, turnPts = 10, name = "Luke", health = 20, abilities = {1, 2}, weapon = 1, type = 1, img = 1}
  playerActors[2] = {speed = 120, turnPts = 20, name = "Ben", health = 10, abilities = {1, 2}, weapon = 1, type = 2, img = 1}
end

function queueChars(room)
  for i, v in ipairs(currentLevel.actors) do
    if room == v.room then
      local canvas, oldCanvas = resumeCanvas(v.canvas)

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
        love.graphics.setColor(100, 200, 100)
      end

      if v.dead == true then
        love.graphics.draw(charImgs.img[v.actor.item.img], charImgs.quad[v.actor.item.img][v.dir][3][1], -cameraPos.x, -cameraPos.y) -- draw char
      elseif v.targetMode > 0 and v.move == false then
        local weapon = weapons[v.actor.item.weapon].img
        if v.dir == "l" or v.dir == "u" then
          love.graphics.draw(weaponImgs.img[weapon], weaponImgs.quad[weapon][v.dir][1][1], charImgs.info[v.actor.item.img].center[v.dir].x-weaponImgs.info[weapon].center[v.dir].x-cameraPos.x, charImgs.info[v.actor.item.img].center[v.dir].y-weaponImgs.info[weapon].center[v.dir].y-cameraPos.y)
        end
        love.graphics.draw(charImgs.img[v.actor.item.img], charImgs.quad[v.actor.item.img][v.dir][2][1], -cameraPos.x, -cameraPos.y) -- draw corpse
        if v.dir == "r" or v.dir == "d" then
          love.graphics.draw(weaponImgs.img[weapon], weaponImgs.quad[weapon][v.dir][1][1], charImgs.info[v.actor.item.img].center[v.dir].x-weaponImgs.info[weapon].center[v.dir].x-cameraPos.x, charImgs.info[v.actor.item.img].center[v.dir].y-weaponImgs.info[weapon].center[v.dir].y-cameraPos.y)
        end
      else
        love.graphics.draw(charImgs.img[v.actor.item.img], charImgs.quad[v.actor.item.img][v.dir][1][1], -cameraPos.x, -cameraPos.y) -- draw corpse
      end
      love.graphics.setCanvas(oldCanvas)
      love.graphics.setColor(255, 255, 255)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize*2-charImgs.width[v.actor.item.img]/2, y = math.floor(y)+tileSize/2, z= charImgs.height[v.actor.item.img]-tileSize}
    end
  end
end
