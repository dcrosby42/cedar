#!/usr/bin/env ruby
require "bundler/setup"
require "cedar"

module LabelExample
  extend self

  def new_state
    {
      words: "Welcome to the Cedar grove!",
      x: 0, y: 0,
      dx: 100, dy: 150,
      color: Gosu::Color::WHITE,
      border_color: Gosu::Color::RED,
    }
  end

  def update(state, input, res)
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

    # movement
    state[:x] += state[:dx] * input.time.dt
    state[:y] += state[:dy] * input.time.dt
    state[:dx] *= -1 if state[:x] > 200 || state[:x] < 0
    state[:dy] *= -1 if state[:y] > 400 || state[:y] < 0
    state
  end

  def draw(state, output, res)
    output.graphics << Cedar::Draw::Label.new(text: "(hit SPACE)", color: Gosu::Color.rgba(255, 255, 255, 80))
    output.graphics << Cedar::Draw::Label.new(x: state[:x], y: state[:y], text: state[:words], color: state[:color])
    output.graphics << Cedar::Draw::RectOutline.new(x: 1, y: 1, w: 210, h: 410, color: state[:border_color])
  end
end

Cedar::Game.new(
  root_module: LabelExample,
  caption: "01: A bouncing label",
).start!
