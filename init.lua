-- Athena QoL. For Athena 2.0 (character 27): five skill slots, any bow whatever its level, her
-- Studies scaled by the world, a stored skill point at worlds 2 and 3, and two skills to buy:
-- Smarter Aim (world 2: Ranged Attack 1 to 3 become Calculated Shot 1 to 3, twice the damage
-- limit) and Athena Maximum (world 3, yellow: with a bow, the limit +100%, Calculated Shot on a
-- known weakness, 10% HP each turn, +40 accuracy). Lua owns who and every number; the loader calls
-- it from the game's equip check, the Studies, the damage limit, a hit's element, the turns and
-- the accuracy (loader 2.46.0).

local ids = rq.ids
local ATHENA = ids.chara.ATHENA_2_0           -- 27
local SKILL_SLOTS = ids.skill.SKILL_SLOTS     -- 568: no star 3 slots, ★ 4, ★★ 5, ★★★ 6
local SLOTS_RANK = 3                          -- ★★: five slots. The 6th is never sold to her.
local BOW = ids.item_kind.BOW                 -- 5, the weapon kind (Ｉ種類詳細)
local ROSTER_FIRST = 20                       -- allies' roster slots start here; enemies are below

-- The Studies' gains for worlds 1, 2 and 3, in place of the game's +3 attack, +2 accuracy,
-- +1 speed, +5 HP, +1 critical. The game's rule decides which Study fires; the gain is not cut
-- at the studied ally's stat. The stats keep the game's maximums.
local GAINS = {
  attack = { 100, 500, 2000 },
  hp = { 100, 500, 2000 },
  accuracy = { 5, 10, 20 },
  speed = { 5, 10, 20 },
  critical = { 5, 10, 20 },
}

local MAXIMUM_LIMIT = 100   -- Athena Maximum: the damage limit +100%, added to Damage Maximum's percent
local MAXIMUM_HEAL = 10     -- percent of her most HP, at each of her turns
local MAXIMUM_ACCURACY = 40 -- added to the hit chance, the scale of a skill's own -5 and -10
local SHOT3_ACCURACY = -5   -- Ranged Attack 3's -5, which the game keeps by its number (110)

local function world()
  local w = rq.world.current() or 1
  if w < 1 then return 1 end
  if w > 3 then return 3 end
  return w
end

-- Skills ---------------------------------------------------------------------

local SHOT_LINE = "'I am not stupid, my bow was stupid!'$She is also stupid.$$"
local SHOT_ELEMENT = "Element:\tNone$\t(Athena Maximum: a known weakness)"

-- Ranged Attack 1 to 3 (108 to 110) with twice the limit: the same target, multiplier, added
-- attack and basic-attack flag as the game's.
local RANGED = { ids.skill.RANGED_ATTACK_1, ids.skill.RANGED_ATTACK_2, ids.skill.RANGED_ATTACK_3 }
local SHOT_DATA = {
  { bairitsu = 100, flat = 0, cap = 1000, modifier = "None", mult = "1.0x" },
  { bairitsu = 110, flat = 100, cap = 2000, modifier = "Attack +100", mult = "1.1x" },
  { bairitsu = 110, flat = 200, cap = 4000, modifier = "Attack +200$\tAccuracy -5", mult = "1.1x" },
}

local SHOT = {}         -- 1 to 3 -> the skill number
local TO_SHOT = {}      -- Ranged Attack n -> Calculated Shot n
local TO_RANGED = {}    -- and back
local IS_SHOT = {}
for n, d in ipairs(SHOT_DATA) do
  local no = rq.skill.define({
    id = "athena-qol:calculated_shot_" .. n,
    kind = "physical",
    name = "Calculated Shot " .. n,
    flavor = "shot with equipped weapon.",
    desc = SHOT_LINE
      .. "Target:\tSingle enemy/Long range$"
      .. "Modifier:\t" .. d.modifier .. "$"
      .. "Dmg Mult:\t" .. d.mult .. "$"
      .. "Limit:\t" .. d.cap .. " damage$"
      .. SHOT_ELEMENT,
    target = 2,
    bairitsu = d.bairitsu,
    flat = d.flat,
    cap = d.cap,
    basic = 1,
  })
  rq.skill.sort_as(no, RANGED[n])
  SHOT[n] = no
  TO_SHOT[RANGED[n]] = no
  TO_RANGED[no] = RANGED[n]
  IS_SHOT[no] = true
end

