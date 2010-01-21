require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "scout_scout"
    gem.summary = %Q{API wrapper for scout.com}
    gem.description = %Q{API wrapper for scout.com}
    gem.email = "jnewland@gmail.com"
    gem.homepage = "http://github.com/jnewland/scout_scout"
    gem.authors = ["Jesse Newland"]
    gem.add_development_dependency "rspec", "= 1.2.9"
    gem.add_development_dependency "fakeweb"
    gem.add_dependency "hashie", "~> 0.1.8"
    gem.add_dependency "httparty", "~> 0.5.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
$LOAD_PATH.unshift 'lib'
require 'scout_scout/version'
Rake::RDocTask.new do |rdoc|
  version = ScoutScout::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "scout_scout #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
