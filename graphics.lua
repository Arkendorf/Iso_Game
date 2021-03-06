function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  screen = {}
  screen.scale = 2
  screen.w = love.graphics.getWidth() / screen.scale
  screen.h = love.graphics.getHeight() / screen.scale

  font = love.graphics.newImageFont("font.png",
  " abcdefghijklmnopqrstuvwxyz" ..
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
  "123456789.,!?-+/():;%&`'*#=[]\"", 1)
  love.graphics.setFont(font)

  buttonFont = love.graphics.newImageFont("buttonfont.png","1234567890")

  smallFont = love.graphics.newImageFont("smallfont.png","1234567890.-", 1)

  cursorImg = love.graphics.newImage("cursor.png")
  targetImg = love.graphics.newImage("target.png")
  tileSize = 16

  tiles = {}
  tiles.img, tiles.width, tiles.height, tiles.quad, tiles.info = loadFolder("tiles")
  tileTypeImg = love.graphics.newImage("tileindicator.png")

  finishImg = love.graphics.newImage("finish.png")
  finishQuad = createSpriteSheet(finishImg, 3, 3, 32, 16)

  hazardTiles = {}
  hazardTiles.img, hazardTiles.width, hazardTiles.height, hazardTiles.quad, hazardTiles.info = loadFolder("hazards")

  doorTiles = {}
  doorTiles.img, doorTiles.width, doorTiles.height, doorTiles.quad, doorTiles.info = loadFolder("doors")

  particleImgs = {}
  particleImgs.img, particleImgs.width, particleImgs.height, particleImgs.quad, particleImgs.info = loadFolder("particles")

  charImgs = {}
  charImgs.img, charImgs.width, charImgs.height, charImgs.quad, charImgs.info = loadFolder2("chars")

  weaponImgs = {}
  weaponImgs.img, weaponImgs.width, weaponImgs.height, weaponImgs.quad, weaponImgs.info = loadFolder2("weapons")

  projectileImgs = {}
  projectileImgs.img, projectileImgs.width,projectileImgs.height, projectileImgs.quad, projectileImgs.info = loadFolder("projectiles")

  pathImg = love.graphics.newImage("path.png")
  pathQuad = createSpriteSheet(pathImg, 2, 3, 32, 16)

  enemyIcon = {}
  enemyIcon.img = love.graphics.newImage("enemyicon.png")
  enemyIcon.quad = createSpriteSheet(enemyIcon.img, 3, 1, 8, 8)

  combatButtonImg = love.graphics.newImage("combatbuttons.png")
  combatButtonQuad = createSpriteSheet(combatButtonImg, 4, 1, 44, 24)

  combatIconImg = love.graphics.newImage("buttonicons.png")
  combatIconOnQuad = createSpriteSheet(combatIconImg, 1, 4, 44, 24)
  combatIconOffQuad = createSpriteSheet(combatIconImg, 1, 4, 44, 24, 44, 0)

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
end


function createSpriteSheet(a, b, c, d, e, f, g) -- image, tiles across, tiles down, tile width, tile height, x offset, y offset
if not f then
  f = 0
end
if not g then
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

function loadFolder(folder)
  local imageList = {}
  local widthList = {}
  local heightList = {}
  local quadList = {}
  local infoList = {}

  local i = 1
  while true do
    if love.filesystem.isFile(folder.."/"..tostring(i)..".png") == true then
      imageList[i] = love.graphics.newImage(folder.."/"..tostring(i)..".png")
      heightList[i] = imageList[i]:getHeight()
      if love.filesystem.isFile(folder.."/"..tostring(i)..".txt") == true then
        infoList[i] = love.filesystem.load(folder.."/"..tostring(i)..".txt")()
        widthList[i] = infoList[i].w
        local frames = math.floor(imageList[i]:getWidth()/widthList[i])
        quadList[i] = createSpriteSheet(imageList[i], frames, 1, widthList[i], heightList[i])
        infoList[i].frame = 1
        infoList[i].maxFrame = frames
      else
        widthList[i] = imageList[i]:getWidth()
      end
      i = i + 1
    else
      break
    end
  end
  return imageList, widthList, heightList, quadList, infoList
end

function loadFolder2(folder)
  local imageList = {}
  local widthList = {}
  local heightList = {}
  local quadList = {}
  local infoList = {}

  local i = 1
  while true do
    if love.filesystem.isFile(folder.."/"..tostring(i)..".png") == true then
      imageList[i] = love.graphics.newImage(folder.."/"..tostring(i)..".png")
      if love.filesystem.isFile(folder.."/"..tostring(i)..".txt") == true then
        infoList[i] = love.filesystem.load(folder.."/"..tostring(i)..".txt")()

        quadList[i] = {u = {}, d = {}, l = {}, r = {}}
        widthList[i] = infoList[i].w
        local frames = math.floor(imageList[i]:getWidth()/widthList[i]/4)
        heightList[i] = infoList[i].h
        local animations = math.floor(imageList[i]:getHeight()/heightList[i])

        for j = 1, animations do
          quadList[i].u[j] = createSpriteSheet(imageList[i], frames, 1, widthList[i], heightList[i], imageList[i]:getWidth()/4*3, (j-1)*heightList[i])
        end
        for j = 1, animations do
          quadList[i].d[j] = createSpriteSheet(imageList[i], frames, 1, widthList[i], heightList[i], imageList[i]:getWidth()/4*2, (j-1)*heightList[i])
        end
        for j = 1, animations do
          quadList[i].l[j] = createSpriteSheet(imageList[i], frames, 1, widthList[i], heightList[i], imageList[i]:getWidth()/4, (j-1)*heightList[i])
        end
        for j = 1, animations do
          quadList[i].r[j] = createSpriteSheet(imageList[i], frames, 1, widthList[i], heightList[i], 0, (j-1)*heightList[i])
        end
      else
        heightList[i] = imageList[i]:getHeight()
        widthList[i] = imageList[i]:getWidth()
      end
      i = i + 1
    else
      break
    end
  end
  return imageList, widthList, heightList, quadList, infoList
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
