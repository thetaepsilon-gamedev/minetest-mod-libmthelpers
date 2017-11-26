# libmthelpers
Misc. helper routines for minetest mods

When experimenting with in-game code using the luacmd mod,
I noticed that there were fragments of code that kept popping up everywhere.
I therefore decided to write them in a persistent location instead...
and threw them in this mod.

This mod therefore contains a bunch of fairly small boilerplate functions for things I typed frequently.
Because of their size, I'm not really going to bother documenting them.
Their function is fairly obvious in most cases;
[use the source luke][1] for it cannot lie.
Access to the table of functions is performed via [modns][2].

## Why is init.lua empty!?
[modns][2] handles all loading of this mod.
See the lib/ directory;
The lua files beginning with "com.github.thetaepsilon.minetest.libmthelpers"
represents the mod and their components.
The above string is also the modns path to load this mod by.



[1]: https://blog.codinghorror.com/learn-to-read-the-source-luke/
[2]: https://github.com/thetaepsilon-gamedev/minetest-mod-modns
