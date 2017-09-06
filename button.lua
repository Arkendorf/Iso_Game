 function button_load()
   button_toggleMode = function (mode)
     if currentActor.mode == mode then
       currentActor.mode = 0
       currentActor.targetMode = 0
     else
       currentActor.mode = mode
       if mode == 1 then
         currentActor.targetMode = 1
       else
         currentActor.targetMode = abilities[playerActors[currentLevel.type][currentActor.actor].abilities[mode-1]].targetMode
       end
     end
   end


   buttons = {}
   buttons[1] = {x = 1, y = screen.h-25, w = 44, h = 24, func = button_toggleMode, args = {1}}
   buttons[2] = {x = 45, y = screen.h-25, w = 44, h = 24, func = button_toggleMode, args = {2}}
   buttons[3] = {x = 89, y = screen.h-25, w = 44, h = 24, func = button_toggleMode, args = {3}}

 end

 function button_mousepressed(x, y, button)
   for i, v in ipairs(buttons) do
     if button == 1 then
       if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
         v.func(unpack(v.args))
         return true
       end
     end
   end
   return false
 end
