function delay_load()
  delays = {}
end

function delay_update(dt)
  local removeNils = false
  for i, v in ipairs(delays) do
    v.time = v.time - dt
    if v.time <= 0 then
      v.func(unpack(v.args))
      delays[i] = nil
      removeNils = true
    end
  end
  if removeNils == true then
    delays = removeNil(delays)
  end
end

function newDelay(time, func, args)
  delays[#delays+1] = {time = time, func = func, args = args}
end
