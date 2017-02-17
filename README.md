# Modifications for Medal of Honor: Allied Assault

This is a collection of mods that I spent many of my teenage years on. Most of them are unfinished, some may be missing files. There were many, many more, but they appear to be lost to the ages. Should I ever unearth more in my backups, I will upload them here as well.

Several of these mods require C++ code to run; the code has been severely censored to avoid legal issues, though, so don't expect it to compile.

I was asked by [@Loix7](https://twitter.com/Loix7) to share this for archival/historical purposes, so here goes! For working mods, please refer to the wonderful [Amalgamated Allied Assault Alliance clan's mod database](http://www.mohaaaa.co.uk/AAAAMOHAA/content/downloads-and-resources). I highly commend them for compiling such a comprehensive collection!

# Table of Contents
* `ffe` - Fire-For-Effect! adds artillery and air support in the style of *Wolfenstein: Enemy Territory*
* `firefighters` - unfinished cooperative firefighting mod
* `horror` - Survival Horror; one player is invisible and has one-shot-kill ability while the others try to survive
* `landmines` - duplicate of *Enemy Territory's* feature of defusable landmines
* `mohreal` - unfinished (barely started?) mod to add what today's kids call "hardcore mode" to the game: ironsights, harsher damage model, more difficult aim control, stamina
* `paintball` - unfinished attempt at believably modelling paintball ballistics
* `portal` - duplicate of *Portal's*... well, portals, just without the fancy rendering-to-texture (i.e. teleports with momentum conservation)
* `rope` - a dysfunctional attempt at adding climbable ropes with harpoons (the idea was to allow climbing anywhere one pleased); started with me inventing an algorithm which was actually already widely known, only I had no idea of Position-Based Dynamics at the time
* `teamcommand` - Team Command; a never-before-seen mod that gave every player a squad of AI bots to issue orders to via in-game voice chat; the entire C++ component is missing, I don't have it even in private backups

# License

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
```

# Special thanks
I'd like to thank 2015 & EA for making this game happen and providing me with some of the fondest memories of my late childhood/adolescence. :) Many thanks also go out to jv_map, SaperPL, Mefy, Elgan Sayer, BjarneBZR, MJ, Trent Gillespie, lizardkid, Gen Cobra, Cobra {sfx} (that's two different guys, actually!), Catalina, ChemicalRider, all the *.map for Medal of Honor* and *The Modding Theater* and *{sfx}* crews and many, many others who made the MoHAA modding community such an awesome space to be in for all those years. You guys helped me start down the path in life I'm still walking to this day, and hope to continue.

## Disclaimer
None of this code is supported. Some of it may require additional steps to set up. If you're building the C++ code, remember that the resulting DLLs are not replacements for the originals, they are "overlays" that still require the originals to work. Some C++ code has been intentionally removed, it is not intended to build easily.
