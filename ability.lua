function ability_load()
  abilities = {}

  abilities[1] = {type = 1, cost = 2, coolDown = 1, func = 1, targetMode = 1}

  abilityFuncs = {}

  abilityFuncs[1] = function (a, b)
    projectileAttack(a, b)
  end
end

function useAbility(ability, a, b) -- ability, user, and target (not necessarily an enemy)
  abilityFuncs[abilities[ability].func](a, b)
end
