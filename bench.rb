##
## $Rev$
## $Release: 0.0.0 $
## $Copyright$
##

##
## usage: ruby -s bench.rb [-cgialt] [-cgiext] [-rubygems] [-N=1000]
##

begin
  require($cgialt ? 'cgialt' : 'cgi')
rescue LoadError
  begin
    $:.unshift 'lib'
    require($cgialt ? 'cgialt' : 'cgi')
    $rubylib = 'lib'
  rescue LoadError
    require 'rubygems'
    require($cgialt ? 'cgialt' : 'cgi')
    $rubygems = true
  end
end

require 'benchmark'
require 'cgiext' if $cgiext
require 'rubygems' if $profile
require 'ruby-prof' if $profile

if defined?(CGI::RELEASE)
  puts "*** CGIAlt: release #{CGI::RELEASE}"
end

$N = ($N || 1000).to_i


class BenchmarkApplication


  QUERY_STRING = 'id=123&name=John+Smith&passwd=%40h%3D%7E%2F%5E%24%2F'
  #COOKIE_STRING = "name1=val1&val2&val3; name2=val2&%26%3C%3E%22;_session_id=abcdefg0123456789"
  COOKIE_STRING = '_session_id=e15eb25e3d8f3d51814024aab7ccbca0; dbx-pagemeta=grabit:0-|1-|2-|3-|4-|5-|6-|7-&advancedstuff:0-; dbx-postmeta=grabit:0+|1+|2+|3+|4+|5+|6+&advancedstuff:0-|1-|2-'
  #COOKIE_STRING = "name1=val1&val2&val3"
  SCRIPT_NAME  = '/cgi-bin/app/example/command.cgi'

  def initialize
    @request_method = 'GET'
    @query_string = QUERY_STRING
    @cookie_string = COOKIE_STRING
    @script_name = SCRIPT_NAME
  end

  def setup
    ENV['REQUEST_METHOD'] = @request_method
    ENV['QUERY_STRING']   = @query_string
    ENV['HTTP_COOKIE']    = @cookie_string
    ENV['SCRIPT_NAME']    = @script_name
  end


  def bench_invoke_ruby(ntimes)
    (ntimes/10).times do
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
      `ruby -e 'nil'`
    end
  end

  def self._def_bench_require(*names)
    if names.empty?
      method = 'bench_invoke_ruby'
      statement = 'nil'
    else
      method = "bench_require_" + names.join('_')
      statement = names.collect{|name| "require \"#{name}\""}.join('; ')
    end
    statement = "$:.unshift \"#{$rubylib}\"; " + statement if $rubylib
    command_opt = $rubygems ? '-rubygems' : ''
    s = ''
    s   << %Q|def #{method}(ntimes)\n|
    s   << %Q|  (ntimes / 10).times do\n|
    10.times do
      s << %Q|    `ruby #{command_opt} -e '#{statement}'`\n|
    end
    s   << %Q|  end\n|
    s   << %Q|end\n|
    return s
  end

  eval self._def_bench_require()
  eval self._def_bench_require('cgi')
  eval self._def_bench_require('cgi',    'cgiext')
  eval self._def_bench_require('cgialt')
  eval self._def_bench_require('cgialt', 'cgiext')

  def bench_cgi_new_simple(ntimes)
    ENV['QUERY_STRING'] = ''
    ENV['COOKIE_STRING'] = ''
    (ntimes / 10).times do
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
    end
  end

  def bench_cgi_new_complex(ntimes)
    ENV['QUERY_STRING'] =  @query_string
    ENV['COOKIE_STRING'] = @cookie_string
    (ntimes / 10).times do
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
      CGI.new
    end
  end

  def bench_cgi_header_simple(ntimes)
    cgi = CGI.new
    (ntimes / 10).times do
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
      cgi.header("text/html; charset=utf8")
    end
    return cgi.header("text/html; charset=utf8")
  end

  def bench_cgi_header_complex(ntimes)
    cgi = CGI.new
    options = {
      'type'     => 'text/xhtml',
      'charset'  => 'utf8',
      'length'   => 1024,
      'status'   => 'REDIRECT',
      'location' => 'http://www.example.com/',
      'server'   => 'webrick',
      'language' => 'ja',
      'Cache-Control' => 'none',
    }
    (ntimes / 10).times do
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
      cgi.header(options)
    end
    return cgi.header(options)
  end



  def execute

    method = "bench_require_#{$cgialt ? 'cgialt' : 'cgi'}#{$cgiext ? '_cgiext' : ''}"
    libname = "#{$cgialt ? 'cgialt' : 'cgi'}#{$cgiext ? '","cgiext': ''}"
    cmdopt = $rubygems ? '-rubygems ' : ''
    data = [
      [ 1,
        [ :bench_invoke_ruby, "ruby #{cmdopt}-e 'nil'" ],
        [ method.intern, "ruby #{cmdopt}-e 'require \"#{libname}\"'" ],
      ],
      [ 100,
        [ :bench_cgi_new_simple,  'CGI#new (simple)' ],
        [ :bench_cgi_new_complex, 'CGI#new (complex)' ],
      ],
      [ 1000,
        [ :bench_cgi_header_simple,  'CGI#header (simple)'  ],
        [ :bench_cgi_header_complex, 'CGI#header (complex)' ],
      ],
    ]

    nl = ''
    data.each do |list|
      factor = list.shift
      ntimes = factor * $N
      s = "#{ntimes} times"
      s << ' ' * (32 - s.length)
      header = "*** %s      user   system    total      real\n" % s
      format = "%8.3u %8.3y %8.3t %8.3r\n"
      print nl
      nl = "\n"
      Benchmark.benchmark(header, 38, format) do |job|
        list.each do |method, title|
          self.setup()
          output = nil
          if $profile
            result = RubyProf.profile do
              job.report(title) do
                output = self.__send__(method, ntimes)
              end
            end
            outfile = $o || "profile_#{method.to_s.sub(/bench_cgi_/,'')}.html"
            RubyProf::GraphHtmlPrinter.new(result).print(output='')
            File.open(outfile, 'w') {|f| f.write(output) }
          else
            job.report(title) do
              output = self.__send__(method, ntimes)
            end
          end
          if $DEBUG
            #puts "*** debug: "
            output.each {|line| p line }
          end
        end
      end
    end
  end

end


if $0 == __FILE__
  BenchmarkApplication.new.execute
end
