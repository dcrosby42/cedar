class Cedar::Resources::SpriteAnimation
  def self.category
    :animation
  end

  def self.construct(config:, resources:)
    new(
      name: config[:name],
      sprite_name: config[:sprite],
      fps: config[:fps],
      frame_count: resources.get_sprite(config[:sprite]).frame_count,
      looping: !!config[:looping],
      hold_ends: !!config[:hold_ends],
    )
  end

  def initialize(name:, sprite_name:, fps:, frame_count:, looping:, hold_ends:)
    @name = name
    @sprite_name = sprite_name
    @fps = fps
    @frame_count = frame_count
    @looping = looping
    @hold_ends = hold_ends
  end

  def call(t)
    sprite = @sprite_name
    frame = (t * @fps).to_i
    if @looping
      frame %= @frame_count
    else
      if frame < 0
        if @hold_ends
          frame = 0
        else
          # not holding; render nothing
          sprite = nil
          frame = nil
        end
      elsif frame > @frame_count - 1
        if @hold_ends
          frame = @frame_count - 1
        else
          # not holding; render nothing
          sprite = nil
          frame = nil
        end
      end
    end
    [sprite, frame]
  end
end
