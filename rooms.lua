function rooms_load()
  rooms = {}
  rooms[1] = {{2, 1, 2, 1, 1, 1},
              {2, 1, 2, 1, 1, 1},
              {2, 1, 1, 3, 3, 1},
              {2, 1, 1, 1, 1, 1},
              {2, 1, 1, 2, 1, 1},
              {2, 1, 2, 2, 1, 1}}
  rooms[2] = {{1, 2, 1, 1, 1, 0},
              {1, 2, 1, 1, 1, 0},
              {1, 2, 1, 1, 1, 0},
              {1, 1, 1, 0, 0, 0},
              {1, 3, 1, 0, 0, 0},
              {1, 3, 1, 1, 1, 1}}
  tileType = {[0] = 0, [1] = 1, [2] = 2, [3] = 3}
  floors = {}
  roomNodes = {}

  drawQueue = {}
end

function rooms_draw()
  if scanning == false then
    drawRoom()
  else
    drawScannedRoom()
  end

  mouse_draw()
  love.graphics.setColor(255, 255, 255)
end

function drawRoom()
  love.graphics.draw(floors[currentRoom]) -- floor is drawn first so it will be at the bottom
  setValidColor(currentActor.path.valid) -- sets color of path indicator
  if currentActor.mode == 0 then
    drawPath(currentActor) -- draws path indicator
  end

  drawQueue = {} -- reset queue
  queueWalls(currentRoom)
  queueCover(currentRoom)
  queueHazards(currentRoom)
  queueChars(currentRoom)
  queueEnemyChars(currentRoom)
  queueParticles(currentRoom)
  table.sort(drawQueue, function(a, b) return a.y < b.y end) -- sort queue to ensure proper layering
  drawItemsInQueue() -- draw items in queue
end

function drawItemsInQueue()
  for i, v in ipairs(drawQueue) do
    if v.r ~= nil and v.g ~= nil and v.b ~= nil then -- set the color if a color is given
      love.graphics.setColor(v.r, v.g, v.b)
    else
      love.graphics.setColor(255, 255, 255)
    end

    if v.type == "particle" then
      local x, y, w, h = v.quad:getViewport()
      love.graphics.draw(v.img, v.quad, v.x, v.y-v.z, v.dir, 1, 1, w/2, h/2)
    else
      love.graphics.draw(v.img, v.x, v.y-v.z)
    end
  end
  love.graphics.setColor(225, 255, 255)
end

function queueWalls(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[rooms[room][i][j]] == 2 then
        local x, y = tileToIso(j, i)
        drawQueue[#drawQueue + 1] = {type = "wall", img = wallImg, x = x, y = y, z= wallImg:getHeight()-tileSize}
      end
    end
  end
end

function queueCover(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[rooms[room][i][j]] == 3 then
        local x, y = tileToIso(j, i)
        drawQueue[#drawQueue + 1] = {type = "cover", img = coverImg, x = x, y = y, z= coverImg:getHeight()-tileSize}
      end
    end
  end
end

function startRoom(room)
  if floors[room] == nil then
    floors[room] = drawFloor(room)
  end
  if scanFloors[room] == nil then
    scanFloors[room] = drawScanFloor(room)
  end
  roomNodes = createIsoNodes(room)
end

function drawFloor(room)
  local floor = love.graphics.newCanvas((#rooms[room][1]+1)*tileSize*2, (#rooms[room]+1)*tileSize)
  love.graphics.setCanvas(floor)
  love.graphics.clear()
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        love.graphics.setColor(155, 155, 155)
        love.graphics.draw(tileImg, tileToIso(j, i))
      end
    end
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.setCanvas()
  return floor
end

function createIsoNodes(room)
  roomNodes = {}
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        local x, y = tileToIso(j, i)
        roomNodes[#roomNodes + 1] = {tX = j, tY = i, x = x + tileSize, y = y + tileSize/2}
      end
    end
  end
  return roomNodes
end
