#!/usr/local/bin/ruby

##
## example:
##   $ ab -n 20000 -c 5 'http://localhost:80/bench.fcgi?name=%40%21%7C+%2A%3F'
##


#require 'cgi'; require 'fcgi'
require 'cgialt'; require 'cgialt/fcgi'
#require 'cgiext'

FCGI.each_cgi do |cgi|
  #begin
    name = cgi['name']
    name = 'World' if name.empty?
    print cgi.header('text/html')
    print "<html><body><h1>Hello #{CGI.escapeHTML(name)}</h1></body></html>\n"
  #rescue Exception => ex
  #  print cgi.header('text/plain')
  #  puts "*** ERROR: #{ex}"
  #  ex.backtrace.each do |item|
  #    puts "    from #{item}"
  #  end
  #end
end
