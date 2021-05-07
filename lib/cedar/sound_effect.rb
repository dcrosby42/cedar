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
    end
    ChannelAccess.clear
  end

  # Meets the informal Cedar "drawable" interface
  Effect = Struct.new(:name, :id, :volume, :looping, :speed, :pan, keyword_init: true) do
    # #play volume speed looping
    def draw(res)
      key = "#{name}_#{id}"
      ch = ChannelCache[key]
      if !ch
        snd = res.get_sound(name)
        ch = snd.play(pan, volume, speed, looping)
        ChannelCache[key] = ch
      end
      ChannelAccess << key
      # TODO update ch attrs? #pause #resume #paused? #playing? #stop
    end
  end
end # Cedar
