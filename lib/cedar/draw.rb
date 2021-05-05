module Cedar
  module Draw
    Rect = Struct.new(:x, :y, :z, :w, :h, :color, :mode, keyword_init: true) do
      def draw(res)
        self.color ||= Gosu::Color::WHITE
        self.x ||= 0
        self.y ||= 0
        self.w ||= 1
        self.h ||= 1
        self.z ||= 0
        self.mode ||= :default
        Gosu.draw_rect(x, y, w, h, color, z, mode)
      end
    end

    RectOutline = Struct.new(:x, :y, :z, :w, :h, :color, :mode, keyword_init: true) do
      def draw(res)
        self.color ||= Gosu::Color::WHITE
        self.x ||= 0
        self.y ||= 0
        self.w ||= 1
        self.h ||= 1
        self.z ||= 0
        self.mode ||= :default
        Gosu.draw_line(x, y, color, x + w, y, color, z, mode)
        Gosu.draw_line(x + w, y, color, x + w, y + h, color, z, mode)
        Gosu.draw_line(x, y, color, x, y + h, color, z, mode)
        Gosu.draw_line(x, y + h, color, x + w, y + h, color, z, mode)
      end
    end

    Line = Struct.new(:x1, :y1, :x2, :y2, :z, :color, :color2, :mode, keyword_init: true) do
      def draw(res)
        c1 = color || Gosu::Color::WHITE
        c2 = color2 || c1
        Gosu.draw_line(x1, y1, c1, x2, y2, c2, z || 100, mode || :default)
      end
    end

    Image = Struct.new(:image, :path, :x, :y, :z, :scale_x, :scale_y, :subimage, keyword_init: true) do
      def draw(res)
        img = image || res.get_image(path || raise("Image needs :image or :path"))
        if subimage
          img = img.subimage(*subimage)
        end
        img.draw(x, y, z || 0, scale_x || 1, scale_y || 1)
      end
    end

    Sprite = Struct.new(:name, :sprite_id, :frame, :sprite_frame, :x, :y, :z, :angle, :center_x, :center_y, :scale_x, :scale_y, keyword_init: true) do
      def draw(res)
        self.name ||= self.sprite_id  # sprite_id is deprecated in favor of name
        return if name.nil? # quietly draw nothing when given nil.  Animations may choose to send nil sprite ids to indicate "nothing"
        sprite = res.get_sprite(self.name)
        self.x ||= 0
        self.y ||= 0
        self.z ||= 0
        self.center_x ||= sprite.center_x || 0
        self.center_y ||= sprite.center_y || 0
        self.scale_x ||= sprite.scale_x || 1
        self.scale_y ||= sprite.scale_y || 1
        img = sprite.image_for_frame(frame || sprite_frame || 0) # sprite_frame is deprecated in favor of frame
        img.draw_rot(x, y, z || 0, angle || 0, center_x, center_y, scale_x, scale_y)
      end
    end
    # Legacy alias
    SheetSprite = Sprite

    Animation = Struct.new(:name, :t, :x, :y, :z, :angle, :center_x, :center_y, :scale_x, :scale_y, keyword_init: true) do
      def draw(res)
        sprite, frame = res.get_animation(name).call(t)
        Sprite.new(name: sprite, frame: frame, x: x, y: y, z: z, angle: angle, center_x: center_x, center_y: center_y, scale_x: scale_x).draw(res)
      end
    end

    Text = Struct.new(:text, :font, :x, :y, :z, :scale_x, :scale_y, :color, keyword_init: true) do
      def draw(res)
        font = self.font || "default"
        f = res.get_font(font)
        f.draw_text(text, x || 0, y || 0, z || 0, scale_x || 1, scale_y || 1, color || Gosu::Color::WHITE)
      end
    end
    # legacy alias
    Label = Text

    # TODO: support 'z' for Group (and Scale and Translate) by applying z (somehow? adding?) to all child elemnents, recursively into other groups)
    class Group
      def initialize(&block)
        @drawables = []
        block.call self if block_given?
      end

      def clear
        @drawables.clear
      end

      def add(dr)
        case dr
        when Array
          @drawables.concat(dr)
        else
          @drawables << dr
        end
      end

      alias_method :concat, :add
      alias_method :<<, :add

      def draw(res)
        @drawables.each do |d|
          if d.respond_to?(:draw)
            d.draw(res)
          elsif d.respond_to?(:call)
            d.call(res)
          else
            raise "Cedar::Draw::Group#draw: Item isn't drawable (needs #draw or #call): #{d.inspect}"
          end
        end
      end

      alias_method :call, :draw
      alias_method :[], :draw
    end

    class Scale < Group
      def initialize(scale_x, scale_y = nil)
        super()
        @scale_x = scale_x
        @scale_y = scale_y || @scale_x
      end

      def draw(res)
        Gosu.scale(@scale_x, @scale_y) do
          super
        end
      end
    end

    class Translate < Group
      def initialize(x, y)
        super()
        @x = x
        @y = y
      end

      def draw(res)
        Gosu.translate(@x, @y) do
          super
        end
      end
    end
  end
end
