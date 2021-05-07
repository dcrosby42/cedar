class Cedar::Resources::Sound < Struct.new(:name, :sample, :pan, :volume, :speed, :looping)
  def self.category
    :sound
  end

  def self.construct(config:, resources:)
    sample = resources.loader.load_sound(config[:sound])
    new(
      name,
      sample,
      config[:pan] || 0,
      config[:volume] || 1,
      config[:speed] || 1,
      config[:looping] || false,
    )
  end

  def play(pan = nil, volume = nil, speed = nil, looping = nil)
    sample.play_pan(
      pan || self.pan,
      volume || self.volume,
      speed || self.speed,
      looping || self.looping,
    )
  end
end
