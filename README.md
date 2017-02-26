# LifeOne

Workthrough of Pete Corey's two articles walking through building a Game of Life implementation
using processes to represent cells, and using the Registry module to keep track of them.
Uses Phoenix for the front-end, rendering to canvas using channels.

http://www.east5th.co/blog/2017/02/06/playing-the-game-of-life-with-elixir-processes/
http://www.east5th.co/blog/2017/02/20/rendering-life-on-a-canvas-with-phoenix-sockets

To start it up, run `iex -S mix phoenix.server` and go to `http://localhost:4000`. The intitial
positions should be in place: hit any key to start the simulation. Reload to restart.
