# 
# cgi.rb - cgi support library
# 
# Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
# 
# Copyright (C) 2000  Information-technology Promotion Agency, Japan
#
# Author: Wakou Aoyama <wakou@ruby-lang.org>
#
# Documentation: Wakou Aoyama (RDoc'd and embellished by William Webber) 
# 
# == Overview
#
# The Common Gateway Interface (CGI) is a simple protocol
# for passing an HTTP request from a web server to a
# standalone program, and returning the output to the web
# browser.  Basically, a CGI program is called with the
# parameters of the request passed in either in the
# environment (GET) or via $stdin (POST), and everything
# it prints to $stdout is returned to the client.
# 
# This file holds the +CGI+ class.  This class provides
# functionality for retrieving HTTP request parameters,
# managing cookies, and generating HTML output.  See the
# class documentation for more details and examples of use.
#
# The file cgi/session.rb provides session management
# functionality; see that file for more details.
#
# See http://www.w3.org/CGI/ for more information on the CGI
# protocol.

class CGI
  RELEASE = ('$Release: 0.0.0 $' =~ /[.\d]+/) && $&
  if $DEBUG || ENV['DEBUG']
    $stderr.puts "*** CGIAlt: release #{RELEASE}"
  end
end

require 'cgialt/util'
require 'cgialt/cookie'
require 'cgialt/core'
#require 'cgialt/html'   # loaded by core only when CGI.new(type) and type != nil
