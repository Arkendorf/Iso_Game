function hud_load()
end

function hud_update(dt)
end

function hud_draw()
  love.graphics.setColor(palette.yellow)
  love.graphics.draw(scanIconImg, scanIconQuad[1])
  love.graphics.print(text[1], 32, 0+4)

  love.graphics.setColor(palette.blue)
  love.graphics.draw(scanIconImg, scanIconQuad[2], 0, 16)
  love.graphics.print(text[2], 32, 16+4)

  love.graphics.setColor(palette.cyan)
  love.graphics.draw(scanIconImg, scanIconQuad[3], 0, 32)
  love.graphics.print(text[3], 32, 32+4)

  love.graphics.setColor(palette.purple)
  love.graphics.draw(scanIconImg, scanIconQuad[4], 0, 48)
  love.graphics.print(text[4], 32, 48+4)

  love.graphics.setColor(palette.red)
  love.graphics.draw(scanIconImg, scanIconQuad[5], 0, 64)
  love.graphics.print(text[5], 32, 64+4)

  love.graphics.setColor(255, 255, 255)
end
