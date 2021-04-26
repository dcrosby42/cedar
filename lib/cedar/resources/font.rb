class Cedar::Resources::Font
  def self.category
    :font
  end

  def self.construct(config:, resources:)
    f = resources.loader.load_font(
      font_file: config[:font],
      height: config[:size],
      bold: config[:bold],
      italic: config[:italic],
      underline: config[:underline],
    )
    f
  end
end