local SMARTER_AIM = rq.skill.define({
  id = "athena-qol:smarter_aim",
  kind = "knowledge",
  name = "Smarter Aim",
  flavor = "",
  desc = "Upgrades Athena Ranged Attacks.$She will still be stupid.$$"
    .. "Target:\tSelf$"
    .. "Effect:\tRanged Attack 1 to 3 become$"
    .. "\tCalculated Shot 1 to 3,$"
    .. "\twith twice the damage limit$"
    .. "Cannot be erased.",
})
rq.skill.patch(SMARTER_AIM, { locked = 1 })

-- A yellow skill, as the game registers Damage Maximum (Ｓ能力登録: type 20, panel 102, action 0).
local MAXIMUM = rq.skill.define({
  id = "athena-qol:athena_maximum",
  kind = "knowledge",
  name = "Athena Maximum",
  flavor = "",
  desc = "Athena at her very best, while she holds a bow.$$"
    .. "Target:\tSelf$"
    .. "Effect:\tDamage limit +" .. MAXIMUM_LIMIT .. "%$"
    .. "\tCalculated Shot takes the element$"
    .. "\tof a known weakness$"
    .. "\tHeals " .. MAXIMUM_HEAL .. "% HP each turn$"
    .. "\tAccuracy +" .. MAXIMUM_ACCURACY .. "$"
    .. "Unequipped:\tNo effect",
})
rq.skill.patch(MAXIMUM, { type = 20, panel = 102, action = 0, target = 0 })

-- Ranged Attack <-> Calculated Shot, by Smarter Aim. The row keeps its uses and hotbar place.
local function sync(iic)
  local smart = rq.chara.rank(iic, SMARTER_AIM) >= 1
  local changed = 0
  for _, s in ipairs(rq.chara.slots(iic)) do
    local to
    if smart then to = TO_SHOT[s.skill] else to = TO_RANGED[s.skill] end
    if to then
      rq.chara.set_slot(iic, s.slot, to)
      rq.chara.set_flavor(iic, s.slot)
      changed = changed + 1
    end
  end
  return changed
end

-- Five slots through the game's own Skill Slots, also in old saves; the swap after each recalculation.
rq.chara.edit(ATHENA, {
  learn = { { id = SKILL_SLOTS, n = SLOTS_RANK } },
  on_recalc = function(iic)
    sync(iic)
  end,
})

rq.chara.on_learn(function(ctx)
  if ctx.skill == SMARTER_AIM then sync(ctx.iic) end
end)

