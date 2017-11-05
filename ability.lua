function ability_load()
  abilities = {}

  abilities[1] = {cost = 2, coolDown = 1, func = 1, targetMode = 1, icon = 2, dmgInfo = {baseDmg = 5, projectile = 2, type = 2}, ai = 1, img = 2}

  abilityFuncs = {}

  abilityFuncs[1] = function (a, b, enemies, info)
    projectileAttack(a, b, enemies, info)
  end

  abilityFuncs[2] = function (a, b, enemies, info)
    hitscanAttack(a, b, enemies, info)
  end

  abilityAIs = {} -- functions should be adjusted so 10 is a good result

  abilityAIs[1] = function (enemyNum, enemy, target, info) -- for normal weapons
    return enemyCombatAIs[1](enemyNum, enemy, target, info) * (10/info.baseDmg)
  end
end

function useAbility(ability, a, b, enemies) -- ability, user, and target (not necessarily an enemy), and rivals (for a player, it would be enemies)
    abilityFuncs[abilities[ability].func](a, b, enemies, abilities[ability].dmgInfo)
end

function ability_update(dt)
  if currentActor.mode > 1 and currentActor.coolDowns[currentActor.mode-1] ~= 0 then
    currentActor.mode = 0
    currentActor.targetMode = 0

    -- set animation for putting away weapon
    currentActor.anim.quad = 5
    currentActor.anim.frame = 1
    newDelay(getAnimTime(charImgs.info[currentActor.actor.item.img], 1), function (player) player.anim.quad = 1; player.anim.frame = 1 end, {currentActor})
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
