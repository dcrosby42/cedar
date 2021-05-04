class Cedar::Resources::GridSheetSprite < Cedar::Resources::BaseSprite
  attr_reader :image, :image_path, :tile_grid # for dev and debug of spritesheets

  def initialize(name:, image:, grid: nil, tile_grid: nil, scale_x: nil, scale_y: nil, center_x: nil, center_y: nil)
    super name: name, scale_x: scale_x, scale_y: scale_y, center_x: center_x, center_y: center_y
    @image = image
    @tile_grid = grid || tile_grid || open_struct # x y w h count stride
    @tile_grid.x ||= 0
    @tile_grid.y ||= 0
    @tile_grid.w ||= @image.width.to_i
    @tile_grid.h ||= @image.height.to_i
    @tile_grid.count ||= 1
    @tile_grid.stride ||= @tile_grid.count
    @subs = []
  end

  def frame_count
    @tile_grid.count
  end

  def image_for_frame(i)
    i = i.to_i % frame_count
    @subs[i] ||= begin
        left = @tile_grid.x + @tile_grid.w * (i % @tile_grid.stride)
        top = @tile_grid.y + @tile_grid.h * (i / @tile_grid.stride)
        @image.subimage(left, top, @tile_grid.w, @tile_grid.h)
      end
  end

  def self.category
    :sprite
  end

  def self.construct(config:, resources:)
    new(
      name: config[:name],
      tile_grid: open_struct(config[:grid] || config[:tile_grid]), # tile_grid is from early dev, deprecated
      image: resources.get_image(config[:image]),
    )
  end
end
