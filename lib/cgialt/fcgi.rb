##
## $Rev: 33 $
## $Release: 0.0.2 $
## copyright(c) 2007 kuwata-lab.com all rights reserved.
##

=begin

fcgi.rb 0.8.5 - fcgi.so compatible pure-ruby FastCGI library

fastcgi.rb Copyright (C) 2001 Eli Green
fcgi.rb    Copyright (C) 2002-2003 MoonWolf <moonwolf@moonwolf.com>
fcgi.rb    Copyright (C) 2004 Minero Aoki

=end


trap('SIGTERM') { exit }
trap('SIGPIPE', 'IGNORE')

begin
  raise LoadError if defined?(FCGI_PURE_RUBY) && FCGI_PURE_RUBY
  require 'fcgi.so'
rescue LoadError
  require 'cgialt/fcgi/core'
end

require 'cgialt/fcgi/cgi_helper' if defined?(CGI)
