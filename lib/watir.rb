require 'rbconfig'
require 'watir/schema'
require 'watir/schema/version'

module Watir
   def self.os
      @@os ||= (
         host_os = RbConfig::CONFIG['host_os']
         case host_os
         when /(mswin|msys|mingw|cygwin|bccwin|wince|emc)/
            plat = $1 == 'mswin' && 'native' || $1
            out = `ver`.encode( 'US-ASCII',
                  :invalid => :replace, :undef => :replace )
            if out =~ /\[.* (\d+)\.([\d\.]+)\]/
               "windows-#{plat}-#{$1 == '5' && 'xp' || 'vista'}-#{$1}.#{$2}"
            else
               "windows-#{plat}" ; end
         when /darwin|mac os/
            'macosx'
         when /linux/
            'linux'
         when /(solaris|bsd)/
            "unix-#{$1}"
         else
            raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
         end) ; end ; end
