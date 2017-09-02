


function map_load()
  map = {x = 1, y = 1, w = 64, h = 64}
  map.canvas = love.graphics.newCanvas(map.w, map.h)
  mapTileSize = 8

  mapBoxImg = drawBox(map.w+2, map.h+2+font:getHeight()*5, 2)

  mapInfoBoxes = {}
  mapInfoBoxes[1] = createInfoBox(map.x+3, map.y+map.h+6, font:getWidth(text[1]), font:getHeight(), text[6])
  mapInfoBoxes[2] = createInfoBox(map.x+3, map.y+map.h+6+font:getHeight(), font:getWidth(text[2]), font:getHeight(), text[7])
  mapInfoBoxes[3] = createInfoBox(map.x+3, map.y+map.h+6+font:getHeight()*2, font:getWidth(text[3]), font:getHeight(), text[8])
  mapInfoBoxes[4] = createInfoBox(map.x+3, map.y+map.h+6+font:getHeight()*3, font:getWidth(text[4]), font:getHeight(), text[9])
  mapInfoBoxes[5] = createInfoBox(map.x+3, map.y+map.h+6+font:getHeight()*4, font:getWidth(text[5]), font:getHeight(), text[10])
end

function drawMapTiles(room, size) -- what room to draw, size of tiles
  --tiles
  local map = rooms[room]
  for i, v in ipairs(map) do
    for j, k in ipairs(v) do
      if tileType[k] ~= 0 then
        if tileType[k] == 1 then
          love.graphics.setColor(palette.yellow)
        elseif tileType[k] == 2 then
          love.graphics.setColor(palette.blue)
        elseif tileType[k] == 3 then
          love.graphics.setColor(palette.cyan)
        end
        love.graphics.rectangle("fill", (j-1)*size, (i-1)*size, size-1, size-1)
        love.graphics.setColor(255, 255, 255)
      end
    end
  end

  --doors and hazards
  for i, v in ipairs(currentLevel.doors) do
    if v.room1 == room then
      love.graphics.setColor(palette.purple)
      love.graphics.rectangle("fill", (v.tX1-1)*size, (v.tY1-1)*size, size-1, size-1)
      love.graphics.setColor(255, 255, 255)
    elseif v.room2 == room then
      love.graphics.setColor(palette.purple)
      love.graphics.rectangle("fill", (v.tX2-1)*size, (v.tY2-1)*size, size-1, size-1)
      love.graphics.setColor(255, 255, 255)
    end
  end
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room then
      love.graphics.setColor(palette.red)
      love.graphics.rectangle("fill", (v.tX-1)*size, (v.tY-1)*size, size-1, size-1)
      love.graphics.setColor(255, 255, 255)
    end
  end

  --players and enemies
  for i, v in ipairs(currentLevel.actors) do
    if v.room == room and v.dead == false then
      love.graphics.setColor(palette.green)
      love.graphics.rectangle("fill", math.floor((v.x/tileSize)*size), math.floor((v.y/tileSize)*size), size-1, size-1)
      love.graphics.setColor(255, 255, 255)
    end
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.room == room and v.dead == false then
      love.graphics.setColor(palette.red)
      love.graphics.rectangle("fill", math.floor((v.x/tileSize)*size), math.floor((v.y/tileSize)*size), size-1, size-1)
      love.graphics.setColor(255, 255, 255)
    end
  end
end

function drawMap(x, y)
  local canvas, oldCanvas = resumeCanvas(map.canvas)
  love.graphics.push()

  love.graphics.translate(math.floor((map.w-currentActor.x-mapTileSize)/2), math.floor((map.h-currentActor.y-mapTileSize)/2))
  drawMapTiles(currentRoom, mapTileSize)
  love.graphics.pop()

  love.graphics.setCanvas(oldCanvas)

  love.graphics.draw(mapBoxImg, x, y)
  love.graphics.draw(map.canvas, x+3, y+3)

  -- key
  love.graphics.setColor(palette.yellow)
  love.graphics.print(text[1], 4, map.h+6)

  love.graphics.setColor(palette.blue)
  love.graphics.print(text[2], 4, map.h+6+font:getHeight())

  love.graphics.setColor(palette.cyan)
  love.graphics.print(text[3], 4, map.h+6+font:getHeight()*2)

  love.graphics.setColor(palette.purple)
  love.graphics.print(text[4], 4, map.h+6+font:getHeight()*3)

  love.graphics.setColor(palette.red)
  love.graphics.print(text[5], 4, map.h+6+font:getHeight()*4)
  love.graphics.setColor(255, 255, 255)
end
