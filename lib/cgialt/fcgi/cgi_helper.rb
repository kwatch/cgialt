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

require 'cgialt' unless defined?(CGI)

class FCGI

  if FCGI.is_cgi?
    def FCGI.each_cgi(arg=nil)
      #require 'cgialt' unless defined?(CGI)
      yield CGI.new(arg)
    end
  else
    def FCGI.each_cgi(arg=nil)
      #require 'cgialt' unless defined?(CGI)
      #exit_requested = false
      FCGI.each do |request|
        $FCGI_REQUEST = request
        $stdout = request.out
        $stderr = request.err
        #ENV.clear
        #ENV.update(request.env)
        $CGI_ENV = request.env
        yield CGI.new(arg)
        request.finish
      end
    end
  end

end
#*** original
#*# There is no C version of 'each_cgi'
#*# Note: for ruby-1.6.8 at least, the constants CGI_PARAMS/CGI_COOKIES
#*# are defined within module 'CGI', even if you have subclassed it
#*
#*class FCGI
#*  def self::each_cgi(*args)
#*    require 'cgi'
#*
#*    eval(<<-EOS,TOPLEVEL_BINDING)
#*    class CGI
#*      public :env_table
#*      def self::remove_params
#*        if (const_defined?(:CGI_PARAMS))
#*          remove_const(:CGI_PARAMS)
#*          remove_const(:CGI_COOKIES)
#*        end
#*      end
#*    end # ::CGI class
#*
#*    class FCGI
#*      class CGI < ::CGI
#*        def initialize(request, *args)
#*          ::CGI.remove_params
#*          @request = request
#*          super(*args)
#*          @args = *args
#*        end
#*        def args
#*          @args
#*        end
#*        def env_table
#*          @request.env
#*        end
#*        def stdinput
#*          @request.in
#*        end
#*        def stdoutput
#*          @request.out
#*        end
#*      end # FCGI::CGI class
#*    end # FCGI class
#*    EOS
#*    
#*    if FCGI::is_cgi?
#*      yield ::CGI.new(*args)
#*    else
#*      exit_requested = false
#*      FCGI::each {|request|
#*        $stdout, $stderr = request.out, request.err
#*
#*        yield CGI.new(request, *args)
#*        
#*        request.finish
#*      }
#*    end
#*  end
#*end
#*** /original
