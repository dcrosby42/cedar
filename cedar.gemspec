version = File.read("VERSION").strip

Gem::Specification.new do |s|
  s.name = "cedar"
  s.version = version
  s.platform = Gem::Platform::RUBY
  s.summary = "For building games!"
  s.description = "Gosu-based, with Entity-Component-System framework and Elm-inspired modules"
  s.author = "David Crosby"
  s.email = "dcrosby42@gmail.com"
  s.homepage = "http://github.com/dcrosby42"
  s.files = Dir["README.md", "VERSION", "Gemfile", "Rakefile", "lib/**/*"]
  s.require_path = "lib"
  s.add_dependency "gosu", "~>1.2.0"
  s.add_dependency "activesupport", "~>6.1.3.1"
end
