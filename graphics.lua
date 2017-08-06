function graphics_load()
  w, h = love.graphics.getDimensions()

  tile = love.graphics.newImage("tile.png")
  wall = love.graphics.newImage("wall.png")
  cursor = love.graphics.newImage("cursor.png")
  door = love.graphics.newImage("door.png")
  tileSize = 16

  pathImg = love.graphics.newImage("path.png")
  pathQuad = createSpriteSheet(pathImg, 2, 3, 32, 16, 0, 0)

  scanFloorImg = love.graphics.newImage("scanfloor.png")
  scanFloorQuad = createSpriteSheet(scanFloorImg, 4, 4, 32, 16, 0, 0)

  scanDoorImg = love.graphics.newImage("scandoor.png")
  scanDoorQuad = createSpriteSheet(scanDoorImg, 4, 4, 32, 16, 0, 0)

  scanWallImg = love.graphics.newImage("scanwall.png")
  scanWallQuad = createSpriteSheet(scanWallImg, 4, 4, 32, 16, 0, 0)

  scanCoverImg = love.graphics.newImage("scancover.png")
  scanCoverQuad = createSpriteSheet(scanCoverImg, 4, 4, 32, 16, 0, 0)

  scanHazardImg = love.graphics.newImage("scanhazard.png")
  scanHazardQuad = createSpriteSheet(scanHazardImg, 4, 4, 32, 16, 0, 0)
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

function bitmaskFromMap(tX, tY, map, tile)
  local value = 1
  if tX > 1 then
    if map[tY][tX-1] == tile then
      value = value + 2
    end
  end
  if tX < #map[tY] then
    if map[tY][tX+1] == tile then
      value = value + 4
    end
  end
  if tY > 1 then
    if map[tY-1][tX] == tile then
      value = value + 1
    end
  end
  if tY < #map then
    if map[tY+1][tX] == tile then
      value = value + 8
    end
  end
  return value
end
