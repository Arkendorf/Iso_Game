function graphics_load()
  screen = {}
  screen.w, screen.h = love.graphics.getDimensions()
  --font = love.graphics.newFont(12)
  font = love.graphics.newImageFont("font.png",
  " abcdefghijklmnopqrstuvwxyz" ..
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
  "123456789.,!?-+/():;%&`'*#=[]\"", 1)
  love.graphics.setFont(font)

  tileImg = love.graphics.newImage("tile.png")
  wallImg = love.graphics.newImage("wall.png")
  coverImg = love.graphics.newImage("cover.png")
  hazardImg = love.graphics.newImage("hazard.png")
  cursorImg = love.graphics.newImage("cursor.png")
  tileSize = 16

  pathImg = love.graphics.newImage("path.png")
  pathQuad = createSpriteSheet(pathImg, 2, 3, 32, 16, 0, 0)

  scanBorderImg = love.graphics.newImage("scanborder.png")
  scanBorderQuad = createSpriteSheet(scanBorderImg, 4, 5, 32, 16, 0, 0)

  scanIconImg = love.graphics.newImage("scanicons.png")
  scanIconQuad = createSpriteSheet(scanIconImg, 5, 1, 32, 16, 0, 0)

  infoBoxImg = love.graphics.newImage("infobox.png")
  infoBoxQuad = {love.graphics.newQuad(0, 0, 12, 12, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(12, 0, 10, 12, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(22, 0, 12, 12, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(0, 12, 12, 10, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(12, 12, 10, 10, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(22, 12, 12, 10, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(0, 22, 12, 12, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(12, 22, 10, 12, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(22, 22, 12, 12, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(0, 32, 12, 2, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(12, 32, 10, 2, infoBoxImg:getDimensions()),
                 love.graphics.newQuad(22, 32, 12, 2, infoBoxImg:getDimensions())}

  statusEffectImg = love.graphics.newImage("statuseffecticons.png")
  statusEffectQuad = createSpriteSheet(statusEffectImg, 3, 1, 20, 20, 0, 0)
end


function createSpriteSheet(a, b, c, d, e, f, g) -- tiles across, tiles down, tile width, tile height, x offset, y offset
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
