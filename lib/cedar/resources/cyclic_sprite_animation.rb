class Cedar::Resources::CyclicSpriteAnimation
  def self.category
    :animation
  end

  def self.construct(config:, resources:)
    Cedar::Resources::SpriteAnimation.construct(config: config, resources: resources)
  end
end
