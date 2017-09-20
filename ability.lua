function ability_load()
  abilities = {}

  abilities[1] = {cost = 2, coolDown = 1, func = 1, targetMode = 1, icon = 2, dmgInfo = {baseDmg = 5}}

  abilities[2] = {cost = 3, coolDown = 0, func = 2, targetMode = 4, icon = 3, dmgInfo = {baseDmg = 5}}

  abilityFuncs = {}

  abilityFuncs[1] = function (a, b, enemies, info)
    projectileAttack(a, b, enemies, info)
  end

  abilityFuncs[2] = function (a, b, enemies, info)
    hitscanAttack(a, b, enemies, info)
  end
end

function useAbility(ability, a, b, enemies) -- ability, user, and target (not necessarily an enemy), and rivals (for a player, it would be enemies)
    abilityFuncs[abilities[ability].func](a, b, enemies, abilities[ability].dmgInfo)
end

function ability_update(dt)
  if currentActor.mode > 1 and currentActor.coolDowns[currentActor.mode-1] ~= 0 then
    currentActor.mode = 0
    currentActor.targetMode = 0
  end
end


function reduceCoolDowns(table)
  for i, v in ipairs(table) do
    for j = 1, 2 do
      if v.coolDowns[j] > 0 then
        v.coolDowns[j] = v.coolDowns[j]-1
      end
    end
  end
end
