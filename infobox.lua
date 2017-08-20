
function infobox_load()
  infoboxes = {{x = 0, y = 0, w = 32+font:getWidth(text[1]), h = 16, str = text[6]}, {x =0, y = 16, w = 32+font:getWidth(text[2]), h = 16, str = text[7]}, {x = 0, y = 32, w = 32+font:getWidth(text[3]), h = 16, str = text[8]}, {x = 0, y = 48, w = 32+font:getWidth(text[4]), h = 16, str = text[9]}, {x = 0, y = 64, w = 32+font:getWidth(text[5]), h = 16, str = text[10]}}
  for i, v in ipairs(infoboxes) do
    v.canvas = drawInfoBox(v.str)
  end
  currentInfoBox = {box = infoboxes[1], anim = 0}
end

function createInfoBox(x, y, w, h, str)
  infoboxes[#infoboxes + 1] = {x = x, y = y, w = w, h = h, str = str, canvas = drawInfoBox(str)}
  return #infoboxes
end

function deleteInfoBox(num)
  table.remove(infoboxes, num)
end

function infobox_update(dt)
  if mouse.x >= currentInfoBox.box.x and mouse.x <= currentInfoBox.box.x + currentInfoBox.box.w and mouse.y >= currentInfoBox.box.y and mouse.y <= currentInfoBox.box.y + currentInfoBox.box.h then
    if currentInfoBox.anim < 1 then
      currentInfoBox.anim = currentInfoBox.anim + dt
    elseif currentInfoBox.anim > 1 then
      currentInfoBox.anim = 1
    end
  else
    if currentInfoBox.anim > 0 then
      currentInfoBox.anim = currentInfoBox.anim - dt *2
    elseif currentInfoBox.anim < 0 then
      currentInfoBox.anim = 0
    end
  end

  for i, v in ipairs(infoboxes) do
    if mouse.x >= v.x and mouse.x <= v.x + v.w and mouse.y >= v.y and mouse.y <= v.y + v.h then
      currentInfoBox.box = v
    end
  end
end

function infobox_draw()
  love.graphics.setColor(255, 255, 255, currentInfoBox.anim*255)
  local x, y = mouse.x+12, mouse.y+12
  if x+currentInfoBox.box.canvas:getWidth() > screen.w then
    x = screen.w-currentInfoBox.box.canvas:getWidth()
  end
  if y+currentInfoBox.box.canvas:getHeight() > screen.h then
    y = screen.h-currentInfoBox.box.canvas:getHeight()
  end

  love.graphics.draw(currentInfoBox.box.canvas, math.floor(x), math.floor(y))
  love.graphics.setColor(255, 255, 255, 255)
end

function drawInfoBox(str)
  local preferredWidth = screen.w/4
  local __, lines = font:getWrap(str, preferredWidth)

  local infoBox, oldCanvas = startNewCanvas(preferredWidth+4, #lines * 10+5)
  love.graphics.setCanvas(infoBox)
  love.graphics.clear()

  local width = 0
  for i, v in ipairs(lines) do
    local newWidth = font:getWidth(v)
    if string.sub(v, -1, -1) == " " then
      newWidth = newWidth - font:getWidth(" ")
    end
    if newWidth > width then
      width = newWidth
    end
  end
  love.graphics.draw(drawBox(width+1, font:getHeight()*#lines+1, 1))
  love.graphics.printf(str, 3, 3, width, "left")

  love.graphics.setCanvas(oldCanvas)
  return infoBox
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
