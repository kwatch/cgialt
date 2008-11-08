##
## Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
##
## Copyright (C) 2000  Information-technology Promotion Agency, Japan
##
## Original Author: Wakou Aoyama <wakou@ruby-lang.org>
##
## Documentation: Wakou Aoyama (RDoc'd and embellished by William Webber)
##
## $Rev$
## $Release: 0.0.0 $
## $Copyright$

raise "Please, use ruby 1.5.4 or later." if RUBY_VERSION < "1.5.4"

#*** original
#*require 'English'
#*** original

# CGI class.  See documentation for the file cgi.rb for an overview
# of the CGI protocol.
#
# == Introduction
#
# CGI is a large class, providing several categories of methods, many of which
# are mixed in from other modules.  Some of the documentation is in this class,
# some in the modules CGI::QueryExtension and CGI::HtmlExtension.  See
# CGI::Cookie for specific information on handling cookies, and cgi/session.rb
# (CGI::Session) for information on sessions.
#
# For queries, CGI provides methods to get at environmental variables,
# parameters, cookies, and multipart request data.  For responses, CGI provides
# methods for writing output and generating HTML.
#
# Read on for more details.  Examples are provided at the bottom.
#
# == Queries
#
# The CGI class dynamically mixes in parameter and cookie-parsing
# functionality,  environmental variable access, and support for
# parsing multipart requests (including uploaded files) from the
# CGI::QueryExtension module.
#
# === Environmental Variables
#
# The standard CGI environmental variables are available as read-only
# attributes of a CGI object.  The following is a list of these variables:
#
#
#   AUTH_TYPE               HTTP_HOST          REMOTE_IDENT
#   CONTENT_LENGTH          HTTP_NEGOTIATE     REMOTE_USER
#   CONTENT_TYPE            HTTP_PRAGMA        REQUEST_METHOD
#   GATEWAY_INTERFACE       HTTP_REFERER       SCRIPT_NAME
#   HTTP_ACCEPT             HTTP_USER_AGENT    SERVER_NAME
#   HTTP_ACCEPT_CHARSET     PATH_INFO          SERVER_PORT
#   HTTP_ACCEPT_ENCODING    PATH_TRANSLATED    SERVER_PROTOCOL
#   HTTP_ACCEPT_LANGUAGE    QUERY_STRING       SERVER_SOFTWARE
#   HTTP_CACHE_CONTROL      REMOTE_ADDR
#   HTTP_FROM               REMOTE_HOST
#
#
# For each of these variables, there is a corresponding attribute with the
# same name, except all lower case and without a preceding HTTP_.  
# +content_length+ and +server_port+ are integers; the rest are strings.
#
# === Parameters
#
# The method #params() returns a hash of all parameters in the request as
# name/value-list pairs, where the value-list is an Array of one or more
# values.  The CGI object itself also behaves as a hash of parameter names 
# to values, but only returns a single value (as a String) for each 
# parameter name.
#
# For instance, suppose the request contains the parameter 
# "favourite_colours" with the multiple values "blue" and "green".  The
# following behaviour would occur:
#
#   cgi.params["favourite_colours"]  # => ["blue", "green"]
#   cgi["favourite_colours"]         # => "blue"
#
# If a parameter does not exist, the former method will return an empty
# array, the latter an empty string.  The simplest way to test for existence
# of a parameter is by the #has_key? method.
#
# === Cookies
#
# HTTP Cookies are automatically parsed from the request.  They are available
# from the #cookies() accessor, which returns a hash from cookie name to
# CGI::Cookie object.
#
# === Multipart requests
#
# If a request's method is POST and its content type is multipart/form-data, 
# then it may contain uploaded files.  These are stored by the QueryExtension
# module in the parameters of the request.  The parameter name is the name
# attribute of the file input field, as usual.  However, the value is not
# a string, but an IO object, either an IOString for small files, or a
# Tempfile for larger ones.  This object also has the additional singleton
# methods:
#
# #local_path():: the path of the uploaded file on the local filesystem
# #original_filename():: the name of the file on the client computer
# #content_type():: the content type of the file
#
# == Responses
#
# The CGI class provides methods for sending header and content output to
# the HTTP client, and mixes in methods for programmatic HTML generation
# from CGI::HtmlExtension and CGI::TagMaker modules.  The precise version of HTML
# to use for HTML generation is specified at object creation time.
#
# === Writing output
#
# The simplest way to send output to the HTTP client is using the #out() method.
# This takes the HTTP headers as a hash parameter, and the body content
# via a block.  The headers can be generated as a string using the #header()
# method.  The output stream can be written directly to using the #print()
# method.
#
# === Generating HTML
#
# Each HTML element has a corresponding method for generating that
# element as a String.  The name of this method is the same as that
# of the element, all lowercase.  The attributes of the element are 
# passed in as a hash, and the body as a no-argument block that evaluates
# to a String.  The HTML generation module knows which elements are
# always empty, and silently drops any passed-in body.  It also knows
# which elements require matching closing tags and which don't.  However,
# it does not know what attributes are legal for which elements.
#
# There are also some additional HTML generation methods mixed in from
# the CGI::HtmlExtension module.  These include individual methods for the
# different types of form inputs, and methods for elements that commonly
# take particular attributes where the attributes can be directly specified
# as arguments, rather than via a hash.
#
# == Examples of use
# 
# === Get form values
# 
#   require "cgi"
#   cgi = CGI.new
#   value = cgi['field_name']   # <== value string for 'field_name'
#     # if not 'field_name' included, then return "".
#   fields = cgi.keys            # <== array of field names
# 
#   # returns true if form has 'field_name'
#   cgi.has_key?('field_name')
#   cgi.has_key?('field_name')
#   cgi.include?('field_name')
# 
# CAUTION! cgi['field_name'] returned an Array with the old 
# cgi.rb(included in ruby 1.6)
# 
# === Get form values as hash
# 
#   require "cgi"
#   cgi = CGI.new
#   params = cgi.params
# 
# cgi.params is a hash.
# 
#   cgi.params['new_field_name'] = ["value"]  # add new param
#   cgi.params['field_name'] = ["new_value"]  # change value
#   cgi.params.delete('field_name')           # delete param
#   cgi.params.clear                          # delete all params
# 
# 
# === Save form values to file
# 
#   require "pstore"
#   db = PStore.new("query.db")
#   db.transaction do
#     db["params"] = cgi.params
#   end
# 
# 
# === Restore form values from file
# 
#   require "pstore"
#   db = PStore.new("query.db")
#   db.transaction do
#     cgi.params = db["params"]
#   end
# 
# 
# === Get multipart form values
# 
#   require "cgi"
#   cgi = CGI.new
#   value = cgi['field_name']   # <== value string for 'field_name'
#   value.read                  # <== body of value
#   value.local_path            # <== path to local file of value
#   value.original_filename     # <== original filename of value
#   value.content_type          # <== content_type of value
# 
# and value has StringIO or Tempfile class methods.
# 
# === Get cookie values
# 
#   require "cgi"
#   cgi = CGI.new
#   values = cgi.cookies['name']  # <== array of 'name'
#     # if not 'name' included, then return [].
#   names = cgi.cookies.keys      # <== array of cookie names
# 
# and cgi.cookies is a hash.
# 
# === Get cookie objects
# 
#   require "cgi"
#   cgi = CGI.new
#   for name, cookie in cgi.cookies
#     cookie.expires = Time.now + 30
#   end
#   cgi.out("cookie" => cgi.cookies) {"string"}
# 
#   cgi.cookies # { "name1" => cookie1, "name2" => cookie2, ... }
# 
#   require "cgi"
#   cgi = CGI.new
#   cgi.cookies['name'].expires = Time.now + 30
#   cgi.out("cookie" => cgi.cookies['name']) {"string"}
# 
# === Print http header and html string to $DEFAULT_OUTPUT ($>)
# 
#   require "cgi"
#   cgi = CGI.new("html3")  # add HTML generation methods
#   cgi.out() do
#     cgi.html() do
#       cgi.head{ cgi.title{"TITLE"} } +
#       cgi.body() do
#         cgi.form() do
#           cgi.textarea("get_text") +
#           cgi.br +
#           cgi.submit
#         end +
#         cgi.pre() do
#           CGI::escapeHTML(
#             "params: " + cgi.params.inspect + "\n" +
#             "cookies: " + cgi.cookies.inspect + "\n" +
#             ENV.collect() do |key, value|
#               key + " --> " + value + "\n"
#             end.join("")
#           )
#         end
#       end
#     end
#   end
# 
#   # add HTML generation methods
#   CGI.new("html3")    # html3.2
#   CGI.new("html4")    # html4.01 (Strict)
#   CGI.new("html4Tr")  # html4.01 Transitional
#   CGI.new("html4Fr")  # html4.01 Frameset
#
class CGI

  # :stopdoc:

  $CGI_ENV = ENV    # for FCGI support

  EOL = "\r\n"
  #*** original
  #*# String for carriage return
  #*CR  = "\015"
  #*
  #*# String for linefeed
  #*LF  = "\012"
  #*
  #*# Standard internet newline sequence
  #*EOL = CR + LF
  #*
  #*REVISION = '$Id: cgi.rb 12340 2007-05-22 21:58:09Z shyouhei $' #:nodoc:
  #*
  #*NEEDS_BINMODE = true if /WIN/ni.match(RUBY_PLATFORM) 
  #*
  #*# Path separators in different environments.
  #*PATH_SEPARATOR = {'UNIX'=>'/', 'WINDOWS'=>'\\', 'MACINTOSH'=>':'}
  #*** /original

  # HTTP status codes.
  HTTP_STATUS = {
    "OK"                  => "200 OK",
    "PARTIAL_CONTENT"     => "206 Partial Content",
    "MULTIPLE_CHOICES"    => "300 Multiple Choices",
    "MOVED"               => "301 Moved Permanently",
    "REDIRECT"            => "302 Found",
    "NOT_MODIFIED"        => "304 Not Modified",
    "BAD_REQUEST"         => "400 Bad Request",
    "AUTH_REQUIRED"       => "401 Authorization Required",
    "FORBIDDEN"           => "403 Forbidden",
    "NOT_FOUND"           => "404 Not Found",
    "METHOD_NOT_ALLOWED"  => "405 Method Not Allowed",
    "NOT_ACCEPTABLE"      => "406 Not Acceptable",
    "LENGTH_REQUIRED"     => "411 Length Required",
    "PRECONDITION_FAILED" => "412 Rrecondition Failed",
    "SERVER_ERROR"        => "500 Internal Server Error",
    "NOT_IMPLEMENTED"     => "501 Method Not Implemented",
    "BAD_GATEWAY"         => "502 Bad Gateway",
    "VARIANT_ALSO_VARIES" => "506 Variant Also Negotiates",
  }

  # :startdoc:

  def env_table
    $CGI_ENV
  end
  #*** original
  #*def env_table
  #*  ENV
  #*end
  #/*** original

  def stdinput
    $stdin
  end

  def stdoutput
    $stdout
  end
  #*** original
  #*def stdoutput
  #*  $DEFAULT_OUTPUT
  #*end
  #*** /original

  private :env_table, :stdinput, :stdoutput


  # Create an HTTP header block as a string.
  #
  # Includes the empty line that ends the header block.
  #
  # +options+ can be a string specifying the Content-Type (defaults
  # to text/html), or a hash of header key/value pairs.  The following
  # header keys are recognized:
  #
  # type:: the Content-Type header.  Defaults to "text/html"
  # charset:: the charset of the body, appended to the Content-Type header.
  # nph:: a boolean value.  If true, prepend protocol string and status code, and
  #       date; and sets default values for "server" and "connection" if not
  #       explicitly set.
  # status:: the HTTP status code, returned as the Status header.  See the
  #          list of available status codes below.
  # server:: the server software, returned as the Server header.
  # connection:: the connection type, returned as the Connection header (for 
  #              instance, "close".
  # length:: the length of the content that will be sent, returned as the
  #          Content-Length header.
  # language:: the language of the content, returned as the Content-Language
  #            header.
  # expires:: the time on which the current content expires, as a +Time+
  #           object, returned as the Expires header.
  # cookie:: a cookie or cookies, returned as one or more Set-Cookie headers.
  #          The value can be the literal string of the cookie; a CGI::Cookie
  #          object; an Array of literal cookie strings or Cookie objects; or a 
  #          hash all of whose values are literal cookie strings or Cookie objects.
  #          These cookies are in addition to the cookies held in the
  #          @output_cookies field.
  #
  # Other header lines can also be set; they are appended as key: value.
  # 
  #   header
  #     # Content-Type: text/html
  # 
  #   header("text/plain")
  #     # Content-Type: text/plain
  # 
  #   header("nph"        => true,
  #          "status"     => "OK",  # == "200 OK"
  #            # "status"     => "200 GOOD",
  #          "server"     => ENV['SERVER_SOFTWARE'],
  #          "connection" => "close",
  #          "type"       => "text/html",
  #          "charset"    => "iso-2022-jp",
  #            # Content-Type: text/html; charset=iso-2022-jp
  #          "length"     => 103,
  #          "language"   => "ja",
  #          "expires"    => Time.now + 30,
  #          "cookie"     => [cookie1, cookie2],
  #          "my_header1" => "my_value"
  #          "my_header2" => "my_value")
  # 
  # The status codes are:
  # 
  #   "OK"                  --> "200 OK"
  #   "PARTIAL_CONTENT"     --> "206 Partial Content"
  #   "MULTIPLE_CHOICES"    --> "300 Multiple Choices"
  #   "MOVED"               --> "301 Moved Permanently"
  #   "REDIRECT"            --> "302 Found"
  #   "NOT_MODIFIED"        --> "304 Not Modified"
  #   "BAD_REQUEST"         --> "400 Bad Request"
  #   "AUTH_REQUIRED"       --> "401 Authorization Required"
  #   "FORBIDDEN"           --> "403 Forbidden"
  #   "NOT_FOUND"           --> "404 Not Found"
  #   "METHOD_NOT_ALLOWED"  --> "405 Method Not Allowed"
  #   "NOT_ACCEPTABLE"      --> "406 Not Acceptable"
  #   "LENGTH_REQUIRED"     --> "411 Length Required"
  #   "PRECONDITION_FAILED" --> "412 Precondition Failed"
  #   "SERVER_ERROR"        --> "500 Internal Server Error"
  #   "NOT_IMPLEMENTED"     --> "501 Method Not Implemented"
  #   "BAD_GATEWAY"         --> "502 Bad Gateway"
  #   "VARIANT_ALSO_VARIES" --> "506 Variant Also Negotiates"
  # 
  # This method does not perform charset conversion. 
  #
  def header(options='text/html')
    if options.is_a?(String)
      content_type = options
      buf = _header_for_string(content_type)
    elsif options.is_a?(Hash)
      if options.size == 1 && options.has_key?('type')
        content_type = options['type']
        buf = _header_for_string(content_type)
      else
        buf = _header_for_hash(options.dup)
      end
    else
      raise ArgumentError.new("expected String or Hash but got #{options.class}")
    end
    if defined?(MOD_RUBY)
      _header_for_modruby(buf)
      return ''
    else
      buf << EOL    # empty line of separator
      return buf
    end
  end

  def _header_for_string(content_type) #:nodoc:
    buf = ''
    env = env_table()
    if nph?()
      buf << "#{env['SERVER_PROTOCOL'] || 'HTTP/1.0'} 200 OK#{EOL}"
      buf << "Date: #{CGI.rfc1123_date(Time.now)}#{EOL}"
      buf << "Server: #{env['SERVER_SOFTWARE']}#{EOL}"
      buf << "Connection: close#{EOL}"
    end
    buf << "Content-Type: #{content_type}#{EOL}"
    if @output_cookies
      @output_cookies.each {|cookie| buf << "Set-Cookie: #{cookie}#{EOL}" }
    end
    return buf
  end
  private :_header_for_string

  def _header_for_hash(options)  #:nodoc:
    buf = ''
    env = env_table()
    ## add charset to option['type']
    options['type'] ||= 'text/html'
    charset = options.delete('charset')
    options['type'] += "; charset=#{charset}" if charset
    ## NPH
    options.delete('nph') if defined?(MOD_RUBY)
    if options.delete('nph') || nph?()
      protocol = env['SERVER_PROTOCOL'] || 'HTTP/1.0'
      status = options.delete('status')
      status = HTTP_STATUS[status] || status || '200 OK'
      buf << "#{protocol} #{status}#{EOL}"
      buf << "Date: #{CGI.rfc1123_date(Time.now)}#{EOL}"
      options['server'] ||= env['SERVER_SOFTWARE'] || ''
      options['connection'] ||= 'close'
    end
    ## common headers
    status = options.delete('status')
    buf << "Status: #{HTTP_STATUS[status] || status}#{EOL}" if status
    server = options.delete('server')
    buf << "Server: #{server}#{EOL}" if server
    connection = options.delete('connection')
    buf << "Connection: #{connection}#{EOL}" if connection
    type = options.delete('type')
    buf << "Content-Type: #{type}#{EOL}" #if type
    length = options.delete('length')
    buf << "Content-Length: #{length}#{EOL}" if length
    language = options.delete('language')
    buf << "Content-Language: #{language}#{EOL}" if language
    expires = options.delete('expires')
    buf << "Expires: #{CGI.rfc1123_date(expires)}#{EOL}" if expires
    ## cookie
    if cookie = options.delete('cookie')
      case cookie
      when String, Cookie
        buf << "Set-Cookie: #{cookie}#{EOL}"
      when Array
        arr = cookie
        arr.each {|cookie| buf << "Set-Cookie: #{cookie}#{EOL}" }
      when Hash
        hash = cookie
        hash.each {|name, cookie| buf << "Set-Cookie: #{cookie}#{EOL}" }
      end
    end
    if @output_cookies
      @output_cookies.each {|cookie| buf << "Set-Cookie: #{cookie}#{EOL}" }
    end
    ## other headers
    options.each do |key, value|
      buf << "#{key}: #{value}#{EOL}"
    end
    return buf
  end
  private :_header_for_hash

  def nph?  #:nodoc:
    env = env_table()
    return /IIS\/(\d+)/n.match(env['SERVER_SOFTWARE']) && $1.to_i < 5
  end

  def _header_for_modruby(buf)  #:nodoc:
    request = Apache::request
    buf.scan(/([^:]+): (.+)#{EOL}/no) do |name, value|
      warn sprintf("name:%s value:%s\n", name, value) if $DEBUG
      case name
      when 'Set-Cookie'
        request.headers_out.add(name, value)
      when /^status$/ni
        request.status_line = value
        request.status = value.to_i
      when /^content-type$/ni
        request.content_type = value
      when /^content-encoding$/ni
        request.content_encoding = value
      when /^location$/ni
        request.status = 302 if request.status == 200
        request.headers_out[name] = value
      else
        request.headers_out[name] = value
      end
    end
    request.send_http_header
    return ''
  end
  private :_header_for_modruby
  #*** original
  #*def header(options = "text/html")
  #*
  #*  buf = ""
  #*  
  #*  case options
  #*  when String
  #*    options = { "type" => options }
  #*  when Hash
  #*    options = options.dup
  #*  end
  #*  
  #*  unless options.has_key?("type")
  #*    options["type"] = "text/html"
  #*  end
  #*  
  #*  if options.has_key?("charset")
  #*    options["type"] += "; charset=" + options.delete("charset")
  #*  end
  #*  
  #*  options.delete("nph") if defined?(MOD_RUBY)
  #*  if options.delete("nph") or
  #*      (/IIS\/(\d+)/n.match(env_table['SERVER_SOFTWARE']) and $1.to_i < 5)
  #*    buf += (env_table["SERVER_PROTOCOL"] or "HTTP/1.0")  + " " +
  #*           (HTTP_STATUS[options["status"]] or options["status"] or "200 OK") +
  #*           EOL +
  #*           "Date: " + CGI::rfc1123_date(Time.now) + EOL
  #*  
  #*    unless options.has_key?("server")
  #*      options["server"] = (env_table['SERVER_SOFTWARE'] or "")
  #*    end
  #*  
  #*    unless options.has_key?("connection")
  #*      options["connection"] = "close"
  #*    end
  #*  
  #*    options.delete("status")
  #*  end
  #*  
  #*  if options.has_key?("status")
  #*    buf += "Status: " +
  #*           (HTTP_STATUS[options["status"]] or options["status"]) + EOL
  #*    options.delete("status")
  #*  end
  #*  
  #*  if options.has_key?("server")
  #*    buf += "Server: " + options.delete("server") + EOL
  #*  end
  #*  
  #*  if options.has_key?("connection")
  #*    buf += "Connection: " + options.delete("connection") + EOL
  #*  end
  #*  
  #*  buf += "Content-Type: " + options.delete("type") + EOL
  #*  
  #*  if options.has_key?("length")
  #*    buf += "Content-Length: " + options.delete("length").to_s + EOL
  #*  end
  #*  
  #*  if options.has_key?("language")
  #*    buf += "Content-Language: " + options.delete("language") + EOL
  #*  end
  #*  
  #*  if options.has_key?("expires")
  #*    buf += "Expires: " + CGI::rfc1123_date( options.delete("expires") ) + EOL
  #*  end
  #*  
  #*  if options.has_key?("cookie")
  #*    if options["cookie"].kind_of?(String) or
  #*         options["cookie"].kind_of?(Cookie)
  #*      buf += "Set-Cookie: " + options.delete("cookie").to_s + EOL
  #*    elsif options["cookie"].kind_of?(Array)
  #*      options.delete("cookie").each{|cookie|
  #*        buf += "Set-Cookie: " + cookie.to_s + EOL
  #*      }
  #*    elsif options["cookie"].kind_of?(Hash)
  #*      options.delete("cookie").each_value{|cookie|
  #*        buf += "Set-Cookie: " + cookie.to_s + EOL
  #*      }
  #*    end
  #*  end
  #*  if @output_cookies
  #*    for cookie in @output_cookies
  #*      buf += "Set-Cookie: " + cookie.to_s + EOL
  #*    end
  #*  end
  #*  
  #*  options.each{|key, value|
  #*    buf += key + ": " + value.to_s + EOL
  #*  }
  #*  
  #*  if defined?(MOD_RUBY)
  #*    table = Apache::request.headers_out
  #*    buf.scan(/([^:]+): (.+)#{EOL}/n){ |name, value|
  #*      warn sprintf("name:%s value:%s\n", name, value) if $DEBUG
  #*      case name
  #*      when 'Set-Cookie'
  #*        table.add(name, value)
  #*      when /^status$/ni
  #*        Apache::request.status_line = value
  #*        Apache::request.status = value.to_i
  #*      when /^content-type$/ni
  #*        Apache::request.content_type = value
  #*      when /^content-encoding$/ni
  #*        Apache::request.content_encoding = value
  #*      when /^location$/ni
  #*        if Apache::request.status == 200
  #*          Apache::request.status = 302
  #*        end
  #*        Apache::request.headers_out[name] = value
  #*      else
  #*        Apache::request.headers_out[name] = value
  #*      end
  #*    }
  #*    Apache::request.send_http_header
  #*    ''
  #*  else
  #*    buf + EOL
  #*  end
  #*
  #*end # header()
  #*** /original


  # Print an HTTP header and body to $DEFAULT_OUTPUT ($>)
  #
  # The header is provided by +options+, as for #header().
  # The body of the document is that returned by the passed-
  # in block.  This block takes no arguments.  It is required.
  #
  #   cgi = CGI.new
  #   cgi.out{ "string" }
  #     # Content-Type: text/html
  #     # Content-Length: 6
  #     #
  #     # string
  # 
  #   cgi.out("text/plain") { "string" }
  #     # Content-Type: text/plain
  #     # Content-Length: 6
  #     #
  #     # string
  # 
  #   cgi.out("nph"        => true,
  #           "status"     => "OK",  # == "200 OK"
  #           "server"     => ENV['SERVER_SOFTWARE'],
  #           "connection" => "close",
  #           "type"       => "text/html",
  #           "charset"    => "iso-2022-jp",
  #             # Content-Type: text/html; charset=iso-2022-jp
  #           "language"   => "ja",
  #           "expires"    => Time.now + (3600 * 24 * 30),
  #           "cookie"     => [cookie1, cookie2],
  #           "my_header1" => "my_value",
  #           "my_header2" => "my_value") { "string" }
  # 
  # Content-Length is automatically calculated from the size of
  # the String returned by the content block.
  #
  # If ENV['REQUEST_METHOD'] == "HEAD", then only the header
  # is outputted (the content block is still required, but it
  # is ignored).
  # 
  # If the charset is "iso-2022-jp" or "euc-jp" or "shift_jis" then
  # the content is converted to this charset, and the language is set 
  # to "ja".
  def out(options='text/html') # :yield:
    options = { 'type' => options } if options.kind_of?(String)
    stdout = $stdout
    env = env_table()
    stdout.binmode if defined? stdout.binmode
    #if ENV['REQUEST_METHOD'] == 'HEAD'
    #  charset = options['charset']
    #  options['language'] ||= 'ja' if charset && charset =~ /iso-2022-jp|euc-jp|shift_jis/ni
    #  stdout.print header(options)
    #  return
    #end
    content = yield
    content = convert_content(content, options)
    options['length'] = _strlen(content).to_s
    stdout.print header(options)
    stdout.print content unless env['REQUEST_METHOD'] == 'HEAD'
  end
  def convert_content(content, options)  #:nodoc:
    charset = options['charset']
    return content unless charset
    opt = nil
    case charset
    when /iso-2022-jp/ni  ; opt = '-m0 -x -j'
    when /euc-jp/ni       ; opt = '-m0 -x -e'
    when /shift_jis/ni    ; opt = '-m0 -x -s'
    end
    if opt
      require 'nkf'
      content = NKF.nkf(opt, content)
      options['language'] ||= 'ja'
    end
    return content
  end
  private :convert_content
  if "".respond_to?(:bytesize)
    def _strlen(str)
      str.bytesize
    end
  else
    def _strlen(str)
      str.length
    end
  end
  private :_strlen
  #*** original
  #*def out(options = "text/html") # :yield:
  #*
  #*  options = { "type" => options } if options.kind_of?(String)
  #*  content = yield
  #*
  #*  if options.has_key?("charset")
  #*    require "nkf"
  #*    case options["charset"]
  #*    when /iso-2022-jp/ni
  #*      content = NKF::nkf('-m0 -x -j', content)
  #*      options["language"] = "ja" unless options.has_key?("language")
  #*    when /euc-jp/ni
  #*      content = NKF::nkf('-m0 -x -e', content)
  #*      options["language"] = "ja" unless options.has_key?("language")
  #*    when /shift_jis/ni
  #*      content = NKF::nkf('-m0 -x -s', content)
  #*      options["language"] = "ja" unless options.has_key?("language")
  #*    end
  #*  end
  #*
  #*  options["length"] = content.length.to_s
  #*  output = stdoutput
  #*  output.binmode if defined? output.binmode
  #*  output.print header(options)
  #*  output.print content unless "HEAD" == env_table['REQUEST_METHOD']
  #*end
  #*** /original


  # Print an argument or list of arguments to the default output stream
  #
  #   cgi = CGI.new
  #   cgi.print    # default:  cgi.print == $DEFAULT_OUTPUT.print
  def print(*options)
    $stdout.print(*options)
    #*** original
    #*stdoutput.print(*options)
    #*** /original
  end


  # Parse an HTTP query string into a hash of key=>value pairs.
  #
  #   params = CGI::parse("query_string")
  #     # {"name1" => ["value1", "value2", ...],
  #     #  "name2" => ["value1", "value2", ...], ... }
  #
  def CGI::parse(query)
    params = {}
    query.split(/[&;]/n).each do |pair|
      key, value = pair.split('=', 2)   # value is nil when '=' not found
      #(params[CGI.unescape(key)] ||= []) << CGI.unescape(value || '')  # desirable
      (params[CGI.unescape(key)] ||= []) << (value ? CGI.unescape(value) : value)
    end
    params.default = [].freeze
    return params
  end
  #*** original
  #*def CGI::parse(query)
  #*  params = Hash.new([].freeze)
  #*
  #*  query.split(/[&;]/n).each do |pairs|
  #*    key, value = pairs.split('=',2).collect{|v| CGI::unescape(v) }
  #*    if params.has_key?(key)
  #*      params[key].push(value)
  #*    else
  #*      params[key] = [value]
  #*    end
  #*  end
  #*
  #*  params
  #*end
  #*** /original


  # Maximum content length of post data
  MAX_CONTENT_LENGTH  = 2 * 1024 * 1024

  # Maximum content length of multipart data
  MAX_MULTIPART_LENGTH  = 128 * 1024 * 1024

  # Maximum number of request parameters when multipart
  MAX_MULTIPART_COUNT = 128


  # Mixin module. It provides the follow functionality groups:
  #
  # 1. Access to CGI environment variables as methods.  See 
  #    documentation to the CGI class for a list of these variables.
  #
  # 2. Access to cookies, including the cookies attribute.
  #
  # 3. Access to parameters, including the params attribute, and overloading
  #    [] to perform parameter value lookup by key.
  #
  # 4. The initialize_query method, for initialising the above
  #    mechanisms, handling multipart forms, and allowing the
  #    class to be used in "offline" mode.
  #
  module QueryExtension

    ## return Integer(ENV['CONTENT_LENGTH'])
    def content_length    ; return Integer(env_table['CONTENT_LENGTH']) ; end

    ## return Integer(ENV['SERVER_PORT'])
    def server_port       ; return Integer(env_table['SERVER_PORT'])    ; end

    ## return ENV['AUTH_TYPE']
    def auth_type         ; return env_table['AUTH_TYPE']            ; end

    ## return ENV['CONTENT_TYPE']
    def content_type      ; return env_table['CONTENT_TYPE']         ; end

    ## return ENV['GATEWAY_INTERFACE']
    def gateway_interface ; return env_table['GATEWAY_INTERFACE']    ; end

    ## return ENV['PATH_INFO']
    def path_info         ; return env_table['PATH_INFO']            ; end

    ## return ENV['PATH_TRANSLATED']
    def path_translated   ; return env_table['PATH_TRANSLATED']      ; end

    ## return ENV['QUERY_STRING']
    def query_string      ; return env_table['QUERY_STRING']         ; end

    ## return ENV['REMOTE_ADDR']
    def remote_addr       ; return env_table['REMOTE_ADDR']          ; end

    ## return ENV['REMOTE_HOST']
    def remote_host       ; return env_table['REMOTE_HOST']          ; end

    ## return ENV['REMOTE_IDENT']
    def remote_ident      ; return env_table['REMOTE_IDENT']         ; end

    ## return ENV['REMOTE_USER']
    def remote_user       ; return env_table['REMOTE_USER']          ; end

    ## return ENV['REQUEST_METHOD']
    def request_method    ; return env_table['REQUEST_METHOD']       ; end

    ## return ENV['SCRIPT_NAME']
    def script_name       ; return env_table['SCRIPT_NAME']          ; end

    ## return ENV['SERVER_NAME']
    def server_name       ; return env_table['SERVER_NAME']          ; end

    ## return ENV['SERVER_PROTOCOL']
    def server_protocol   ; return env_table['SERVER_PROTOCOL']      ; end

    ## return ENV['SERVER_SOFTWARE']
    def server_software   ; return env_table['SERVER_SOFTWARE']      ; end

    ## return ENV['HTTP_ACCEPT']
    def accept            ; return env_table['HTTP_ACCEPT']          ; end

    ## return ENV['HTTP_ACCEPT_CHARSET']
    def accept_charset    ; return env_table['HTTP_ACCEPT_CHARSET']  ; end

    ## return ENV['HTTP_ACCEPT_ENCODING']
    def accept_encoding   ; return env_table['HTTP_ACCEPT_ENCODING'] ; end

    ## return ENV['HTTP_ACCEPT_LANGUAGE']
    def accept_language   ; return env_table['HTTP_ACCEPT_LANGUAGE'] ; end

    ## return ENV['HTTP_CACHE_CONTROL']
    def cache_control     ; return env_table['HTTP_CACHE_CONTROL']   ; end

    ## return ENV['HTTP_FROM']
    def from              ; return env_table['HTTP_FROM']            ; end

    ## return ENV['HTTP_HOST']
    def host              ; return env_table['HTTP_HOST']            ; end

    ## return ENV['HTTP_NEGOTIATE']
    def negotiate         ; return env_table['HTTP_NEGOTIATE']       ; end

    ## return ENV['HTTP_PRAGMA']
    def pragma            ; return env_table['HTTP_PRAGMA']          ; end

    ## return ENV['HTTP_REFERER']
    def referer           ; return env_table['HTTP_REFERER']         ; end

    ## return ENV['HTTP_USER_AGENT']
    def user_agent        ; return env_table['HTTP_USER_AGENT']      ; end

    #*** orignal
    #*%w[ CONTENT_LENGTH SERVER_PORT ].each do |env|
    #*  define_method(env.sub(/^HTTP_/n, '').downcase) do
    #*    (val = env_table[env]) && Integer(val)
    #*  end
    #*end
    #*
    #*%w[ AUTH_TYPE CONTENT_TYPE GATEWAY_INTERFACE PATH_INFO
    #*    PATH_TRANSLATED QUERY_STRING REMOTE_ADDR REMOTE_HOST
    #*    REMOTE_IDENT REMOTE_USER REQUEST_METHOD SCRIPT_NAME
    #*    SERVER_NAME SERVER_PROTOCOL SERVER_SOFTWARE
    #*
    #*    HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ACCEPT_ENCODING
    #*    HTTP_ACCEPT_LANGUAGE HTTP_CACHE_CONTROL HTTP_FROM HTTP_HOST
    #*    HTTP_NEGOTIATE HTTP_PRAGMA HTTP_REFERER HTTP_USER_AGENT ].each do |env|
    #*  define_method(env.sub(/^HTTP_/n, '').downcase) do
    #*    env_table[env]
    #*  end
    #*end
    #*** /orignal

    # Get the raw cookies as a string.
    def raw_cookie
      return env_table['HTTP_COOKIE']
    end
    #*** original
    #*def raw_cookie
    #*  env_table["HTTP_COOKIE"]
    #*end
    #*** /original

    # Get the raw RFC2965 cookies as a string.
    def raw_cookie2
      return env_table['HTTP_COOKIE2']
    end
    #*** original
    #*def raw_cookie2
    #*  env_table["HTTP_COOKIE2"]
    #*end
    #*** /original

    # Get the cookies as a hash of cookie-name=>Cookie pairs.
    attr_accessor :cookies
    #*** original
    #*attr_accessor("cookies")
    #*** /original

    # Get the parameters as a hash of name=>values pairs, where
    # values is an Array.
    attr_reader :params
    #*** original
    #*attr("params")
    #*** /original

    # Set all the parameters.
    def params=(hash)
      @params.clear
      @params.update(hash)
    end

    def read_multipart(boundary, content_length)
      ## read first boundary
      stdin = $stdin
      stdin.binmode if defined? stdin.binmode
      first_line = "--#{boundary}#{EOL}"
      content_length -= first_line.length
      status = stdin.read(first_line.length)
      raise EOFError.new("no content body")  unless status
      raise EOFError.new("bad content body") unless first_line == status
      ## parse and set params
      params = {}
      begin
        quoted = Regexp.quote(boundary, 'n')
      rescue ArgumentError
        quoted = Regexp.quote(boundary)    # Ruby1.9
      end
      boundary_rexp = /--#{quoted}(#{EOL}|--)/n
      boundary_size = "#{EOL}--#{boundary}#{EOL}".length
      boundary_end  = nil
      buf = ''
      bufsize = 10 * 1024
      count = MAX_MULTIPART_COUNT
      while true
        (count -= 1) >= 0 or raise StandardError.new("too many parameters.")
        ## create body (StringIO or Tempfile)
        body = create_body(bufsize < content_length)
        class << body
          alias local_path path
          #attr_reader :original_filename, :content_type
          attr_accessor :original_filename, :content_type   # for Ruby1.9
        end
        ## find head and boundary
        head = nil
        separator = EOL * 2
        until head && matched = boundary_rexp.match(buf)
          if !head && pos = buf.index(separator)
            len  = pos + EOL.length
            head = buf[0, len]
            buf  = buf[(pos+separator.length)..-1]
          else
            if head && buf.size > boundary_size
              len = buf.size - boundary_size
              body.print(buf[0, len])
              buf[0, len] = ''
            end
            c = stdin.read(bufsize < content_length ? bufsize : content_length)
            raise EOFError.new("bad content body") if c.nil? || c.empty?
            buf << c
            content_length -= c.length
          end
        end
        ## read to end of boundary
        m = matched
        len = m.begin(0)
        s = buf[0, len]
        if s =~ /(\r?\n)\z/
          s = buf[0, len - $1.length]
        end
        body.print(s)
        buf = buf[m.end(0)..-1]
        boundary_end = m[1]
        content_length = -1 if boundary_end == '--'
        ## reset file cursor position
        body.rewind
        ## original filename
        /Content-Disposition:.* filename=(?:"(.*?)"|([^;\r\n]*))/ni.match(head)
        filename = $1 || $2 || ''
        filename = CGI.unescape(filename) if unescape_filename?()
        #body.instance_variable_set('@original_filename', filename.taint)
        body.original_filename = filename.taint   # for Ruby1.9
        ## content type
        /Content-Type: (.*)/ni.match(head)
        (content_type = $1 || '').chomp!
        #body.instance_variable_set('@content_type', content_type.taint)
        body.content_type = content_type.taint    # for Ruby1.9
        ## query parameter name
        /Content-Disposition:.* name=(?:"(.*?)"|([^;\r\n]*))/ni.match(head)
        name = $1 || $2 || ''
        (params[name] ||= []) << body
        ## break loop
        break if buf.size == 0
        break if content_length == -1
      end
      raise EOFError, "bad boundary end of body part" unless boundary_end =~ /--/
      params.default = []
      params
    end # read_multipart
    private :read_multipart
    def create_body(is_large)  #:nodoc:
      if is_large
        require 'tempfile'
        body = Tempfile.new('CGI')
      else
        begin
          require 'stringio'
          body = StringIO.new
        rescue LoadError
          require 'tempfile'
          body = Tempfile.new('CGI')
        end
      end
      body.binmode if defined? body.binmode
      return body
    end
    def unescape_filename?  #:nodoc:
      user_agent = env_table['HTTP_USER_AGENT']
      return /Mac/ni.match(user_agent) && /Mozilla/ni.match(user_agent) && !/MSIE/ni.match(user_agent)
    end
    #*** original
    #*def read_multipart(boundary, content_length)
    #*  params = Hash.new([])
    #*  boundary = "--" + boundary
    #*  quoted_boundary = Regexp.quote(boundary, "n")
    #*  buf = ""
    #*  bufsize = 10 * 1024
    #*  boundary_end=""
    #*
    #*  # start multipart/form-data
    #*  stdinput.binmode if defined? stdinput.binmode
    #*  boundary_size = boundary.size + EOL.size
    #*  content_length -= boundary_size
    #*  status = stdinput.read(boundary_size)
    #*  if nil == status
    #*    raise EOFError, "no content body"
    #*  elsif boundary + EOL != status
    #*    raise EOFError, "bad content body"
    #*  end
    #*
    #*  loop do
    #*    head = nil
    #*    if 10240 < content_length
    #*      require "tempfile"
    #*      body = Tempfile.new("CGI")
    #*    else
    #*      begin
    #*        require "stringio"
    #*        body = StringIO.new
    #*      rescue LoadError
    #*        require "tempfile"
    #*        body = Tempfile.new("CGI")
    #*      end
    #*    end
    #*    body.binmode if defined? body.binmode
    #*
    #*    until head and /#{quoted_boundary}(?:#{EOL}|--)/n.match(buf)
    #*
    #*      if (not head) and /#{EOL}#{EOL}/n.match(buf)
    #*        buf = buf.sub(/\A((?:.|\n)*?#{EOL})#{EOL}/n) do
    #*          head = $1.dup
    #*          ""
    #*        end
    #*        next
    #*      end
    #*
    #*      if head and ( (EOL + boundary + EOL).size < buf.size )
    #*        body.print buf[0 ... (buf.size - (EOL + boundary + EOL).size)]
    #*        buf[0 ... (buf.size - (EOL + boundary + EOL).size)] = ""
    #*      end
    #*
    #*      c = if bufsize < content_length
    #*            stdinput.read(bufsize)
    #*          else
    #*            stdinput.read(content_length)
    #*          end
    #*      if c.nil? || c.empty?
    #*        raise EOFError, "bad content body"
    #*      end
    #*      buf.concat(c)
    #*      content_length -= c.size
    #*    end
    #*
    #*    buf = buf.sub(/\A((?:.|\n)*?)(?:[\r\n]{1,2})?#{quoted_boundary}([\r\n]{1,2}|--)/n) do
    #*      body.print $1
    #*      if "--" == $2
    #*        content_length = -1
    #*      end
    #*     boundary_end = $2.dup
    #*      ""
    #*    end
    #*
    #*    body.rewind
    #*
    #*    /Content-Disposition:.* filename=(?:"((?:\\.|[^\"])*)"|([^;]*))/ni.match(head)
    #*    filename = ($1 or $2 or "")
    #*    if /Mac/ni.match(env_table['HTTP_USER_AGENT']) and
    #*        /Mozilla/ni.match(env_table['HTTP_USER_AGENT']) and
    #*        (not /MSIE/ni.match(env_table['HTTP_USER_AGENT']))
    #*      filename = CGI::unescape(filename)
    #*    end
    #*    
    #*    /Content-Type: (.*)/ni.match(head)
    #*    content_type = ($1 or "")
    #*
    #*    (class << body; self; end).class_eval do
    #*      alias local_path path
    #*      define_method(:original_filename) {filename.dup.taint}
    #*      define_method(:content_type) {content_type.dup.taint}
    #*    end
    #*
    #*    /Content-Disposition:.* name="?([^\";]*)"?/ni.match(head)
    #*    name = $1.dup
    #*
    #*    if params.has_key?(name)
    #*      params[name].push(body)
    #*    else
    #*      params[name] = [body]
    #*    end
    #*    break if buf.size == 0
    #*    break if content_length == -1
    #*  end
    #*  raise EOFError, "bad boundary end of body part" unless boundary_end=~/--/
    #*
    #*  params
    #*end # read_multipart
    #*private :read_multipart
    #*** /original

    # offline mode. read name=value pairs on standard input.
    def read_from_cmdline
      require 'shellwords'
      if ARGV.empty?
        string = ARGV.join(' ')
      else
        $stdin.tty? and $stderr.puts "(offline mode: enter name=value pairs on standard input)"
        string = readlines().join(' ').gsub(/\n/n, '')
      end
      string = string.gsub(/\\=/n, '%3D').gsub(/\\&/n, '%26')
      words = Shellwords.shellwords(string)
      sep = words.find {|x| /=/n.match(x) } ? '&' : '+'
      return words.join(sep)
    end
    private :read_from_cmdline
    #*** original
    #*def read_from_cmdline
    #*  require "shellwords"
    #*
    #*  string = unless ARGV.empty?
    #*    ARGV.join(' ')
    #*  else
    #*    if STDIN.tty?
    #*      STDERR.print(
    #*        %|(offline mode: enter name=value pairs on standard input)\n|
    #*      )
    #*    end
    #*    readlines.join(' ').gsub(/\n/n, '')
    #*  end.gsub(/\\=/n, '%3D').gsub(/\\&/n, '%26')
    #*
    #*  words = Shellwords.shellwords(string)
    #*
    #*  if words.find{|x| /=/n.match(x) }
    #*    words.join('&')
    #*  else
    #*    words.join('+')
    #*  end
    #*end
    #*private :read_from_cmdline
    #*** /original

    # Initialize the data from the query.
    #
    # Handles multipart forms (in particular, forms that involve file uploads).
    # Reads query parameters in the @params field, and cookies into @cookies.
    def initialize_query()
      env = env_table()
      case env_table()['REQUEST_METHOD']
      when 'GET', 'HEAD'
        query_str = defined?(MOD_RUBY) ? Apache::request.args : env['QUERY_STRING']
        @params = CGI.parse(query_str || '')
        @multipart = false
      when 'POST'
        content_length = Integer(env['CONTENT_LENGTH'])
        if /\Amultipart\/form-data/.match(env['CONTENT_TYPE'])
          raise StandardError.new("too large multipart data.") if content_length > MAX_MULTIPART_LENGTH
          unless /boundary=(?:"([^";,]+?)"|([^;,\s]+))/.match(env['CONTENT_TYPE'])
            raise StandardError.new("no boundary of multipart data.")
          end
          boundary = $1 || $2
          @params = read_multipart(boundary, content_length)
          @multipart = true
        else
          raise StandardError.new("too large post data.") if content_length > MAX_CONTENT_LENGTH
          stdin = $stdin
          stdin.binmode if defined? stdin.binmode
          query_str = stdin.read(content_length)
          @params = CGI.parse(query_str || '')
          @multipart = false
        end
      else
        @params = Hash.new([].freeze)
        @multipart = false
      end
      @cookies = CGI::Cookie.parse(env['HTTP_COOKIE'] || env['COOKIE'])
      nil
    end
    private :initialize_query
    #*** original
    #*def initialize_query()
    #*  if ("POST" == env_table['REQUEST_METHOD']) and
    #*     %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n.match(env_table['CONTENT_TYPE'])
    #*    boundary = $1.dup
    #*    @multipart = true
    #*    @params = read_multipart(boundary, Integer(env_table['CONTENT_LENGTH']))
    #*  else
    #*    @multipart = false
    #*    @params = CGI::parse(
    #*                case env_table['REQUEST_METHOD']
    #*                when "GET", "HEAD"
    #*                  if defined?(MOD_RUBY)
    #*                    Apache::request.args or ""
    #*                  else
    #*                    env_table['QUERY_STRING'] or ""
    #*                  end
    #*                when "POST"
    #*                  stdinput.binmode if defined? stdinput.binmode
    #*                  stdinput.read(Integer(env_table['CONTENT_LENGTH'])) or ''
    #*                else
    #*                  read_from_cmdline
    #*                end
    #*              )
    #*  end
    #*
    #*  @cookies = CGI::Cookie::parse((env_table['HTTP_COOKIE'] or env_table['COOKIE']))
    #*end
    #*private :initialize_query
    #*** /original

    def multipart?
      @multipart
    end

    module Value    # :nodoc:
      def set_params(params)
        @params = params
      end
      def [](idx, *args)
        if args.size == 0
          warn "#{caller(1)[0]}:CAUTION! cgi['key'] == cgi.params['key'][0]; if want Array, use cgi.params['key']"
          @params[idx]
        else
          super[idx,*args]
        end
      end
      def first
        warn "#{caller(1)[0]}:CAUTION! cgi['key'] == cgi.params['key'][0]; if want Array, use cgi.params['key']"
        self
      end
      alias last first
      def to_a
        @params || [self]
      end
      alias to_ary to_a   	# to be rhs of multiple assignment
    end

    # Get the value for the parameter with a given key.
    #
    # If the parameter has multiple values, only the first will be 
    # retrieved; use #params() to get the array of values.
    def [](key)
      params = @params[key]
      value = params[0]
      if @multipart
        return value if value
        return defined?(StringIO) ? StringIO.new('') : Tempfile.new('CGI')
      else
        str = value ? value.dup : ''
        str.extend(Value)
        str.set_params(params)
        return str
      end
    end
    #*** original
    #*def [](key)
    #*  params = @params[key]
    #*  value = params[0]
    #*  if @multipart
    #*    if value
    #*      return value
    #*    elsif defined? StringIO
    #*      StringIO.new("")
    #*    else
    #*      Tempfile.new("CGI")
    #*    end
    #*  else
    #*    str = if value then value.dup else "" end
    #*    str.extend(Value)
    #*    str.set_params(params)
    #*    str
    #*  end
    #*end
    #*** /original

    # Return all parameter keys as an array.
    def keys(*args)
      @params.keys(*args)
    end

    # Returns true if a given parameter key exists in the query.
    def has_key?(*args)
      @params.has_key?(*args)
    end
    alias key? has_key?
    alias include? has_key?

  end # QueryExtension


  # Creates a new CGI instance.
  #
  # +type+ specifies which version of HTML to load the HTML generation
  # methods for.  The following versions of HTML are supported:
  #
  # html3:: HTML 3.x
  # html4:: HTML 4.0
  # html4Tr:: HTML 4.0 Transitional
  # html4Fr:: HTML 4.0 with Framesets
  #
  # If not specified, no HTML generation methods will be loaded.
  #
  # If the CGI object is not created in a standard CGI call environment
  # (that is, it can't locate REQUEST_METHOD in its environment), then
  # it will run in "offline" mode.  In this mode, it reads its parameters
  # from the command line or (failing that) from standard input.  Otherwise,
  # cookies and other parameters are parsed automatically from the standard
  # CGI locations, which varies according to the REQUEST_METHOD.
  def initialize(type=nil)
    env = env_table()
    if defined?(MOD_RUBY) && !env['GATEWAY_INTERFACE']
      Apache.request.setup_cgi_env
    end
    ##
    #extend QueryExtension
    if defined?(CGI_PARAMS)
      warn "do not use CGI_PARAMS and CGI_COOKIES"
      @params = CGI_PARAMS.dup
      @cookies = CGI_COOKIES.dup
      @multipart = false
    else
      initialize_query()  # set @params, @cookies, and @multipart
    end
    @output_cookies = nil
    @output_hidden = nil
    ##
    if type
      require 'cgialt/html' unless defined?(HtmlExtension)
      case type
      when 'html3'
        extend Html3; element_init()
        extend HtmlExtension
      when 'html4'
        extend Html4; element_init()
        extend HtmlExtension
      when 'html4Tr'
        extend Html4Tr; element_init()
        extend HtmlExtension
      when 'html4Fr'
        extend Html4Tr; element_init()
        extend Html4Fr; element_init()
        extend HtmlExtension
      end
    end
  end
  include QueryExtension
  #*** original
  #*def initialize(type = "query")
  #*  if defined?(MOD_RUBY) && !ENV.key?("GATEWAY_INTERFACE")
  #*    Apache.request.setup_cgi_env
  #*  end
  #*
  #*  extend QueryExtension
  #*  @multipart = false
  #*  if defined?(CGI_PARAMS)
  #*    warn "do not use CGI_PARAMS and CGI_COOKIES"
  #*    @params = CGI_PARAMS.dup
  #*    @cookies = CGI_COOKIES.dup
  #*  else
  #*    initialize_query()  # set @params, @cookies
  #*  end
  #*  @output_cookies = nil
  #*  @output_hidden = nil
  #*
  #*  case type
  #*  when "html3"
  #*    extend Html3
  #*    element_init()
  #*    extend HtmlExtension
  #*  when "html4"
  #*    extend Html4
  #*    element_init()
  #*    extend HtmlExtension
  #*  when "html4Tr"
  #*    extend Html4Tr
  #*    element_init()
  #*    extend HtmlExtension
  #*  when "html4Fr"
  #*    extend Html4Tr
  #*    element_init()
  #*    extend Html4Fr
  #*    element_init()
  #*    extend HtmlExtension
  #*  end
  #*end
  #*** /original

end   # class CGI
