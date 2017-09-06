function ability_load()
  abilities = {}

  abilities[1] = {type = 1, cost = 2, coolDown = 1, func = 1, targetMode = 1}

  abilityFuncs = {}

  abilityFuncs[1] = function (a, b, enemies)
    projectileAttack(a, b, enemies)
  end

  abilityDmgFuncs = {}

  abilityDmgFuncs[1] = function (a, b)

  end
end

function useAbility(ability, a, b, enemies) -- ability, user, and target (not necessarily an enemy), and rivals (for a player, it would be enemies)
    abilityFuncs[abilities[ability].func](a, b, enemies)
end
