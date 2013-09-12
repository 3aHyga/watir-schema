# Watir::Schema

Support multiple platforms (Windows, OS X, etc.) and browsers (Chrome, Firefox, Safari, IE, etc.):
 - Chrome
 - Firefox
 - IE*
 - Safari*
* - no proxy support

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
      domain: networkadvertising.org
      login: monitoring@networkadvertising.org
      tls: true
      password: '#rrrjjhdr@'
      auth_type: :plain #or :plain or :login or :cram_md5
      from: 'monitoring@networkadvertising.org'
      from_name: 'NAI Monitoring'
      body: ! "From: %from_name <%from>\n
        Subject: Watir web-surfing report"
    sites:
      google.com:
        schema:
          - 'a:id:gb_70:%C'
          - 't:id:Email:%S=monitoring@networkadvertising.org='
          - 't:id:Passwd:%S=#rrrjjhdr@='
          - 'i:id:signIn:C'
          - 't:name:q:%S=2012 Audi A6='
          - 'b:name:btnG:C'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
