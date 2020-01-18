# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Xuan Cao"]
  gem.email         = ["xcao2@ualberta.ca"]
  gem.description   = %q{Annotation tool that collects and aggregates data from multiple sources}
  gem.summary       = %q{Annotation tool that collects and aggregates data from multiple sources}
  gem.homepage      = "http://xuancao.ca"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "data-scrapper"
  gem.require_paths = ["lib"]
  gem.version       = "1.0.0.1"

  gem.add_dependency('bio')
  gem.add_dependency('wikipedia-client')
  gem.add_dependency('bio-isoelectric_point')
  gem.add_dependency('savon', '~> 2.5.1')
  gem.add_dependency('nokogiri',">= 1.10.4")
  gem.add_dependency('require_all', '~> 1.3.1')
  gem.add_dependency('dalli', '~> 2.6.0')
  gem.add_dependency("libxml-ruby", "~> 2.7.0")
  gem.add_dependency('activesupport', ">= 3.0.0")
  gem.add_dependency('i18n')
  gem.add_dependency('sinatra')
  gem.add_dependency('poltergeist')
  gem.add_dependency('rest-client')
  gem.add_dependency('htmlentities')
  gem.add_dependency('hpricot')
  gem.add_dependency('mechanize', '~> 2.7', '>= 2.7.4')
  gem.add_dependency('parallel')
  gem.add_dependency('httpclient')
  gem.add_dependency('similar_text')
  gem.add_dependency('crack')
  gem.add_dependency('similarity')
  gem.add_dependency('awesome_print')
  gem.add_dependency('guard-rspec')
  gem.add_dependency('optimist')
  gem.add_dependency('gsl')
  gem.add_dependency('kmeans-clusterer')
  gem.add_dependency('scalpel')
  gem.add_dependency('pragmatic_segmenter')
  gem.add_dependency('minitest', '~> 5.8.1')
  gem.add_dependency('ruby-graphviz')
  gem.add_dependency('faker')
  gem.add_dependency('progress_bar')
  gem.add_dependency('rb-gsl', '>=1.16.0')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('pry')
  gem.add_development_dependency('awesome_print')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-minitest')
  gem.add_development_dependency('rb-inotify')
  gem.add_development_dependency('rb-fsevent')
  gem.add_development_dependency('rb-fchange')
  gem.add_development_dependency('terminal-notifier-guard')
  gem.add_development_dependency('rake-compiler')
  
end

  # metbuilder is wishart gem. basically, you install the gem at local first, then add the gem to gemspec
  # so your gem can include this gem's functionalities
  # gem.add_dependency('metbuilder')
