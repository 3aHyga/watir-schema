require 'watir'
require 'watir-webdriver'
require 'fileutils'
require 'open3'
require 'yaml'
require 'timeout'
require 'net/smtp'

module Watir
   class Browser
      module Firefox
         def browser_run options
            b = Watir::Browser.new :firefox, options
            profile_dir = b.driver.send( :bridge ).
                  instance_variable_get( :@launcher ).
                  instance_variable_get( :@profile_dir )
            [ b, [ profile_dir ].freeze ] ; end

         def browser_init browser, proxy = false
            profile = Selenium::WebDriver::Firefox::Profile.new
            profile.native_events = true
            @options = { :profile => profile }
            if proxy
               @options.merge :proxy => { :http => "http://localhost:8080" } ; end

            @b, @profile_data = browser_run @options ; end ; end

      module Chrome
         def browser_init browser, proxy = false
            @profile_data = [ File.join( @path, 'profile' ) ].freeze
            switches = [ "--user-data-dir=#{@profile_data.last}" ]
            if proxy
               switches << "--proxy-server=localhost:8080" ; end
            @options = { :switches => switches }
            @b = Watir::Browser.new :chrome, @options ; end ; end

      module Msie
         def browser_init browser, proxy = false
            clear_current_state
            # MSIE has no plain proxy settings
            si, so, se, @wthr = Open3.popen3( "AutoHotkey " +
                  "\"#{fix_path Watir::Schema.root( "share/msie_err_control.ahk" )}\"" )
            @b = Watir::Browser.new :ie ; end ; end

      module Safari
         def browser_init browser, proxy = false
            clear_current_state
            # Safari has no plain proxy settings
            @b = Watir::Browser.new :safari
            end ; end

      module Opera
         def browser_init browser, proxy = false
            # http://code.google.com/p/selenium/wiki/OperaDriver
	    # Opera driver have no proxy caps
            @profile_data = [ File.join( @path, 'profile' ) ].freeze
            @b = Watir::Browser.new :opera, { :profile => @profile_data.last }
	end ; end ; end

   class Schema
      Actions = {
            's' => '.select_list',
            'o' => '.option',
            't' => '.text_field',
            'a' => '.a',
            'i' => '.input',
            'b' => '.button',
            'c' => '.checkbox',
            'f' => '.form',
            'd' => '.div',
            'p' => '.span',
            'e' => '.element',
            '%' => '.when_present',
            'L' => '.select',
            'S' => '.set',
            'C' => '.click',
            'T' => '.text',
         }
      AKeys = Actions.keys.join().gsub(/[?]/) do |e| "\\#{e}" ; end

      def self.root path = ''
         root = File.expand_path '../../..', __FILE__
         File.join root, path
      end

      def initialize settings, browser = 'firefox', basedir = nil
         # Initialize browser
         @browser = browser.to_sym
         if ![ :chrome, :firefox, :msie, :opera, :safari ].include? @browser
            raise "#{@browser.inspect} isn't supported" ; end
         @browser_settings = settings[ 'browsers' ][ @browser.to_s ]
         eval "extend Browser::#{@browser.capitalize}"
         log * { Browser: browser }

         # Initialize paths for data logs
         basedir = !basedir.empty? && basedir || ENV[ 'TMP' ]
         @path = File.join( basedir, 'watir-scheme', ::Time.now.strftime('%m-%d-%Y'),
               "#{browser.capitalize}-#{::Time.now.strftime("%H_%M_%S")}" )
         log * { Path: @path }
         FileUtils.mkdir_p @path

         # Initialize timeouts
         @load_timeout = @browser_settings[ 'timeouts' ] &&
               @browser_settings[ 'timeouts' ][ 'load' ] || settings[ :timeouts ] &&
               settings[ :timeouts ][ :load ] || 60
         @automate_timeout = @browser_settings[ 'timeouts' ] &&
               @browser_settings[ 'timeouts' ][ 'automate' ] ||
               settings[ :timeouts ] && settings[ :timeouts ][ :automate ] || 600

         # Data folders to store
         ( @browser_settings[ 'data' ] || {} ).each do |os, data|
            if Watir.os =~ /#{os}/
               @profile_data = data ; end ; end

         # Store settings
         log >> { Settings: settings }
         @settings = settings ; end

      def crawl schema, proxy, storedir
         log + { schema: schema, proxy: proxy, storedir: storedir }

         #Initialize testing variables
         pid = nil

         #Initialize browser
         browser_init @browser,
               proxy && ( schema[ :proxy ] || settings[ :proxy ] )

         #Begin web crawl
         surf schema[ 'sites' ] || []
         if storedir && !storedir.empty?
            store_state storedir ; end
      ensure
         if @b
            # close browser
            @b.close rescue nil ; end ; end

      def report schema, email, io, l = nil
         if io == $stdout || !email || email.empty?
            return ; end

         rep = schema[ 'report' ]
         status = ''
         smtp = Net::SMTP.new rep[ 'server' ], rep[ 'port' ]
         if rep[ 'tls' ]
            smtp.enable_starttls ; end
         io.rewind
         begin
            smtp.start( rep[ 'domain' ],
                  rep[ 'login' ], rep[ 'password' ], rep[ 'auth_type' ] ) do |s|
               msg = rep[ 'body' ].gsub( /%[_\w]+/ ) do |str|
                  rep[ str.sub( '%', '' ) ] ; end.split( "\n" ).map do |x|
                  x.strip end.join( "\n")
               msg << "\nTo: #{email}\n\nThe log is below:\n\n"
               msg << io.read
               s.send_message msg, rep[ 'from' ], email
            end
            status = "Report has been sent"
         rescue
            log.e
            status = "It is unable to send the log"
            l = true ; end

         if l && !l.empty?
            io.rewind
            $stdout.puts io.read ; end
         $stdout.puts status ; end

   private

      def fix_path path
         if Watir.os =~ /windows/
            path.gsub!( /\//, "\\" ) ; end
         path ; end

      def is_fullpath? path
         if Watir.os =~ /windows/
            path[ 1 ] == ':' && ( path[ 2 ] == "\\" || path[ 2 ] == '/' )
         else
            path[ 0 ] == '/' ; end ; end

      def store_state folder = nil
         log + { folder: folder }
         target_base = folder
         target_dir = target_base
         log > "Storing browser state to #{target_dir}"
         home = Dir.home
         init = if @profile_data.is_a? Hash
               Proc.new do |dir|
                  source = dir[ 1 ]
                  Dir.chdir( is_fullpath?( source ) && source ||
                        File.join( home, source ) )
                  target_dir = File.join target_base, dir[ 0 ] ; end
            else
               Proc.new do |dir|
                  Dir.chdir( is_fullpath?( dir ) && dir ||
                        File.join( home, dir ) ) ; end ; end

         @profile_data.each do |dir|
            init.call dir
            Dir.glob( File.join '**', '*' ).each do |file|
               tfile = File.join( target_dir, file )
               FileUtils.mkdir_p( File.dirname tfile )
               FileUtils.cp_r( file, tfile ) rescue Exception
               end ; end

         clear_current_state ; end

      def clear_current_state
         if @profile_data.frozen?
            return ; end

         home = Dir.home
         init = if @profile_data.is_a? Hash
               Proc.new do |dir|
                  source = dir[ 1 ]
                  Dir.chdir( is_fullpath?( source ) && source ||
                        File.join( home, source ) ) ; end
            else
               Proc.new do |dir|
                  Dir.chdir( is_fullpath( dir ) && dir ||
                        File.join( home, dir ) ) ; end ; end

         @profile_data.each do |dir|
            init.call dir
            list = Dir.glob '*'
            list.delete 'index.dat'
            FileUtils.rm_rf list rescue Exception ; end ; end

      def surf sites
         log + { :sites => sites }
         b = @b
         log >> { :b => b }
         sites.each do |site, opts|
            log > { Site: site }
            log >> { Opts: opts }

            uri = site + ( opts[ 'path' ] || '' )
            log > { uri: uri }
            begin
               Timeout::timeout( @load_timeout ) do
                  b.goto uri ; end
            rescue Timeout::Error
               log % "Error: can't complete the site #{uri} surfing"
               next ; end

            schema = opts[ 'schema' ]
            log > "#{schema.size} steps in the schema for the site have found"
            schema.each do |act|
               log >> { act: act }
               e = 'b'
               while act.size > 0
                  if act =~ /^(?:([@?#{AKeys}])|(:([\w\-]+):([^:]+):)|([\(=`~](.*[^\\\)=`~])[\)=`~]))/
                     log >> { Matches: [ $1, $2, $3, $4, $5, $6 ] }
                     if $1
                        case $1
                        when '@'
                           e = "Watir::Wait.until(@automate_timeout) {(#{e})}"
                        when '?'
                           e = "(#{e}) if b"
                        else
                           e << Actions[ $1 ] ; end
                        act = act[ 1..-1 ]
                     elsif $2
                        e << "(:'#{$3}'=>'#{$4}')"
                        act = act[ $2.size..-1 ]
                     elsif $5
                        match = $5
                        word = $6.gsub( /\\(.)/, '\1' )
                        case match[ 0 ]
                        when '~'
                           e << " =~ /#{word}/"
                        when '='
                           e << "('#{word}')"
                        when '('
                           e = "sleep (#{word}); #{e}"
                        else
                           e << " !~ /#{word}/" ; end
                        act = act[ match.size..-1 ] ; end
                  else
                     log.e "Unknown operation #{act[ 0 ]} in schema part: #{act}"
                     act = act[ 1..-1 ] ; end ; end
               log > "Step: eval #{e}"
               begin
                  Timeout::timeout( @automate_timeout ) do
                     eval e ; end
               rescue Timeout::Error
                  log > "Error: We didn't wait out the Opt-out analyzing completed"
               rescue Watir::Wait::TimeoutError;
                  log > "Error: Can't execute #{e}"
               rescue Interrupt
                  return nil
               rescue Exception
                  log.e
                  end ; end ; end

         true ; end ; end ; end

