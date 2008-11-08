#!/usr/bin/ruby

###
### $Rev: 28 $
### $Release: 0.0.2 $
### copyright(c) 2007 kuwata-lab.com all rights reserved.
###

require 'rubygems'

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = "cgialt"
  s.author      = "makoto kuwata"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.homepage    = "http://cgialt.rubyforge.org/"
  s.summary     = "an alternative of 'cgi.rb' in pure Ruby"
  s.description = <<-'END'
  CGIAlt is an alternative library of 'cgi.rb'.
  It is compatible with and faster than 'cgi.rb'.
  It is able to install with CGIExt (which is re-implementation of cgi.rb in C extension).
  END

  ## files
  files = []
  files += Dir.glob('lib/**/*')
  files += Dir.glob('test/**/*')
  files += %w[README.txt bench.rb setup.rb]
  files += %w[CHANGES.txt] if test(?f, 'CHANGES.txt')
  s.files       = files
  #s.test_file   = 'test/test.rb'
end

# Quick fix for Ruby 1.8.3 / YAML bug   (thanks to Ross Bamford)
if (RUBY_VERSION == '1.8.3')
  def spec.to_yaml
    out = super
    out = '--- ' + out unless out =~ /^---/
    out
  end
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
