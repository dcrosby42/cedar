module Cedar
  # Provide a privacy guard around all the Gosu magic
  # and Cedar methods the game window truly posesses,
  # providing a limited view on certain helpful tidbits
  # to modules during update and draw phases.
  class WindowWrapper
    def initialize(window)
      @window = window
    end

    def width; @window.width; end
    def height; @window.height; end

    # more?
  end
end
