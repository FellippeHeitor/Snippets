# Snippets
Code that's not part of any other project but may eventually be reused.

* **loadImage256.bas** - Loads an 8-bit image with proper palette adjustments and returns a handle. Can be used with 32-bit images as long as they contain 256 colors max (errors otherwise).
* **bouncingBalls.bas** - Pseudo physics engine with rubber balls that can be dropped with a mouse click and that interact with each other. A "boing" sound file is embedded in the code and is dumped to disk at startup.
* **circleLoading.bas** - Simple animation of a circle rotating to be used as a "loading" screen indicator.
* **conway.bas** - Conway's game of life - uses too much CPU, needs optimizing.
* **dithering.bas** - Loads an image and dithers it down to the amount of colors selected.
* **drawGen.bas** - Generates DRAW command strings by allowing you to draw with the mouse, pick colors, close shapes and paint. More details at http://www.qb64.net/forum/index.php?topic=14253.msg123332#msg123332 
* **fontglypharray.bas** - The code will create an array with coordinates of points surrounding the text provided. It'll scan whatever text you enter and fill Points(x, y). In the end, said coordinates are plotted on the screen, as well as copied to the clipboard as data statements you can paste in another QB64 program. The whole point of writing this was to have a starting point for recreating the coding challenge from this video: https://youtu.be/4hA7G3gup-4
* **host-client** - Host-client sample for TCP/IP communication.
* **hunterImagePreview.bas** - Simple image previewer; added for reference on how to stretch images while keeping aspect ratio.
* **iconpreview.bas** - Contains a function that loads the specified ".ico" file and returns a handle to the image in memory.
* **lineWithDraw.bas** - Draws a thick line from point A to point B by using DRAW instructions.
* **largeFont16.bas** - Contains the BIOS emulated font extract from libqb.cpp (QB64) and uses it to draw it at larger sizes. Routines to emulate _PRINTSTRING, _FONTHEIGHT, _FONTWIDTH and _PRINTWIDTH included.
* **pseudoRND.bas** - Generates a random table that can be reset and reused unlike the native random table.
* **rotateImage.bas** - Uses _MAPTRIANGLE to rotate an image freely.
* **sandParticles.bas** - Prototype of a particle system that attempted to resemble sand.
* **saveMemoryImage.bas** - Loads an image in 32-bit mode and dumps its contents from memory to disk (the uncompressed image).
* **scoreboard.bas** - Contains code used to fetch and update a scoreboard text file on a non-HTTPs, PHP-enabled server.
* **scrollbar.bas** - Scrollbar study.
* **shadow.bas** - A controllable source of light casts a shadow on screen.
* **svg.bas** - SVG renderer. Limited, but functional for simple files.
* **voxel.bas** - Faux-voxel rendering/drawing.