module Cedar
  class Input
    attr_accessor :time, :keyboard, :mouse, :window

    def initialize(window)
      @window = window
      @time = GameTime.new
      @keyboard = Keyboard.new
      @mouse = Mouse.new
    end
  end
end
