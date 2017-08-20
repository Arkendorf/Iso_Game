function drawInfoBox(str)
  local width = math.ceil(screen.w/40)*10
  local __, lines = font:getWrap(str, width)
  local borderW = 2
  local infoBox = love.graphics.newCanvas(width+borderW*2, #lines * 10+borderW*2)
  love.graphics.setCanvas(infoBox)
  love.graphics.clear()
  for i, v in ipairs(lines) do
    if i == 1 then
      love.graphics.draw(infoBoxImg, infoBoxQuad[1], 0, (i-1) * 10)
      for j = 1, math.ceil((width-24)/10) do
        love.graphics.draw(infoBoxImg, infoBoxQuad[2], j * 10+borderW, (i-1) * 10)
      end
      love.graphics.draw(infoBoxImg, infoBoxQuad[3], width-10+borderW, (i-1) * 10)
    elseif i == #lines then
      love.graphics.draw(infoBoxImg, infoBoxQuad[7], 0, (i-1) * 10+borderW)
      for j = 1, math.ceil((width-24)/10) do
        love.graphics.draw(infoBoxImg, infoBoxQuad[8], j * 10+borderW, (i-1) * 10+borderW)
      end
      love.graphics.draw(infoBoxImg, infoBoxQuad[9], width-10+borderW, (i-1) * 10+borderW)
    else
      love.graphics.draw(infoBoxImg, infoBoxQuad[4], 0, (i-1) * 10+borderW)
      for j = 1, math.ceil((width-24)/10) do
        love.graphics.draw(infoBoxImg, infoBoxQuad[5], j * 10+borderW, (i-1) * 10+borderW)
      end
      love.graphics.draw(infoBoxImg, infoBoxQuad[6], width-10+borderW, (i-1) * 10+borderW)
    end
    if #lines == 1 then -- complete border if there is only one line of text
      love.graphics.draw(infoBoxImg, infoBoxQuad[10], 0, 12)
      for j = 1, math.ceil((width-24)/10) do
        love.graphics.draw(infoBoxImg, infoBoxQuad[11], j * 10+borderW, 12)
      end
      love.graphics.draw(infoBoxImg, infoBoxQuad[12], width-10+borderW, 12)
    end

    love.graphics.setColor(palette.cyan)
    love.graphics.print(v, borderW+1, (i-1) * 10+3)
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.setCanvas()
  return infoBox
end

function getWrapSize(str, limit)
  local width, lines = font:getWrap(str, limit)
  return #lines * font:getHeight()
end

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
