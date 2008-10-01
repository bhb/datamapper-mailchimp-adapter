require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
 
GEM = "dm-mailchimp-adapter"
GEM_VERSION = "1.0.0"
AUTHOR = "MandarinSoda"
EMAIL = ""
HOMEPAGE = "http://mandarinsoda.com"
SUMMARY = "A gem that provides mailchimp api integration via a DataMapper Adapter"
 
spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{lib,specs}/**/*")
end
 
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
 
desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end
 
desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end