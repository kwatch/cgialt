##
## Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
##
## Copyright (C) 2000  Information-technology Promotion Agency, Japan
##
## Original Author: Wakou Aoyama <wakou@ruby-lang.org>
##
## Documentation: Wakou Aoyama (RDoc'd and embellished by William Webber)
##
## $Rev: 32 $
## $Release: 0.0.2 $
## copyright(c) 2007 kuwata-lab.com all rights reserved.

class CGI

  #*** original
  #*require "delegate"
  #***

  # Class representing an HTTP cookie.
  #
  # In addition to its specific fields and methods, a Cookie instance
  # is a delegator to the array of its values.
  #
  # See RFC 2965.
  #
  # == Examples of use
  #   cookie1 = CGI::Cookie::new("name", "value1", "value2", ...)
  #   cookie1 = CGI::Cookie::new("name" => "name", "value" => "value")
  #   cookie1 = CGI::Cookie::new('name'    => 'name',
  #                              'value'   => ['value1', 'value2', ...],
  #                              'path'    => 'path',   # optional
  #                              'domain'  => 'domain', # optional
  #                              'expires' => Time.now, # optional
  #                              'secure'  => true      # optional
  #                             )
  # 
  #   cgi.out("cookie" => [cookie1, cookie2]) { "string" }
  # 
  #   name    = cookie1.name
  #   values  = cookie1.value
  #   path    = cookie1.path
  #   domain  = cookie1.domain
  #   expires = cookie1.expires
  #   secure  = cookie1.secure
  # 
  #   cookie1.name    = 'name'
  #   cookie1.value   = ['value1', 'value2', ...]
  #   cookie1.path    = 'path'
  #   cookie1.domain  = 'domain'
  #   cookie1.expires = Time.now + 30
  #   cookie1.secure  = true
  class Cookie   ## DelegateClass(Array) is too high cost!
  #*** original
  #*class Cookie < DelegateClass(Array)
  #*** /original

    # Create a new CGI::Cookie object.
    #
    # The contents of the cookie can be specified as a +name+ and one
    # or more +value+ arguments.  Alternatively, the contents can
    # be specified as a single hash argument.  The possible keywords of
    # this hash are as follows:
    #
    # name:: the name of the cookie.  Required.
    # value:: the cookie's value or list of values.
    # path:: the path for which this cookie applies.  Defaults to the
    #        base directory of the CGI script.
    # domain:: the domain for which this cookie applies.
    # expires:: the time at which this cookie expires, as a +Time+ object.
    # secure:: whether this cookie is a secure cookie or not (default to
    #          false).  Secure cookies are only transmitted to HTTPS 
    #          servers.
    #
    # These keywords correspond to attributes of the cookie object.
    def initialize(name='', *value)
      rexp = %r|\A.*/|
      if name.is_a?(String)
        @name = name
        @value = value  # value is an Array
        @path = rexp.match($CGI_ENV['SCRIPT_NAME']) ? $& : ''
        @secure = false
      else
        options = name
        @name  = options['name']  or raise ArgumentError, "`name' required"
        @value = Array(options['value'])
        @path  = options['path'] || (rexp.match($CGI_ENV['SCRIPT_NAME']) ? $& : '')  # simple support for IE
        @domain  = options['domain']
        @expires = options['expires']
        @secure  = options['secure'] == true
      end
      #super(@value)
    end
    #*** original
    #*def initialize(name = "", *value)
    #*  options = if name.kind_of?(String)
    #*              { "name" => name, "value" => value }
    #*            else
    #*              name
    #*            end
    #*  unless options.has_key?("name")
    #*    raise ArgumentError, "`name' required"
    #*  end
    #*
    #*  @name = options["name"]
    #*  @value = Array(options["value"])
    #*  # simple support for IE
    #*  if options["path"]
    #*    @path = options["path"]
    #*  else
    #*    %r|^(.*/)|.match(ENV["SCRIPT_NAME"])
    #*    @path = ($1 or "")
    #*  end
    #*  @domain = options["domain"]
    #*  @expires = options["expires"]
    #*  @secure = options["secure"] == true ? true : false
    #*
    #*  super(@value)
    #*end
    #*** /original

    attr_accessor :name, :value, :path, :domain, :expires
    attr_reader :secure
    #*** original
    #*attr_accessor("name", "value", "path", "domain", "expires")
    #*attr_reader("secure")
    #*** original

    # Set whether the Cookie is a secure cookie or not.
    #
    # +val+ must be a boolean.
    def secure=(val)
      @secure = val if val == true or val == false
      @secure
    end

    # Convert the Cookie to its string representation.
    def to_s
      val = @value.is_a?(String) ? CGI.escape(@value) \
                                 : @value.collect{|v| CGI.escape(v) }.join('&')
      buf = "#{CGI.escape(@name)}=#{val}"
      buf << "; domain=#{@domain}" if @domain
      buf << "; path=#{@path}"     if @path
      buf << "; expires=#{CGI.rfc1123_date(@expires)}" if @expires
      buf << "; secure"            if @secure == true
      return buf
    end
    #*** original
    #*def to_s
    #*  buf = ""
    #*  buf += @name + '='
    #*
    #*  if @value.kind_of?(String)
    #*    buf += CGI::escape(@value)
    #*  else
    #*    buf += @value.collect{|v| CGI::escape(v) }.join("&")
    #*  end
    #*
    #*  if @domain
    #*    buf += '; domain=' + @domain
    #*  end
    #*
    #*  if @path
    #*    buf += '; path=' + @path
    #*  end
    #*
    #*  if @expires
    #*    buf += '; expires=' + CGI::rfc1123_date(@expires)
    #*  end
    #*
    #*  if @secure == true
    #*    buf += '; secure'
    #*  end
    #*
    #*  buf
    #*end
    #*** /original

    ## define methods instead of DelegateClass(Array)
    include Enumerable  ##:nodoc:
    def [](*args)  ##:nodoc:
      @value[*args]
    end
    def []=(index, value)  ##:nodoc:
      @value[index] = value
    end
    def each(&block)  ##:nodoc:
      @value.each(&block)
    end
    def method_missing(m, *args)  ##:nodoc:
      @value.respond_to?(m) ? @value.__send__(m, *args) : super
    end
    def respond_to?(m)  ##:nodoc:
      super(m) || @value.respond_to?(m)
    end
    #def inspect;  @value.inspect;  end
    #def ==(arg);  @value == arg;  end
    #def ===(arg);  @value === arg;  end

  end # class Cookie


  # Parse a raw cookie string into a hash of cookie-name=>Cookie
  # pairs.
  #
  #   cookies = CGI::Cookie::parse("raw_cookie_string")
  #     # { "name1" => cookie1, "name2" => cookie2, ... }
  #
  def Cookie::parse(raw_cookie)
    cookies = Hash.new([])
    return cookies if !raw_cookie || raw_cookie.empty?
    for pairs in raw_cookie.split(/[;,]\s?/)
      name, value = pairs.split('=', 2)
      next unless name && value
      name = CGI.unescape(name)
      values = value.split('&').collect{|v| CGI.unescape(v) }
      if cookies.has_key?(name)
        cookies[name].value.concat(values)
      else
        cookies[name] = self.new(name, *values)
      end
    end
    return cookies
  end
  #*** original
  #*def Cookie::parse(raw_cookie)
  #*  cookies = Hash.new([])
  #*  return cookies unless raw_cookie
  #*
  #*  raw_cookie.split(/[;,]\s?/).each do |pairs|
  #*    name, values = pairs.split('=',2)
  #*    next unless name and values
  #*    name = CGI::unescape(name)
  #*    values ||= ""
  #*    values = values.split('&').collect{|v| CGI::unescape(v) }
  #*    if cookies.has_key?(name)
  #*      values = cookies[name].value + values
  #*    end
  #*    cookies[name] = Cookie::new({ "name" => name, "value" => values })
  #*  end
  #*
  #*  cookies
  #*end
  #*** /original

end