-- Her buy list: Smarter Aim from world 2, Athena Maximum from world 3, 1 point each.
rq.chara.on_offer(function(ctx)
  if ctx.no ~= ATHENA then return nil end
  local w = world()
  local rows = {}
  if w >= 2 and rq.chara.rank(ctx.iic, SMARTER_AIM) < 1 then
    rows[#rows + 1] = { skill = SMARTER_AIM, cost = 1, level = 1, points = 1 }
  end
  if w >= 3 and rq.chara.rank(ctx.iic, MAXIMUM) < 1 then
    rows[#rows + 1] = { skill = MAXIMUM, cost = 1, level = 1, points = 1 }
  end
  return rows
end)

-- Bows at any level ----------------------------------------------------------

-- Only the level is lifted: a bow her class or the item's own list refuses stays refused.
rq.item.on_can_equip(function(ctx)
  if ctx.chara ~= ATHENA or ctx.allowed then return nil end
  if #ctx.reasons ~= 1 or ctx.reason ~= "level" then return nil end
  local it = rq.item.get(ctx.ii)
  if it and it.subtype == BOW then return true end
  return nil
end)

-- Studies --------------------------------------------------------------------

rq.battle.on_study(function(ctx)
  local g = GAINS[ctx.stat]
  if g then return g[world()] end
  return nil
end)

-- Their hover texts say the world's gain: the game's sentence ("will increase by 3 after each")
-- with the number replaced. rq.skill.on_describe runs each time a text is shown, so a load or a
-- world transfer needs nothing more.
local STUDY_STAT = {
  [ids.skill.ATTACK_STUDIES] = "attack",     -- 336
  [ids.skill.ACCURACY_STUDIES] = "accuracy", -- 337
  [ids.skill.SPEED_STUDIES] = "speed",       -- 338
  [ids.skill.HP_STUDIES] = "hp",             -- 339
  [ids.skill.CRITICAL_STUDIES] = "critical", -- 340
}

local function study_text(no, text)
  local stat = STUDY_STAT[no]
  if not stat or type(text) ~= "string" then return nil end
  local out, n = text:gsub("will increase by %d+ after each",
    "will increase by " .. GAINS[stat][world()] .. " after each", 1)
  if n == 0 then return nil end
  return out
end

rq.skill.on_describe(study_text)

-- Stored points ----------------------------------------------------------------

-- One point for world 2 and one more for world 3, given once each whenever she is in the roster:
-- on reaching the world with her, or when she joins later. rq.savedata keeps how many she got.
local GIVEN = "points_given"

local function owed()
  local w = world()
  return (w >= 2 and 1 or 0) + (w >= 3 and 1 or 0)
end

local function give_points()
  local iic = rq.chara.find(ATHENA)
  if not iic then return 0 end
  local given = rq.savedata.get(GIVEN, 0)
  local due = owed()
  if given >= due then return 0 end
  rq.chara.add_skill_points(iic, due - given)
  rq.savedata.set(GIVEN, due)
  rq.log(("Athena QoL: %d stored skill point(s) for world %d"):format(due - given, world()))
  return due - given
end

rq.saves.on_load(function() give_points() end)
rq.world.on_transfer_after(function() give_points() end)
rq.chara.on_create(function(ctx)
  -- after the game finished making her (the recruitment goes on after Ｃ生成)
  if ctx.no == ATHENA then rq.after(0, give_points) end
end)

-- Morurun's reset and Skill Again set her free points to the game's own count: give ours back.
rq.chara.on_skill_reset(function(ctx)
  if ctx.no ~= ATHENA then return end
  local given = rq.savedata.get(GIVEN, 0)
  if given > 0 then rq.chara.add_skill_points(ctx.iic, given) end
end)

-- Athena Maximum ---------------------------------------------------------------

-- On her hotbar, with a bow in hand. Neither changes inside a fight, so it is kept per fight.
local maximum_on = {}

local function has_maximum(iic)
  local v = maximum_on[iic]
  if v ~= nil then return v end
  v = false
  if iic >= ROSTER_FIRST and rq.chara.number(iic) == ATHENA and rq.chara.weapon_detail(iic) == BOW then
    for _, s in ipairs(rq.chara.slots(iic)) do
      if s.skill == MAXIMUM and s.bar > 0 then
        v = true
        break
      end
    end
  end
  maximum_on[iic] = v
  return v
end

rq.battle.on_start(function() maximum_on = {} end)
rq.battle.on_end(function() maximum_on = {} end)

rq.combat.on_cap(function(ctx)
  if ctx.base > 0 and has_maximum(ctx.attacker) then
    return ctx.base * (100 + ctx.damage_max + MAXIMUM_LIMIT) // 100
  end
  return nil
end)

-- As the game's arrows: the weakness only when it is known and no guard took the hit.
rq.combat.on_element(function(ctx)
  if IS_SHOT[ctx.skill] and ctx.known and not ctx.guarded and ctx.weakness ~= 0
    and has_maximum(ctx.attacker) then
    return ctx.weakness
  end
  return nil
end)

local function accuracy(ctx)
  local d = 0
  if ctx.skill == SHOT[3] then d = d + SHOT3_ACCURACY end
  if has_maximum(ctx.attacker) then d = d + MAXIMUM_ACCURACY end
  return d
end
rq.combat.on_accuracy(accuracy)

rq.battle.on_turn(function(ctx)
  if ctx.side ~= "ally" or ctx.downed or not has_maximum(ctx.iic) then return end
  local c = rq.chara.get(ctx.iic)
  if c and c.hp > 0 and c.hp < c.hp_max then
    ctx:heal(math.max(1, c.hp_max * MAXIMUM_HEAL // 100))
  end
end)

rq.log("Athena QoL: five slots, bows at any level, Studies by world, Smarter Aim "
  .. SMARTER_AIM .. ", Calculated Shot " .. SHOT[1] .. "/" .. SHOT[2] .. "/" .. SHOT[3]
  .. ", Athena Maximum " .. MAXIMUM)

-- For the Lab.
return {
  SHOT = SHOT,
  SMARTER_AIM = SMARTER_AIM,
  MAXIMUM = MAXIMUM,
  GAINS = GAINS,
  study_text = study_text,
  sync = sync,
  owed = owed,
  give_points = give_points,
  has_maximum = has_maximum,
  accuracy = accuracy,
  -- forgets who has Athena Maximum on, as a fight's start does
  forget_maximum = function() maximum_on = {} end,
}
