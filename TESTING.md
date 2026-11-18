# Testing Athena QoL

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading athena-qol` and the line `Athena QoL: five slots, ...`, which gives the skills' numbers.

## What it adds

- **Controls:** no buttons and no `rq.agent.control` ids. Do not invent controls for it.
- **Skills:** Calculated Shot 1 to 3, Smarter Aim and Athena Maximum, at the numbers the log line
  gives (700 to 999, the same every time). Smarter Aim and Athena Maximum are rows of Athena's
  skill window (`offer-N`) from world 2 and world 3.
- **Log:** `Athena QoL: <n> stored skill point(s) for world <w>` when she gets her points.

## How to check it

1. Athena 2.0 (character 27) in the roster: her skill window shows five hotbar places.
2. A bow above her level shows as wearable on her in the vault; a non-bow above her level does not.
3. Put her in rank 4 or 5 with a stronger ally diagonally in front of her, win a fight: each Study
   on her hotbar that fired adds the world's gain to its stat (status page). Each Study's
   description says that gain ("will increase by 100 after each" for Attack in world 1).
4. In world 2 or 3, her skill window sells Smarter Aim for 1 point. Buy it: her Ranged Attack 1 to
   3 rows become Calculated Shot 1 to 3, in the same hotbar places. ERASE is refused for it.
5. In world 3, buy Athena Maximum and put it on her hotbar. In a fight, with a bow: her turns heal
   10% of her HP; after Weakness Search on an enemy, Calculated Shot on it logs "(Attribute
   weakness)".
6. Her Marble and Broken Clock show no REMOVE in worlds 1 and 2. In world 3 they can come off:
   the game's world transfer takes the "cannot be removed" mark off every item. Not a bug.

## Reported once, not seen again

- One player saw an unleveled bow refused when dropped on her weapon while she wore a bow above
  her level (2026-11-13). The Lab could not make it happen: with Athena at level 1 wearing the
  Giga Attack Bow (level 50), a Shortbow dropped on her weapon slot (status page) or on her column
  (vault) was equipped, and the player could not repeat it. If you see it, note the screen, the
  two bows, her level and the world, and send `logs\rqmod.log`.

## Forcing it for a test

`rq.chara.learn(iic, <Smarter Aim>, { pay = false })` gives the skill as the window does.
`require("athena-qol")` (from another mod) or `rq.mod.get("athena-qol")` returns `SHOT`,
`SMARTER_AIM`, `MAXIMUM`, `GAINS`, `study_text(no, text)`, `sync(iic)`, `owed()`,
`give_points()` and `has_maximum(iic)`.
Work on a copy of the save.

## Tested in the game

The Test Lab's scenario `athena-qol` (with this mod installed): the slots, a bow above her level, the Studies' gains and
their descriptions in each world, Athena Maximum's description, her Marble and Broken Clock
marked "cannot be removed", the stored points, Smarter Aim's swap and Athena Maximum's limit,
element, heal and accuracy.
