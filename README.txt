= README.txt

Release: $Release$

$Copyright$

http://rubyforge.org/projects/cgialt/


==  About

'CGIAlt' is an alternative library of standard 'cgi.rb'.
It is written in pure Ruby but works faster than 'cgi.rb'.


== Features

* Compatible with 'cgi.rb'.
* Faster and more lightweight than 'cgi.rb'.
* Available to install with CGIExt (which is a re-implementation of 'cgi.rb'
  in C extension).
* FastCGI support


==  Install

Download cgialt-$Release$.tar.gz and install it according to the following:

    $ tar xzf cgialt-$Release$.tar.gz
    $ cd cgialt-$Release$/
    $ ruby setup.rb config
    $ ruby setup.rb setup
    $ sudo ruby setup.rb install

Or if you have installed RubyGems, you can install CGIAlt by 'gem' command.

    $ sudo gem install cgialt

It is recommended not to use RubyGems if you have to develop CGI program
because loading RubyGems is very heavy-weight for CGI program.


==  Usage

All you have to do is to require 'cgialt' instead of 'cgi', and you can use
CGI class which is compatible with 'cgi.rb'.

   require 'rubygems'   # if you have installed with RubyGems
   require 'cgialt'

If you want to use CGIAlt with FastCGI (fcgi.rb), require 'cgialt/fcgi'
instead of 'fcgi'.

   require 'cgialt'
   require 'cgialt/fcgi'

If you want to replace original 'cgi.rb' entirely by 'cgialt',
create 'cgi.rb' which requires 'cgialt' under proper directory such as
'/usr/local/lib/ruby/site_ruby/1.8'.

   $ sudo echo 'require "cgialt"' > /usr/local/lib/ruby/site_ruby/1.8/cgi.rb
   $ sudo echo 'require "cgialt/fcgi"' > /usr/local/lib/ruby/site_ruby/1.8/fcgi.rb

When $DEBUG is true or ENV['DEBUG'] is set, CGIAlt prints release number
to $stderr when loaded.

   $ DEBUG=1 ruby -e 'require "cgi"'
   *** CGIAlt: release $Release$


== Benchmark

Try 'bench.rb' included in CGIAlt archive.
The following is an example of benchmark.

    ## cgi.rb
    $ ruby -s bench.rb -N=1000
    *** 1000 times                         user    system     total       real
    ruby -e 'nil'                        0.0900    0.8300   11.5400 (  11.9631)
    ruby -e 'require "cgi"'              0.1000    1.2400   24.7000 (  25.2709)
    
    *** 100000 times                       user    system     total       real
    CGI#new (simple)                    20.3100    0.0300   20.3400 (  20.3770)
    CGI#new (complex)                   26.5800    0.0400   26.6200 (  26.6604)
    
    *** 1000000 times                      user    system     total       real
    CGI#header (simple)                 12.6700    0.0100   12.6800 (  12.7137)
    CGI#header (complex)                43.4600    0.0600   43.5200 (  43.5749)

    ## CGIAlt
    $ ruby -s bench.rb -N=1000 -cgialt
    *** CGIAlt: release 0.0.0
    *** 1000 times                         user    system     total       real
    ruby -e 'nil'                        0.0900    0.8000   11.5900 (  12.0581)
    ruby -e 'require "cgi"'              0.1000    1.2300   19.4800 (  20.0621)
    
    *** 100000 times                       user    system     total       real
    CGI#new (simple)                    14.5000    0.0300   14.5300 (  14.5594)
    CGI#new (complex)                   20.0700    0.0300   20.1000 (  20.1356)
    
    *** 1000000 times                      user    system     total       real
    CGI#header (simple)                  6.0400    0.0100    6.0500 (   6.0553)
    CGI#header (complex)                36.2200    0.0400   36.2600 (  36.3138)


It is good thing for performance to install CGIExt as well as CGIAlt.
The following is a benchmark example of using both CGIAlt and CGIExt.

    ## CGIAlt and CGIExt
    $ ruby -s bench.rb -N=1000 -cgialt -cgiext
    *** CGIAlt: release 0.0.0
    *** 1000 times                         user    system     total       real
    ruby -e 'nil'                        0.0900    0.8100   11.6600 (  12.1769)
    ruby -e 'require "cgi","cgiext"'     0.1000    1.2100   20.8400 (  21.5575)
    
    *** 100000 times                       user    system     total       real
    CGI#new (simple)                    12.4200    0.0400   12.4600 (  12.5207)
    CGI#new (complex)                   13.1600    0.0300   13.1900 (  13.2443)
    
    *** 1000000 times                      user    system     total       real
    CGI#header (simple)                  6.0300    0.0100    6.0400 (   6.0651)
    CGI#header (complex)                36.5400    0.0800   36.6200 (  37.0642)


The following is a summary of above benchmark results.

    Table 1. summary of benchmark
                                       cgi.rb      CGIAlt        CGIAlt+CGIExt
    ---------------------------------------------------------------------------
    require "cgi"         (x1000)       13.16      7.89 ( 67%)      9.18 ( 43%)
    CGI#new (simple)      (x100000)     20.34     14.53 ( 40%)     12.46 ( 63%)
    CGI#new (comple)      (x100000)     26.62     20.10 ( 32%)     13.19 (102%)
    CGI#header (simple)   (x1000000)    12.68      6.05 (110%)      6.04 (110%)
    CGI#header (complex)  (x1000000)    43.52     36.26 ( 20%)     36.62 ( 19%)


Another benchmark script 'bench.fcgi' is provided. It is for FastCGI.
The following is an example result of benchmark.

    Table 2. result of bench.fcgi
                                   Time taken for tests     Request per second
    --------------------------------------------------------------------------
    cgi    + fcgi                          16.686 [sec]        1198.61 [#/sec]
    cgialt + cgialt/fcgi                   15.562 [sec]        1285.18 [#/sec]
    cgialt + cgialt/fcgi + cgiext          15.310 [sec]        1306.34 [#/sec]


== License

Ruby's license


== Author

makoto kuwata <kwa(at)kuwata-lab.com>


== Bug reports

If you have bugs or questions, report them to kwa(at)kuwata-lab.com.
