function char_load()
  playerActors ={}
  playerActors[1] = {}
  playerActors[1][1] = {speed = 30, turnPts = 10, name = "Luke", health = 20, abilities = {1, 1}, weapon = 1}
  playerActors[1][2] = {speed = 120, turnPts = 20, name = "Ben", health = 10, abilities = {1, 1}, weapon = 1}
  charHeight = 32
end

function queueChars(room)
  for i, v in ipairs(currentLevel.actors) do
    if room == v.room then
      local canvas, oldCanvas = resumeCanvas(v.canvas)
      love.graphics.setColor(255, 255, 255)

      love.graphics.draw(wallImg, -cameraPos.x, -cameraPos.y)
      love.graphics.setCanvas(oldCanvas)

      local x, y = coordToIso(v.x, v.y)
      drawQueue[#drawQueue + 1] = {type = 1, img = canvas, x = math.floor(x)+tileSize, y = math.floor(y)+tileSize/2, z= charHeight-tileSize, r = 100, g = 200, b = 100}
    end
  end
end
