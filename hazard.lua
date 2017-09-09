function hazard_load()
  hazards = {}
  hazards[1] = {img = hazardImg, func = 1, drawType = 1}
end


function queueHazards(room)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and hazards[v.type].drawType == 2 then
      local x, y = tileToIso(v.tX, v.tY)
      drawQueue[#drawQueue + 1] = {type = 1, img = hazards[v.type].img, quad = hazards[v.type].quad, x = x+tileSize, y = y+tileSize/2, z= hazards[v.type].img:getHeight()-tileSize}
    end
  end
end

function drawFlatHazards(room)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and hazards[v.type].drawType == 1 then
      local x, y = tileToIso(v.tX, v.tY)
      if hazards[v.type].quad == nil then
        love.graphics.draw(hazards[v.type].img, x, y)
      else
        love.graphics.draw(hazards[v.type].img, hazards[v.type].quad, x, y)
      end
    end
  end
end
