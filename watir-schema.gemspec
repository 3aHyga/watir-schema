# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'watir/schema/version'

Gem::Specification.new do |spec|
   spec.name          = "watir-schema"
   spec.version       = Watir::Schema::VERSION
   spec.authors       = ["Malo Skrylevo"]
   spec.email         = ["majioa@yandex.ru"]
   spec.description   = %q{The gem is able to run around the clock with report at least every hour. Run of the script can be done with any scheduler like cron}
   spec.summary       = %q{The gem allows automated surfing over web using watir-webdriver}
   spec.homepage      = "https://github.com/3aHyga/watir-schema"
   spec.license       = "MIT"
 
   spec.files         = `git ls-files`.split($/)
   spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
   spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
   spec.require_paths = ["lib"]
 
   spec.add_dependency 'bundler', '~> 1.3.1'
   spec.add_dependency 'watir-webdriver', '~> 0.6.2'
   spec.add_dependency 'micro-optparse'
   spec.add_dependency 'rdoba'

   spec.add_development_dependency "bundler", "~> 1.3"
   spec.add_development_dependency "rake"
end
