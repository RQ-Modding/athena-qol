# Athena QoL

Athena 2.0 grows up a little: more skill slots, any bow, Studies that keep pace with the world,
and two skills of her own to buy.

## What it changes

For Athena 2.0 only:

- **Five skill slots** instead of three: the game's own Skill Slots at ★★, also in an old save.
  The sixth slot is never sold to her, as in the game.
- **Any bow, whatever its level.** Only the level is lifted: a bow her class may not use stays
  refused.
- **Studies scale with the world.** After a fight, each Study the game's rule fires (Athena in rank
  4 or 5, the ally diagonally in front of her standing and higher in that stat) gives:

  | Study | World 1 | World 2 | World 3 | The game's |
  | --- | --- | --- | --- | --- |
  | Attack | +100 | +500 | +2000 | +3 |
  | HP | +100 | +500 | +2000 | +5 |
  | Accuracy | +5 | +10 | +20 | +2 |
  | Speed | +5 | +10 | +20 | +1 |
  | Critical | +5 | +10 | +20 | +1 |

  The gain is not cut at the ally's stat. Accuracy still stops at 200, speed and critical at 100.
  The Studies' descriptions say the gain of the world being played.
- **A stored skill point at world 2, and one more at world 3**, given once each: on reaching the
  world with her in the roster, or when she joins later. Morurun's reset and Skill Again keep them.
- **Smarter Aim** (from world 2, 1 point): *"Upgrades Athena Ranged Attacks. She will still be
  stupid."* Ranged Attack 1, 2 and 3 become **Calculated Shot 1, 2 and 3**: the same attacks with
  twice the damage limit (1000, 2000 and 4000 damage). Calculated Shot 3 keeps the accuracy -5.
  Ranged Attack 4 stays as it is. Smarter Aim cannot be erased.
- **Athena Maximum** (from world 3, 1 point, a yellow skill). While it is on her hotbar and she
  holds a bow:
  - her damage limits +100%, added to Damage Maximum's (with Damage Maximum ★★★, +200%);
  - Calculated Shot takes the element of the target's weakness when the weakness is known and no
    guard took the hit (as Aegis's arrows do), so it hits for the weakness bonus;
  - heals 10% of her most HP at each of her turns;
  - +40 to her hit chance.

Her Marble (ITEM) and Broken Clock (SPECIAL) cannot be removed, as in the game. In world 3 the
game itself takes that mark off every item when the world begins, so there they can come off; the
mod leaves that as it is.

## Keys and settings

None.

## Saves

The skills she learns are the game's own skill rows. Calculated Shot, Smarter Aim and Athena
Maximum are numbers the loader gives the mod (700 to 999); without the mod those rows show empty
skills. The count of stored points she got is kept in `rq.savedata` beside the save; the game
ignores it.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.66.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/athena-qol/mod.json`.

## How it works

- Slots: `rq.chara.edit(27, { learn = { { id = 568, n = 3 } } })`.
- Bows: `rq.item.on_can_equip`, when the item's level is the game's only reason.
- Studies: `rq.battle.on_study` returns the world's gain, and `rq.skill.on_describe` puts it in
  their descriptions.
- Stored points: `rq.chara.add_skill_points` from `rq.saves.on_load`, `rq.world.on_transfer_after`
  and `rq.chara.on_create`; `rq.chara.on_skill_reset` gives them back after a reset.
- Smarter Aim: `rq.skill.define`, `rq.chara.on_offer`, and the rows swapped with
  `rq.chara.set_slot` after each recalculation (`edit`'s `on_recalc`).
- Athena Maximum: `rq.combat.on_cap`, `rq.combat.on_element`, `rq.battle.on_turn`'s `ctx:heal`
  and `rq.combat.on_accuracy`.

## License

MIT, see [LICENSE](LICENSE).
