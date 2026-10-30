# VFX and gameplay v9

Q: Arcane Spear. E: Frost Nova. R: Radiant Renewal. T: Flame Bolt. All four are available from the start. Spell input supports a 160 ms buffer at the end of cooldown. Projectile aiming follows the center reticle; the server validates the direction and clips the visual endpoint to solid geometry. Spear and fire damage occurs after their visual travel time.

Fire uses an animated 4x4 flipbook, a separate hot core, smoke, sparks and short-lived local lighting. The other initial spells also have local illumination. Camera remains centered with no lateral roll.

14 braziers provide flame particles, embers and gently varying light. Client visibility is limited by distance and vertical separation. Pale imported rocks were archived; sculpted basalt Terrain replaces them around the sanctuary and first cave. Terrain backup: ServerStorage.BeforeCaveTerrainV9, region corner (-40,45,-40) in voxel coordinates. A generated replacement mesh was rejected visually and remains archived in ServerStorage.BasaltWallV9.

Tested Q/E/R/T without game script errors, confirmed cleanup to zero active spell models, successfully loaded fire texture/audio, and checked fire clipping against the cave wall at approximately 20.7 studs rather than passing through it.

Fire texture comes from the previously imported VFX pack: https://create.roblox.com/store/asset/70806823076906 . Fire impact audio: https://create.roblox.com/store/asset/139148990073887 . Existing whoosh: https://create.roblox.com/store/asset/9125648149 .

Save the open Roblox Studio scene with Ctrl+S. Existing rbxlx exports in this folder predate these live edits. This is a visual/gameplay iteration, not a claim of AAA production quality or a complete performance certification.
