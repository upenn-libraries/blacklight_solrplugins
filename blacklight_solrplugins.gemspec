$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "blacklight_solrplugins/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blacklight_solrplugins"
  s.version     = BlacklightSolrplugins::VERSION
  s.authors     = ["Jeff Chiu"]
  s.email       = ["jeffchiu@upenn.edu"]
  s.homepage    = "https://github.com/upenn-libraries/blacklight_solrplugins"
  s.summary     = "Blacklight extension for solrplugins"
  s.description = "Blacklight extension for solrplugins"
  s.license     = "Apache 2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.5.1"
  s.add_dependency "blacklight", "~> 6.0"

  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "sqlite3"
end
