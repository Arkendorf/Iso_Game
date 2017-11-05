
function infobox_load()
  infoboxes = {}
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
  if currentInfoBox.box and mouse.x >= currentInfoBox.box.x and mouse.x <= currentInfoBox.box.x + currentInfoBox.box.w and mouse.y >= currentInfoBox.box.y and mouse.y <= currentInfoBox.box.y + currentInfoBox.box.h then
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
  if currentInfoBox.box then
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
end

function drawInfoBox(str)
  local preferredWidth = screen.w/4
  local __, lines = font:getWrap(str, preferredWidth)

  local infoBox, oldCanvas = startNewCanvas(preferredWidth+4, #lines * 10+5)

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
  love.graphics.setColor(100, 100, 100)
  love.graphics.printf(str, 3, 3, width, "left")
  love.graphics.setColor(255, 255, 255)

  love.graphics.setCanvas(oldCanvas)
  return infoBox
end
