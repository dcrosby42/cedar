module Cedar::Sound
  ChannelCache = {}
  ChannelAccess = []

  # After every game update, check to see if any cached sounds were omitted during the draw phase.
  # Any sound object not (re)drawn need to be stopped and purged.
  def self.cleanup
    return if ChannelCache.empty?
    (ChannelCache.keys - ChannelAccess).each do |key|
      puts "Cedar::Sound stop #{key}" if Cedar::Sound.debug
      ChannelCache[key].stop
      ChannelCache.delete key
    end
    ChannelAccess.clear
  end

  def self.on; @on; end
  def self.on=(b); @on = b; end

  def self.debug; @debug; end
  def self.debug=(b); @debug = b; end

  self.on = true
  self.debug = false

  # Meets the informal Cedar "drawable" interface
  Effect = Struct.new(:name, :id, :volume, :looping, :speed, :pan, keyword_init: true) do
    # #play volume speed looping
    def draw(res)
      return unless Cedar::Sound.on
      key = "#{name}_#{id}"
      ch = ChannelCache[key]
      if !ch
        snd = res.get_sound(name)
        ch = snd.play(pan, volume, speed, looping)
        ChannelCache[key] = ch
        puts "Cedar::Sound play #{key}" if Cedar::Sound.debug
      end
      ChannelAccess << key
      # TODO update ch attrs? #pause #resume #paused? #playing? #stop
    end
  end
end # Cedar
