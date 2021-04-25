**Cedar**

- [Getting Started](#getting-started)
- [Examples](#examples)
- [Concepts](#concepts)
  - [Modules](#modules)
    - [Module State](#module-state)
- [API](#api)
  - [Input](#input)
    - [Time](#time)
    - [Keyboard](#keyboard)
    - [Mouse](#mouse)
  - [Output](#output)
    - [Cedar::Draw::Rect](#cedardrawrect)
    - [Cedar::Draw::RectOutline](#cedardrawrectoutline)
    - [Cedar::Draw::Line](#cedardrawline)
    - [Cedar::Draw::Image](#cedardrawimage)
    - [Cedar::Draw::SheetSprite](#cedardrawsheetsprite)
    - [Cedar::Draw::Label](#cedardrawlabel)
    - [Cedar::Draw::Group](#cedardrawgroup)
    - [Cedar::Draw::Translate < Group](#cedardrawtranslate--group)
    - [Cedar::Draw::Scale < Group](#cedardrawscale--group)
  - [Resources](#resources)
    - [Resource Configs](#resource-configs)
      - [Custom Resources](#custom-resources)
- [ECS](#ecs)

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

## Input 

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

### Cedar::Draw::Image

```ruby
output.graphics << Image.new(image:Gosu::Image, path:"sprites/smiley.gif", x:20, y:100, z:101, scale_x:1.0, scale_y:1.0, subimage:[subx,suby,subw,subh]) do
```

### Cedar::Draw::SheetSprite

```ruby
output.graphics << SheetSprite.new(sprite_id: "sprites/wizard.png", sprite_frame:5, x:0, y:0, z:99, angle:0, center_x:0, center_y:0, scale_x:1, scale_y:1) do
```

### Cedar::Draw::Label

```ruby
output.graphics << Label.new(text: "You have: No tea.", font:Gosu::Font.new(20), x:0, y:0, z:0, scale_x:1, scale_y:1, color:Gosu::Color::WHITE) do
```

### Cedar::Draw::Group

- group.clear()
- group.add(drawable)
  - alias: `concat`
  - alias: `<<`

```ruby
group = Group.new do |g|
  g << Rect.new(x:5, y:5, z:99, color:Gosu::Color.rgba(0, 0, 0, 80))
  g << Label.new(text: "LogZ!", x:5, y:5, z: 100)
end
output.graphics << group
```

### Cedar::Draw::Translate < Group

```ruby
moved = Translate.new(5,5) do |g|
  g << Rect.new(x:0, y:0, z:99, color:Gosu::Color.rgba(0, 0, 0, 80))
  g << Label.new(text: "LogZ!", x:0, y:0, z: 100)
end
output.graphics << moved
```

### Cedar::Draw::Scale < Group

```ruby
scaled = Scale.new(2.0, 2.0) do |g|
  g << Rect.new(x:0, y:0, z:99, color:Gosu::Color.rgba(0, 0, 0, 80))
  g << Label.new(text: "LogZ!", x:0, y:0, z: 100)
end
output.graphics << scaled
```

## Resources

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
tbd

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