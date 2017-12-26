# Snippets
Code that's not part of any other project but may eventually be reused.

* **bouncingBalls.bas** - Pseudo physics engine with rubber balls that can be dropped with a mouse click and that interact with each other. A "boing" sound file is embedded in the code and is dumped to disk at startup.
* **conway.bas** - Conway's game of life - uses too much CPU, needs optimizing.
* **drawGen.bas** - Generates DRAW command strings by allowing you to draw with the mouse, pick colors, close shapes and paint. More details at http://www.qb64.net/forum/index.php?topic=14253.msg123332#msg123332 
* **fontglypharray.bas** - The code will create an array with coordinates of points surrounding the text provided. It'll scan whatever text you enter and fill Points(x, y). In the end, said coordinates are plotted on the screen, as well as copied to the clipboard as data statements you can paste in another QB64 program. The whole point of writing this was to have a starting point for recreating the coding challenge from this video: https://youtu.be/4hA7G3gup-4
* **host-client** - Host-client sample for TCP/IP communication.
* **largeFont16.bas** - Contains the BIOS emulated font extract from libqb.cpp (QB64) and uses it to draw it at larger sizes. Routines to emulate _PRINTSTRING, _FONTHEIGHT, _FONTWIDTH and _PRINTWIDTH included.
* **pseudoRND.bas** - Generates a random table that can be reset and reused unlike the native random table.
* **scoreboard.bas** - Contains code used to fetch and update a scoreboard text file on a non-HTTPs, PHP-enabled server.