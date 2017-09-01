function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  screen = {}
  screen.scale = 2
  screen.w = love.graphics.getWidth() / screen.scale
  screen.h = love.graphics.getHeight() / screen.scale
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
  targetImg = love.graphics.newImage("target.png")
  tileSize = 16

  pathImg = love.graphics.newImage("path.png")
  pathQuad = createSpriteSheet(pathImg, 2, 3, 32, 16)

  scanBorderImg = love.graphics.newImage("scanborder.png")
  scanBorderQuad = createSpriteSheet(scanBorderImg, 4, 5, 32, 16)

  scanIconImg = love.graphics.newImage("scanicons.png")
  scanIconQuad = createSpriteSheet(scanIconImg, 5, 1, 32, 16)

  spottedImg = love.graphics.newImage("statuseffecticons.png")

  combatButtonImg = love.graphics.newImage("combatbuttons.png")
  combatButtonQuad = createSpriteSheet(combatButtonImg, 2, 5, 44, 24)

  boxImg = love.graphics.newImage("box.png")
  boxQuad = {{}, {}, {}, {}}
  for i, v in ipairs(boxQuad) do
    v.topLeft = love.graphics.newQuad(0+(i-1)*32, 0, 3, 3, boxImg:getDimensions())
    v.topRight = love.graphics.newQuad(3+(i-1)*32, 0, 3, 3, boxImg:getDimensions())
    v.bottomLeft = love.graphics.newQuad(0+(i-1)*32, 3, 3, 3, boxImg:getDimensions())
    v.bottomRight = love.graphics.newQuad(3+(i-1)*32, 3, 3, 3, boxImg:getDimensions())
    v.top = love.graphics.newQuad(6+(i-1)*32, 0, 26, 3, boxImg:getDimensions())
    v.bottom = love.graphics.newQuad(6+(i-1)*32, 3, 26, 3, boxImg:getDimensions())
    v.left = love.graphics.newQuad(0+(i-1)*32, 6, 3, 26, boxImg:getDimensions())
    v.right = love.graphics.newQuad(3+(i-1)*32, 6, 3, 26, boxImg:getDimensions())
    v.pattern = love.graphics.newQuad(6+(i-1)*32, 6, 20, 20, boxImg:getDimensions())
  end

  playerHudBoxImg = drawBox(216, 21, 2)

  mapBoxImg = drawBox(66, 66, 2)

  muzzleFlashImg = love.graphics.newImage("muzzleflash.png")
  muzzleFlashQuad = createSpriteSheet(muzzleFlashImg, 3, 1, 16, 16)

  bloodImg = love.graphics.newImage("blood.png")
  bloodQuad = createSpriteSheet(bloodImg, 3, 1, 16, 16)

  laserImg = love.graphics.newImage("laser.png")
end


function createSpriteSheet(a, b, c, d, e, f, g) -- image, tiles across, tiles down, tile width, tile height, x offset, y offset
if f == nil then
  f = 0
end
if g == nil then
  g = 0
end
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
  for i, v in ipairs(currentLevel.doors) do -- makes floors with doors on them not count towards bitmasking
    if v.room1 == room then
      map[v.tY1][v.tX1] = 0
    elseif v.room2 == room then
      map[v.tY2][v.tX2] = 0
    end
  end

  for i, v in ipairs(currentLevel.hazards) do -- makes floors with hazards on them not count towards bitmasking
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
  for i, v in ipairs(currentLevel.doors) do
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
  for i, v in ipairs(currentLevel.hazards) do
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

function drawBox(width, height, type)
  local box, oldCanvas = startNewCanvas(width+4, height+4)

  local layer1 = startNewCanvas(width+2, height+2)
  for down = 0, math.ceil(height/20)-1 do
    for across = 0, math.ceil(width/20)-1 do
      love.graphics.draw(boxImg, boxQuad[type].pattern, 2 + across * 20, 2 + down * 20)
      if down == 0 then
        love.graphics.draw(boxImg, boxQuad[type].top, 2+across * 20, 0)
      end
    end
    love.graphics.draw(boxImg, boxQuad[type].left, 0, 2 + down * 20)
  end
  love.graphics.draw(boxImg, boxQuad[type].topLeft)

  local layer2 = startNewCanvas(width+2, height+2)
  for across = 0, math.ceil(width/20)-1 do
    love.graphics.draw(boxImg, boxQuad[type].bottom, width-across*20-26, height-1)
  end
  for down = 0, math.ceil(height/20)-1 do
    love.graphics.draw(boxImg, boxQuad[type].right, width-1, height-down*20-26)
  end
  love.graphics.draw(boxImg, boxQuad[type].bottomRight, width-1, height-1)

  love.graphics.setCanvas(box)
  love.graphics.draw(layer1, 0, 0)
  love.graphics.draw(layer2, 2, 2)
  love.graphics.draw(boxImg, boxQuad[type].topRight, width+1, 0)
  love.graphics.draw(boxImg, boxQuad[type].bottomLeft, 0, height+1)

  love.graphics.setCanvas(oldCanvas)
  return box
end
