$:.push File.dirname(__FILE__) + '/lib'
require 'taglish/version'

Gem::Specification.new do |gem|
  gem.name = %q{taglish}
  gem.authors = ["Paul A. Jungwirth"]
  gem.date = %q{2012-10-08}
  gem.description = %q{Lets you add tags of various types to your models, including scored tags.}
  gem.summary = "Scored tagging for Rails."
  gem.email = %q{pj@illuminatedcomputing.com}
  gem.homepage      = ''

  gem.add_runtime_dependency 'rails', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'mysql2', '~> 0.3.7'
  gem.add_development_dependency 'pg'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "taglish"
  gem.require_paths = ['lib']
  gem.version       = Taglish::VERSION
end
