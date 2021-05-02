module Cedar::Sound
  ChannelCache = {}
  ChannelAccess = []

  # After every game update, check to see if any cached sounds were omitted during the draw phase.
  # Any sound object not (re)drawn need to be stopped and purged.
  def self.cleanup
    return if ChannelCache.empty?
    (ChannelCache.keys - ChannelAccess).each do |key|
      ChannelCache[key].stop
      ChannelCache.delete key
      puts "Cedar::Sound::Effect remove channel #{key} "
    end
    ChannelAccess.clear
  end

  # #play volume speed looping

  Effect = Struct.new(:path, :id, keyword_init: true) do
    def draw(res)
      key = "#{path}_#{id}"
      ch = ChannelCache[key]
      if !ch
        sample = res.get_sound(path)
        ch = sample.play
        puts "Cedar::Sound::Effect play sound #{key} "
        ChannelCache[key] = ch
      end
      ChannelAccess << key
      # TODO update ch attrs? #pause #resume #paused? #playing? #stop
    end
  end
end # Cedar
