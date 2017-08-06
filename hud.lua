function hud_load()
end

function hud_update(dt)
end

function hud_draw()
  if scanFlicker[1] == 0 then -- yellow bits
    love.graphics.setColor(palette.yellow)
  else
    love.graphics.setColor(palette.yellow[1]/2, palette.yellow[2]/2, palette.yellow[3]/2)
  end
  love.graphics.draw(scanIconImg, scanIconQuad[1])
  love.graphics.print(text[1], 32, 0)

  if scanFlicker[2] == 0 then -- blue bits
    love.graphics.setColor(palette.blue)
  else
    love.graphics.setColor(palette.blue[1]/2, palette.blue[2]/2, palette.blue[3]/2)
  end
  love.graphics.draw(scanIconImg, scanIconQuad[2], 0, 16)
  love.graphics.print(text[2], 32, 16)

  if scanFlicker[3] == 0 then -- cyan bits
    love.graphics.setColor(palette.cyan)
  else
    love.graphics.setColor(palette.cyan[1]/2, palette.cyan[2]/2, palette.cyan[3]/2)
  end
  love.graphics.draw(scanIconImg, scanIconQuad[3], 0, 32)
  love.graphics.print(text[3], 32, 32)

  if scanFlicker[4] == 0 then -- purple bits
    love.graphics.setColor(palette.purple)
  else
    love.graphics.setColor(palette.purple[1]/2, palette.purple[2]/2, palette.purple[3]/2)
  end
  love.graphics.draw(scanIconImg, scanIconQuad[4], 0, 48)
  love.graphics.print(text[4], 32, 48)

  if scanFlicker[5] == 0 then -- red bits
    love.graphics.setColor(palette.red)
  else
    love.graphics.setColor(palette.red[1]/2, palette.red[2]/2, palette.red[3]/2)
  end
  love.graphics.draw(scanIconImg, scanIconQuad[5], 0, 64)
  love.graphics.print(text[5], 32, 64)

  love.graphics.setColor(255, 255, 255)
end
