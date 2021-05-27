**Cedar**

- [Getting Started](#getting-started)
- [Examples](#examples)
- [Concepts](#concepts)
  - [Modules](#modules)
    - [Module State](#module-state)
- [API](#api)
  - [Game](#game)
  - [Input](#input)
    - [Time](#time)
    - [Keyboard](#keyboard)
    - [Mouse](#mouse)
  - [Output](#output)
    - [Cedar::Draw::Text](#cedardrawtext)
    - [Cedar::Draw::Image](#cedardrawimage)
    - [Cedar::Draw::Sprite](#cedardrawsprite)
    - [Cedar::Draw::Rect](#cedardrawrect)
    - [Cedar::Draw::RectOutline](#cedardrawrectoutline)
    - [Cedar::Draw::Line](#cedardrawline)
    - [Cedar::Draw::Group](#cedardrawgroup)
    - [Cedar::Draw::Translate < Group](#cedardrawtranslate--group)
    - [Cedar::Draw::Scale < Group](#cedardrawscale--group)
  - [Resources](#resources)
    - [Resource Configs](#resource-configs)
      - [image_sprite](#image_sprite)
      - [Config Examples](#config-examples)
      - [Custom Resources](#custom-resources)
- [ECS](#ecs)
  - [Cedar::Entity](#cedarentity)
  - [Cedar::EntityStore](#cedarentitystore)
  - [Cedar::Components](#cedarcomponents)
  - [Cedar::Systems](#cedarsystems)
  - [Search - filters, caching](#search---filters-caching)

# Getting Started

# Examples

- [01_label](examples/01_label) - Barebones example Cedar app

# Concepts

## Modules

A Module is an object (or Ruby module or class) with these methods

- `new_state()` => `state`
- `update(state, input, resources)` => `[state, side_fx]`
- `draw(state, output, resources)`
- `resource_config()` => `config`

### Module State

- Any object or value can serve as the state of a Module.
- Cedar initializes a Module by calling `new_state` and retaining the returned object.
- Cedar moves from one state to the next by invoking `update` with the current state object, and overwriting it with the new state returned by `update`.
- Cedar passes the current state object to `draw` to get a rendering
  
- State objects can be mutable, or immutable; this choice resides with the Module implementor.
- Regardless of mutability, a Module's `update` method must always return "the new state" even if it's just the same state object that was passed to update.
- **Modules must not retain any direct references to state.** 
  - All required data should reside withing the state objects created and returned by `new_state` and `update`.
  - Cedar thinks of a state object as a snapshot of a Module in time, and may copy, store, and re-send to `update` or `draw` idempotently, in any order, at any time.

# API

## Game

Options: (all but `root_module` are optional with sane defaults)

- `root_module` - You game Module. See [Concepts: Module](#modules)
- `caption` - The window title. Optional, defaults to root_module.name
- `width` and `height` - pixel dimensions of the game window. Default 1280x720
- `fullscreen` - bool, default false
- `mouse_pointer_visible` - bool, default false
- `update_interval` - Interval between updates in milliseconds.  The default leads to 60fps.  See [Gosu::Window#update_interval](https://www.rubydoc.info/github/gosu/gosu/master/Gosu%2FWindow:update_interval) for more info.

See `Game#initialize` in [lib/game.rb](lib/game.rb)

## Input 

[Cedar::Input](lib/cedar/)

- input.time
- input.keyboard
- input.mouse
- input.window - The Gosu game window.  (Use lightly.)

### Time

`input.time` is a [Cedar::GameTime](lib/cedar/game_time.rb).  **Don't keep references to the time object.** Just read and use one of its convenience properties: 

- input.time.**dt** - time since last update (in decimal seconds)
- input.time.**dt_millis** time since last update (in milliseconds)
- input.time.**t** - game elapsed time in decimal seconds
- input.time.**millis** - game elased time in milliseconds

### Keyboard

Key IDs are [Gosu::KB_* constants](https://www.rubydoc.info/github/gosu/gosu/master/Gosu)

- input.keyboard.**pressed?**(id) - Was this key just now pressed?
- input.keyboard.**down?**(id) - Was this key down?
- input.keyboard.**released?**(id) - Was this key just now released?
- input.keyboard.**shift?** - Was the Shift key down?
- input.keyboard.**control?** - Was the Control key down? (right or left)
- input.keyboard.**alt?** - Was the Alt key down? (right or left)
- input.keyboard.**meta?** - Was the Meta key down? (Mac: Command, Win: Windows, Linux: Super)
- input.keyboard.**any?** - Was any key pressed, held or released this tick?

### Mouse 

tbd

## Output

- output.graphics
- output.window

See below for a list of drawable types

### Cedar::Draw::Text

```ruby
output.graphics << Text.new(text: "You have: No tea.", font:Gosu::Font.new(20), x:0, y:0, z:0, scale_x:1, scale_y:1, color:Gosu::Color::WHITE) do
```

### Cedar::Draw::Image

```ruby
output.graphics << Image.new(image:Gosu::Image, path:"sprites/smiley.gif", x:20, y:100, z:101, scale_x:1.0, scale_y:1.0, subimage:[subx,suby,subw,subh]) do
```

### Cedar::Draw::Sprite

```ruby
output.graphics << Sprite.new(name: "smiley_face", frame:5, x:0, y:0, z:99, angle:0, center_x:0, center_y:0, scale_x:1, scale_y:1) do
```

### Cedar::Draw::Rect

```ruby
output.graphics << Rect.new(x:0, y:0, z:0, w:100, h:50, color:Gosu::Color::BLUE, mode: :default)
```

### Cedar::Draw::RectOutline

```ruby
output.graphics << RectOutline.new(x:0, y:0, z:0, w:100, h:50, color:Gosu::Color::RED, mode: :default)
```

### Cedar::Draw::Line

```ruby
output.graphics << Line.new(x1:100, y1:20, x2:250, :y2:90, z:100, color:Gosu::Color::WHITE, color2:Gosu::Color::BLUE, mode: :default)
```

### Cedar::Draw::Group

- group.clear()
- group.add(drawable)
  - alias: `concat`
  - alias: `<<`

```ruby
group = Group.new do |g|
  g << Rect.new(x:5, y:5, z:99, color:Gosu::Color.rgba(0, 0, 0, 80))
  g << Text.new(text: "LogZ!", x:5, y:5, z: 100)
end
output.graphics << group
```

### Cedar::Draw::Translate < Group

```ruby
moved = Translate.new(5,5) do |g|
  g << Rect.new(x:0, y:0, z:99, color:Gosu::Color.rgba(0, 0, 0, 80))
  g << Text.new(text: "LogZ!", x:0, y:0, z: 100)
end
output.graphics << moved
```

### Cedar::Draw::Scale < Group

```ruby
scaled = Scale.new(2.0, 2.0) do |g|
  g << Rect.new(x:0, y:0, z:99, color:Gosu::Color.rgba(0, 0, 0, 80))
  g << Text.new(text: "LogZ!", x:0, y:0, z: 100)
end
output.graphics << scaled
```

## Resources

The Cedar::Resources object is the bridge between symbolic references (like names of sprites and animations, data blob names, sfx names... things you'd store in your game state) and their realized asset data / live objects (Gosu images, initialized sound playback objects, big map files).

Resources are (typically) lazy-loaded and cached on first use.

`image`, `file` and `data` resources are "auto constructed" by name, when their names coincide with their filesystem paths.

`sprite`, `animation`, `font` etc. resources are named resources that must be pre-configured by modules before they can be referenced (and thence loaded/cached) by name.

- res.get_file(name)
- res.get_data(name)
- res.get_image(name)
- res.get_sprite(name)
- res.get_animation(name)
- res.get_font(name)

- res.register_object_type(obj_type
- res.configure(config)
- res.get_resource(category, name)
- res.reset_caches

### Resource Configs

under construction

A "config" is a Hash with key `:type`, which is a named reference to a registered "object type".

The `Resources#configure` method accepts:
  - A config Hash
  - A string naming a JSON data resource that contains a config, or array thereof
  - An Array of either of the above
  - (#configure is invoked recursively as necessary, so arrays of arrays of names of JSON files, or any arbitrary mixture, usually works.)
  - (nesting Arrays doesn't create nested naming)

Configured resources are available via their `names` within their object type's `category`.

- `image`
  - `image`
- `sprite`
  - `image_sprite`
  - `grid_sheet_sprite`
- `animation`
  - `cyclic_sprite_animation`

#### image_sprite

- `name`
- `image` | `images`
- [ `scale_x`, `scale_y` ]
- [ `center_x`, `center_y` ] 

image_sprite example:

```json
{
    "type": "image_sprite",
    "image": "sprites/smiley.png",
    "name": "smiley_face"
}
```

#### Config Examples


```json
{
    "type": "image_sprite",
    "image": "sprites/smiley.png",
    "name": "smiley_face"
}
// res.get_sprite("smiley_face")
```

```json
{
    "type": "grid_sheet_sprite",
    "name": "girl_run",
    "image": "sprites/girl_sprites.png",
    "tile_grid": {
        "x": 0,
        "y": 36,
        "w": 36,
        "h": 36,
        "count": 8,
        "stride": 3
    }
}
// res.get_sprite("girl_run")
```

```json
{
    "name": "girl_run",
    "type": "cyclic_sprite_animation",
    "sprite": "girl_run",
    "fps": 24
}
// res.get_animation("girl_run")
```



#### Custom Resources

You can define your own type of named resources and configure them through the same channels you'd configure built-ins like sprites and animations.

1. Define your resource type via a new class
2. Register your resource as a new object type
3. Configure resources of your new type

Implement your new resource type as a class with these methods:
  - `.category()` - eg, `:animation`, `:sprite`, or even a new categoriy of your own devising
  - `.construct(config, resources)` - this method should extract constructor args from `config` and `resources` and return a new instance of your resource.
  - The set of methods expected of objects in this `category`.
    - Ie, for a `:sprite` you need to implement `#frame_count` and `#image_for_frame(i)`

# ECS

**E**ntity **C**omponent **S**ystem

## Cedar::Entity

[cedar/ecs/entity.rb](lib/cedar/ecs/entity.rb)

## Cedar::EntityStore

[cedar/ecs/entity_store.rb](lib/cedar/ecs/entity_store.rb)

## Cedar::Components

[cedar/ecs/components.rb](lib/cedar/ecs/components.rb)

## Cedar::Systems

[cedar/ecs/systems.rb](lib/cedar/ecs/systems.rb)

## Search - filters, caching

[cedar/ecs/caching_entity_store.rb](lib/cedar/ecs/caching_entity_store.rb)

[cedar/ecs/entity_filter.rb](lib/cedar/ecs/entity_filter.rb)
