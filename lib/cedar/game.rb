class Cedar::Game < Gosu::Window
  def initialize(root_module:, caption: nil, width: 1280, height: 720, fullscreen: false, update_interval: nil, mouse_pointer_visible: false, reload_button: Gosu::KB_R)
    super width, height
    self.caption = caption || (root_module.name if root_module.respond_to?(:name)) || "Game"
    @fullscreen = fullscreen
    self.fullscreen = @fullscreen
    self.update_interval = update_interval if update_interval
    @mouse_pointer_visible = false
    @reload_button = reload_button

    win_wrapper = Cedar::WindowWrapper.new(self)
    @input = Cedar::Input.new(win_wrapper)
    @output = Cedar::Output.new(win_wrapper)

    @module = root_module
    reset_state
  end

  def reset_state
    @state = @module.new_state
    @res = new_resources
    @res.configure(@module.resource_config) if @module.respond_to?(:resource_config)
  end

  def new_resources
    resource_loader = Cedar::Resources::ResourceLoader.new(dir: "res")
    res = Cedar::Resources.new(resource_loader: resource_loader)
    [
      Cedar::Resources::ImageSprite,
      Cedar::Resources::GridSheetSprite,
      Cedar::Resources::CyclicSpriteAnimation,
      Cedar::Resources::Font,
    ].each do |c|
      res.register_object_type c
    end

    res.configure({
      type: "font",
      name: "default",
      font: nil, # invoke Gosu's default font
      size: 20,
    })

    res
  end

  def start!
    puts "Starting #{self.caption}"
    show
  end

  def update
    check_for_reload_code
    check_for_reset_state

    @input.time.update_to Gosu.milliseconds

    s1, sidefx = @module.update(@state, @input, @res)
    @state = s1 unless s1.nil?
    @input.keyboard.after_update
    handle_sidefx sidefx
  end

  def handle_sidefx(sidefx)
    case sidefx
    when Array
      sidefx.each(&method(:handle_sidefx))
    when Cedar::Sidefx::ToggleFullscreen
      @fullscreen = !@fullscreen
      puts "Toggle fullscreen => #{@fullscreen}"
      self.fullscreen = @fullscreen
    when Cedar::Sidefx::ReloadCode
      reload_code
    when Cedar::Sidefx::ResetState
      reset_state
    end
  end

  def draw
    @output.reset
    @module.draw(@state, @output, @res)
    @output.graphics.draw(@res)
  end

  def button_down(id)
    @input.keyboard.button_down(id)
  end

  def button_up(id)
    @input.keyboard.button_up(id)
  end

  def needs_cursor?
    return @mouse_pointer_visible
  end

  # Unused (for now) Gosu callback
  # def needs_redraw?
  #   super
  # end

  # def drop
  #   super
  # end

  def close
    super
  end

  def reload_code
    if AutoReload.reload_all
      puts "Code reloaded"
      return true
    end
    false
  end

  def check_for_reload_code
    if @reload_button && @input.keyboard.pressed?(@reload_button) && @input.keyboard.control?
      puts "Code reload requested"
      return reload_code
    end
    false
  end

  def check_for_reset_state
    if @reload_button && @input.keyboard.pressed?(@reload_button) && @input.keyboard.shift?
      puts "State reset"
      reset_state
      return true
    end
    false
  end
end
