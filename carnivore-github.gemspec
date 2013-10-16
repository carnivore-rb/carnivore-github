$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'carnivore-github/version'
Gem::Specification.new do |s|
  s.name = 'carnivore-github'
  s.version = Carnivore::Github::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'https://github.com/heavywater/carnivore-github'
  s.description = 'Carnivore Github source'
  s.require_path = 'lib'
  s.add_dependency 'carnivore', '>= 0.1.8'
  s.add_dependency 'http'
  s.files = Dir['**/*']
end
