#!/usr/bin/env rake

desc "Prepare bundler"
task :bundleup do
  sh 'gem install bundler --version "~> 1.3.1" --no-ri --no-rdoc'
end

desc "Requires"
task :req do
   $: << File.expand_path( '../lib', __FILE__ )
   require 'bundler/gem_helper'
   require 'watir'

   Bundler::GemHelper.install_tasks
end

desc "Prepare bundle environment"
task :up do
  sh 'bundle install'
end

desc "Test with cucumber"
task :test do
  sh 'if [ -d features ]; then tests=$(ls features/*.feature) ; cucumber $tests; fi'
end

desc "Distilled clean"
task :distclean do
   sh 'git clean -fd'
   sh 'cat .gitignore | while read mask; do rm -rf $(find -iname "$mask"); done'
end

desc "Prepare environment"
task :env => [ :req ] do
   files = [ 'http://selenium.googlecode.com/files/selenium-server-2.31.0.zip' ]
   drivers = case RUBY_PLATFORM
         when /linux/
	sh "#{Watir::Schema.root}/share/setup_linux #{Watir::Schema.root}"
            [ RUBY_PLATFORM =~ /64/ && 'chromedriver_linux64_26.0.1383.0.zip' ||
	      'chromedriver_linux32_26.0.1383.0.zip' ]
         when /windows/
	[ RUBY_PLATFORM =~ /64/ && 'IEDriverServer_x64_2.31.0.zip' ||
	      'IEDriverServer_Win32_2.31.0.zip',
	      'chromedriver_win_26.0.1383.0.zip' ]
         when /macosx/
	[ 'chromedriver_mac_26.0.1383.0.zip' ]
         else [] ; end
   drivers.each do |driver|
      files << "http://chromedriver.googlecode.com/files/#{driver}" ; end

   files.each do |file|
      filename = File.basename file
      target = File.join Watir::Schema.root, filename
      sh "wget #{file} -O #{target}"
      sh "7z x #{target}"
   end

   puts "-" * 30 + "\nPlease, reload your environment"
end

desc "Generate gem"
namespace :gem do
  task :build => [ :req ] do
    sh 'gem build watir-schema.gemspec'
  end

  task :install do
    require File.expand_path( '../lib/watir/schema/version', __FILE__ )
    sh "gem install watir-schema-#{Watir::Schema::VERSION}.gem"
  end

  task :publish => [ :req ] do
    require File.expand_path( '../lib/watir/schema/version', __FILE__ )
    sh "git tag v#{Watir::Schema::VERSION}"
    sh "gem push watir-schema-#{Watir::Schema::VERSION}.gem"
    sh "git push"
    sh "git push --tag"
  end

  task :make => [ :build, :install, :publish ]
  task :default => :make
end

task(:default).clear
task :default => :test
task :all => [ :bundleup, :up, :test, :'gem:make', :distclean ]
task :build => [ :bundleup, :up, :test, :'gem:build', :'gem:install', :distclean ]

