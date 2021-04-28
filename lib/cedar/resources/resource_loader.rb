require "json"
require "yaml"

class Cedar::Resources::ResourceLoader
  def initialize(dir: "res")
    @resource_dir = dir
  end

  # Returns a Gosu::Image for the named image file
  def load_image(name, tileable: true, retro: true)
    Gosu::Image.new(get_file_path(name), tileable: tileable, retro: retro)
  rescue
    raise "Cannot load_image #{name.inspect}"
  end

  # Returns the raw content of the given file
  def load_file(name)
    File.read(get_file_path(name))
  rescue
    raise "Cannot load_file #{name.inspect}"
  end

  def load_font(font_file: nil, height: nil, bold: false, italic: false, underline: false)
    height ||= 20
    opts = {
      bold: !!bold,
      italic: !!italic,
      underline: !!underline,
    }
    opts[:name] = get_file_path(font_file) if font_file
    return Gosu::Font.new(height, opts)
  end

  # Returns the parsed data (if name has recognizable file ext,
  # such as .json, .yaml, .yml etc.)
  # Returns raw content if unrecognized.
  def load_data(name)
    text = load_file(name)
    case File.extname(name)
    when ".json"
      JSON.parse(text, symbolize_names: true)
    when ".yaml", ".yml"
      YAML.load(text)
    else
      text
    end
  rescue
    raise "Cannot load_data #{name.inspect}"
  end

  def get_file_path(file)
    name = "#{@resource_dir}/#{file}"
    raise "Resource file doesn't exist: #{name.inspect}" unless File.exists?(name)
    raise "Resource file is actually a dir: #{name.inspect}" if File.directory?(name)
    name
  end
end
