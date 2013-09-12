#!/usr/bin/env rake

desc "Prepare bundler"
task :prebundle do
   sh 'gem install bundler --version "~> 1.3.1" --no-rdoc --no-ri'
end

desc "Prepare bundle environment"
task :pre do
   sh 'bundle install'
end

desc "Requires"
task :req do
   $: << File.expand_path( '../lib', __FILE__ )
   require 'bundler/gem_helper'
   require 'watir'

   Bundler::GemHelper.install_tasks
end

desc "Prepare environment"
task :env do
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
task :gem do
   sh 'gem build watir-schema.gemspec'
   sh "gem install watir-schema-#{Watir::Schema::VERSION}.gem"
end

desc "Distilled clean"
task :distclean do
   sh 'git clean -fd'
   sh 'rm -rf $(find -iname "*~")'
end

task(:default).clear
task :default => :pre
task :release => [ :req ]
task :env => [ :req ]
task :gem => [ :req ]
task :build => [ :prebundle, :pre, :gem ]
task :all => [ :build, :env ]

