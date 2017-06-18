function rooms_load()
  rooms = {}
  rooms[1] = {{1, 0, 0, 1, 0, 0},
              {1, 0, 0, 1, 0, 0},
              {1, 0, 0, 1, 0, 0},
              {1, 0, 0, 0, 0, 0},
              {1, 0, 0, 1, 0, 0},
              {1, 0, 1, 1, 0, 0}}
  rooms[2] = {{0, 0, 0, 0, 0, 0},
              {0, 0, 0, 0, 0, 0},
              {0, 0, 0, 0, 0, 0},
              {0, 0, 0, 0, 0, 0},
              {0, 0, 0, 0, 0, 0},
              {0, 0, 0, 0, 0, 0}}
  tileType = {[0] = 0, [1] = 1}
  floors = {}
  roomNodes = {}
end

function rooms_draw()
  -- floor is drawn first so it will be at the bottom
  love.graphics.draw(floors[currentRoom])

  drawPath(currentActor)

  --the walls are then drawn
  drawWalls()

end

function drawWalls()
  local x = 0
  local y = 0
  for i = 1, #rooms[currentRoom] + #rooms[currentRoom][1] - 1 do
    if i <= #rooms[currentRoom] then
      x = 1
      y = i
    else
      x = i - #rooms[currentRoom] + 1
      y = #rooms[currentRoom]
    end
    while x <= #rooms[currentRoom][1] and y >= 1 do
      if tileType[rooms[currentRoom][y][x]] == 1 then
        love.graphics.setColor(255, 255, 255)
        local tX, tY = tileToIso(x-1, y-1)
        love.graphics.draw(wall, tX, tY - wall:getHeight()+tileSize)
      end
      x = x + 1
      y = y - 1
    end
    drawAChar((i-1)*tileSize/2,i*tileSize/2)
  end
end

function tileToIso(x, y)
  return (x-y+#rooms[currentRoom]-1)*tileSize, (y+x)*tileSize/2
end

function startRoom(room)
  if floors[room] == nil then
    floors[room] = drawFloor(room)
  end
  roomNodes = createIsoNodes(room)
end

function drawFloor(room)
  local floor = love.graphics.newCanvas((#rooms[room][1]+1)*tileSize*2, (#rooms[room]+1)*tileSize)
  love.graphics.setCanvas(floor)
  love.graphics.clear()
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 0 then
        love.graphics.setColor(155, 155, 155)
        love.graphics.draw(tile, tileToIso(j-1, i-1))
      end
    end
  end
  love.graphics.setCanvas()
  return floor
end

function createIsoNodes(room)
  roomNodes = {}
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 0 then
        local tX, tY = tileToIso(j-1, i-1)
        roomNodes[#roomNodes + 1] = {tX = j, tY = i, x = tX + tileSize, y = tY + tileSize/2}
      end
    end
  end
  return roomNodes
end
