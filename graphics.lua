function graphics_load()
  w, h = love.graphics.getDimensions()

  tile = love.graphics.newImage("tile.png")
  wall = love.graphics.newImage("wall.png")
  cursor = love.graphics.newImage("cursor.png")
  door = love.graphics.newImage("door.png")
  tileSize = 16

  pathImg = love.graphics.newImage("path.png")
  pathQuad = createSpriteSheet(pathImg, 2, 3, 32, 16, 0, 0)

  scanBorderImg = love.graphics.newImage("scanborder.png")
  scanBorderQuad = createSpriteSheet(scanBorderImg, 4, 5, 32, 16, 0, 0)

  scanIconImg = love.graphics.newImage("scanicons.png")
  scanIconQuad = createSpriteSheet(scanIconImg, 5, 1, 32, 16, 0, 0)
end


function createSpriteSheet(a, b, c, d, e, f, g)
local spriteSheet = {}
for i = 1, c do
  for k = 1, b do
    spriteSheet[#spriteSheet + 1] = love.graphics.newQuad(f + (k - 1) * d, g + (i - 1) * e, d, e, a:getDimensions())
  end
end
return spriteSheet
end

--pathQuad = createSpriteSheet(pathImg, 2, 3, 32, 16, 0, 0)

function bitmaskFromMap(room, tX, tY, roomMap, tile)
  local map = copy(roomMap)
  for i, v in ipairs(levels[currentLevel].doors) do -- makes floors with doors on them not count towards bitmasking
    if v.room1 == room then
      map[v.tY1][v.tX1] = 0
    elseif v.room2 == room then
      map[v.tY2][v.tX2] = 0
    end
  end

  for i, v in ipairs(levels[currentLevel].hazards) do -- makes floors with hazards on them not count towards bitmasking
    if v.room == room then
      map[v.tY][v.tX] = 0
    end
  end

  local value = 1
  if tX > 1 and tileType[map[tY][tX-1]] == tile then
    value = value + 2
  end
  if tX < #map[tY] and tileType[map[tY][tX+1]] == tile then
      value = value + 4
  end
  if tY > 1 and tileType[map[tY-1][tX]] == tile then
    value = value + 1
  end
  if tY < #map and tileType[map[tY+1][tX]] == tile then
    value = value + 8
  end
  return value
end

function bitmaskFromDoors(room, tX, tY)
  local value = 1
  for i, v in ipairs(levels[currentLevel].doors) do
    if v.room1 == room then
      if v.tX1 - tX == -1 and v.tY1 == tY then
        value = value + 2
      end
      if v.tX1 - tX == 1 and v.tY1 == tY then
        value = value + 4
      end
      if v.tY1 - tY == -1 and v.tX1 == tX then
        value = value + 1
      end
      if v.tY1 - tY == 1 and v.tX1 == tX then
        value = value + 8
      end
    elseif v.room2 == room then
      if v.tX2 - tX == -1 and v.tY2 == tY then
        value = value + 2
      end
      if v.tX2 - tX == 1 and v.tY2 == tY then
        value = value + 4
      end
      if v.tY2 - tY == -1 and v.tX2 == tX then
        value = value + 1
      end
      if v.tY2 - tY == 1 and v.tX2 == tX then
        value = value + 8
      end
    end
  end
  return value
end

function bitmaskFromHazards(room, tX, tY)
  local value = 1
  for i, v in ipairs(levels[currentLevel].hazards) do
    if v.room == room then
      if v.tX - tX == -1 and v.tY == tY then
        value = value + 2
      end
      if v.tX - tX == 1 and v.tY == tY then
        value = value + 4
      end
      if v.tY - tY == -1 and v.tX == tX then
        value = value + 1
      end
      if v.tY - tY == 1 and v.tX == tX then
        value = value + 8
      end
    end
  end
  return value
end
