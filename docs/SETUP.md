# Source layout and scene dependencies

The archived v2 place opens independently in Roblox Studio. The newer source exports are provided for review; copying them into the old scene is not a complete upgrade procedure.

For the corresponding current scene, script placement is:

- `src/server/AbismoServer.server.luau`: Script in ServerScriptService named AbismoServer.
- `src/client/*.client.luau`: LocalScripts in StarterPlayer.StarterPlayerScripts, using the filename before `.client.luau` as their names.
- `src/shared/ArcaneSpellArtV8.luau`: ModuleScript in ReplicatedStorage named ArcaneSpellArtV8.

Required scene objects include Workspace.AbismoArcano and its portals Portal0 through Portal5, ReplicatedStorage.AbismoEvent (RemoteEvent), and the corresponding floor geometry/spawn setup. The newer VFX reference ReplicatedStorage.SpellMaterialsV9.FlameFlipbook, ArcaneLanceMeshV8 and ArcaneIceMeshV8. These newer visual instances and terrain changes are not guaranteed to exist in the archived v2 place.

Keep a backup of the current Studio place. Export the current scene before replacing scripts or claiming a reproducible v9 build. The historical development notes describe tests performed during development, not a fresh validation of this repository's combined scene and source exports.
