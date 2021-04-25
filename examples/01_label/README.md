**01_label** - A bouncing label

A barebones Cedar example.

# Run me

```
cd cedar/examples/01_label
bundle install
./main.rb
```


_(This example was configured to load the Cedar gem from ../.. via `bundle config --local local.cedar ../..`)_

# Tour the code

(All code for this example is tucked in [main.rb](main.rb))

## Whirlwind design session

Let's animate a blurb of text bouncing around inside a 200 x 400 red box.

For fun, hitting SPACE should toggle the text back-n-forth to a green ball.

## The `LabelExample` module

A [module](../../README.md#modules) should not maintain any internal state, so there's no need to create a class or instances thereof. A Ruby Module with module-level methods `new_state`, `update` and `draw` are all that's required.

```ruby
module LabelExample
  def self.new_state
    # initialize a new state object. Can be anything. 
    {}
  end

  def self.update(state, input, res)
    state # always gotta return the next state, even if it's the given state
  end

  def self.draw(state, output, res)
  end
```

The docs say "State can be anything" but it's important that our module uses
**internally consistent** structure(s).  The `new_state`, `update` and `draw` methods **must agree** on the types and rules contained in the state as it passes from method to method or we're gonna have trouble.

This bit of pseudocode (essentially) describes how Cedar uses your module to run the game simulation:

```ruby
  s = LabelExample.initial_state
  loop do
    # ...game timer, input collection, etc
    s = update(s, input, res)
    draw(s, output, res)
  end
```

(More on the `input`, `output` and `res` args in a bit.)

## Initial state

Cedar calls our module's `#new_state` method before the main game loop begins.

This object will be the first state passed to `#update`.

```ruby
  def new_state
    {
      words: "Welcome to the Cedar grove!",
      x: 0, y: 0,
      dx: 100, dy: 150,
      color: Gosu::Color::WHITE,
      border_color: Gosu::Color::RED,
    }
  end
```

Here, we chose to model state using a shallow Hash:

- `words` holds the content for the text blurb
- `x` and `y` hold the position of the text
- `dx` and `dy` hold the velocity of the moving text.
- `color` is a Gosu color to use to render the text
- `border_color` is a Gosu color for drawing the fixed rectangular bounds

Later, this object will be passed to `update`.

## Update the simulation

Cedar calls `update` then `draw` with each tick of the game simulation.

Let's break down our `update` method:

```ruby
  def update(state, input, res)
    ...
```

The params:

- `state` - Our module's state.  The object returned by `new_state`, OR (more often) the object returned by a prior invocation of `update`
- `input` - A `Cedar::Input` structure, containing time and controller inputs. See [Input](../../README.md#input)
- `res` - A `Cedar::Resources` used for retrieving file data, images, sprites, animation funcs, etc.

```ruby
    ...
    # controls
    if input.keyboard.pressed?(Gosu::KB_SPACE)
      if state[:words] == "O"
        state[:words] = "Welcome to the Cedar grove!"
        state[:color] = Gosu::Color::WHITE
      else
        state[:words] = "O"
        state[:color] = Gosu::Color::GREEN
      end
    end
    ...
```

Here we check if KB_SPACE was just now pressed (`input.keyboard.pressed?` returns true only during the tick where the key was initially depressed; to check for general down-ness of a key as time goes by, use `input.keyboard.down?`).  If pressed, we peek at the state of `:words` and toggle the string between `"O"` and the welcome message. We also toggle the `:color` between white and green.

```ruby
    ...
    # movement
    state[:x] += state[:dx] * input.time.dt
    state[:y] += state[:dy] * input.time.dt
    state[:dx] *= -1 if state[:x] > 200 || state[:x] < 0
    state[:dy] *= -1 if state[:y] > 400 || state[:y] < 0
    ...
```

Here we recompute the location `:x` and `:y` using velocity stored in `:dx` and `:dy`.  If the location ends up beyond our hard-coded boundary of `[0,0,200,400]`, we invert either `:dx` or `:dy` accordingly to simulate bouncing off the walls.

```ruby
    state # return the "next state" from update
  end
```

Our implementation of `update` modifies `state` in place.  But since Cedar makes no assumption about the mutability of any given state object, we must still return a reference to the "new" state object, even though for us, it's the same object we were given.

_(* This method of state wrangling enables module implementors to use immutable values--persistent data structures--to manage module state.)_

## Draw the scene


```ruby
  def self.draw(state, output, res)
    ...
```

The params:

- `state` - Our module's state.  Almost always, the object returned by the most recent call to `update`.
- `output` - A `Cedar::Output` structure, containing `graphics` and some other helpful references used for composing an output scene.
- `res` - Same `Resources` object as passed to `update`.

The technique:

Our `draw` method isn't really meant to _draw_ anything; instead, it enqueues a set of _drawing directives_ into `output.graphics`, which Cedar will then use to execute Gosu drawing commands.

Eg, 

```ruby
    ...
    output.graphics << Cedar::Draw::Label.new(x: state[:x], y: state[:y], text: state[:words], color: state[:color])
    ...
```

...creates a new `Label` object using values from our state, and adds it to `output.graphics`. 

Notes on `z` and draw order:

- Cedar drawing directives are executed in the order they are added to `graphics`.
- Gosu drawing is last-on-top: the latest draw instructions are layered over the earlier operations. EXCEPT!
- ...Gosu drawing commands tend to support a `z` param to more directly control layering, which defaults to 0.  Last-on-top applies to any commands that share the same `z` value.  Higher `z` values draw on top of lower `z` values.
- **Cedar drawing directives all support `z`** params that pass directly to Gosu.

Note: Cedar provides `Group`, `Translate` and `Scale` drawing directives to group, move and size entire subsets of drawing objects.

## Build and start the Game

Near the bottom of [`main.rb`](main.rb), we build and launch the actual `Cedar::Game`:

```ruby
Cedar::Game.new(
  root_module: LabelExample,
  caption: "01: A bouncing label",
).start!
```

A Cedar game is essentially a Gosu window wrapping our module.

The only required Game config options is `root_module`.  Other avialable options include `caption`, `width`, `height`, `fullscreen` etc. See [Game: Options](../../README.md#game).
