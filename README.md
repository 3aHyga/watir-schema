# Watir::Schema

[![Dependency Status](https://gemnasium.com/3aHyga/watir-schema.png)](https://gemnasium.com/3aHyga/watir-schema)
[![Gem Version](https://badge.fury.io/rb/watir-schema.png)](http://rubygems.org/gems/watir-schema)
[![Build Status](https://travis-ci.org/3aHyga/watir-schema.png?branch=master)](https://travis-ci.org/3aHyga/watir-schema)
[![Coverage Status](https://coveralls.io/repos/3aHyga/watir-schema/badge.png)](https://coveralls.io/r/3aHyga/watir-schema)
[![Endorse Count](http://api.coderwall.com/3aHyga/endorsecount.png)](http://coderwall.com/3aHyga)

Support multiple platforms (Windows, OS X, etc.) and browsers (Chrome, Firefox, Safari, IE, etc.):
 - Chrome
 - Firefox
 - IE (no proxy support)
 - Safari (no proxy support)

The tool is able to run around the clock with report at least every hour. Run of the script can be done with any scheduler like cron.

Functions:
 - Launch a web surfer that will:
  - Allow to use a proxy on 8080 port;
  - Do a deep surf using the specified schema, including, for example, authenticated browsing on numerous websites, interacting with web forms, and random exploration of webpages;
  - Return the browser's work folder;
  - Store all of the surf data in a programmatically searchable log file immediately upon completion of the automated web surfing;
 - Store the log results to the body of an email and send the results to the specified address at the end of each surf;

## Requirements

###Linux/MacOSX:
 - chromedriver: http://code.google.com/p/selenium/wiki/ChromeDriver

###Windows:

 - autohotkey.exe: http://www.autohotkey.com/
 - IEDriverServer.exe: http://code.google.com/p/selenium/wiki/InternetExplorerDriver
 - chromedriver.exe: http://code.google.com/p/selenium/wiki/ChromeDriver

All Programs must be included in PATH variable.

## Installation

Add this line to your application's Gemfile:

    gem 'watir-schema'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install watir-schema

Then execute the rake task :env that should automatically prepare environment, and install all requirements:

    $ rake env

## Usage

Sample run:

    $ watir-schema -v 5 -s schema.yaml -d ~/ -e sample@gmail.com

This will set log level 5 (extremely excessive), surf the web using schema.yaml config, and store browser data in the '~/' folder, and then send report to collected log specified sample@gmail.com.

Help info on the tool:

    $ watir-schema -h
    This is a watir-schema script, how to use it see below
       -v, --verbose 1                  enable verbose output, values: 0 to 5
       -s, --schema                     set schema YAML-file to proceed
       -b, --browser firefox            use browser to surf, values: msie|firefox|chrome|safari
       -p, --[no-]proxy                 use proxy
       -d, --dir                        set base dir to store results
       -t, --store                      store web-browser state into a folder
       -e, --email                      set an email to report test results
       -l, --log                        set output flow to a file
       -h, --help                       Show this message
       -V, --version                    Print version
    
## File schema.yaml

Sample schema.yaml is shewn below:

    ---
    report:
      server: smtp.gmail.com
      port: 587
      domain: domain.com
      login: login@domain.com
      tls: true
      password: 'password'
      auth_type: :plain # or :plain or :login or :cram_md5
      from: 'login@domain.com'
      from_name: 'Name of User'
      body: ! "From: %from_name <%from>\n
        Subject: Watir web-surfing report"
    sites:
      google.com:
        schema:
          - 'a:id:gb_70:%C'
          - 't:id:Email:%S=login@domain.com='
          - 't:id:Passwd:%S=password='
          - 'i:id:signIn:C'
          - 't:name:q:%S=2012 Audi A6='
          - 'b:name:btnG:C'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

