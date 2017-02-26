# LifeOne

Workthough of the article [Playing the Game of Life With Elixir Processes](http://www.east5th.co/blog/2017/02/06/playing-the-game-of-life-with-elixir-processes/).

Very slight changes at first: `Universe` -> `Universe.Worker`, and `Cell` -> `Cell.Worker`. 

## Running the application

```
iex -S mix
```

Then seed the application with one of the following using`Cell.Worker.sow({x,y})`:

### Glider:
```
[{1, 2},{2, 1},{0, 0}, {1, 0}, {2, 0}] |> Enum.map(&Cell.Worker.sow/1)
```

### Diehard
```
[{6, 2},{0, 1}, {1, 1},{1, 0},{5, 0}, {6, 0}, {7, 0}] |> Enum.map(&Cell.Worker.sow/1)
```

### Blinker
```
[{0,0},{1,0},{2,0}] |> Enum.map(&Cell.Worker.sow/1)
```

Run the observer, and observe the processes being created and dying over the generations:

```
> :observer.start
> 1..150 |> Enum.map(fn ->
    Universe.Worker.tick
    :timer.sleep(500)
  end)
```
