require 'test/unit'
#require 'cgi'
require(ENV['CGI'] || 'cgialt')


if defined?(CGIExt)
  def if_cgiext;  yield if block_given?; true;  end
  def if_cgialt;  false;  end
else
  def if_cgiext;  false;  end
  def if_cgialt;  yield if block_given?; true;  end
end


class CGIUtilTest < Test::Unit::TestCase

  def test_escape_html
    ## escape html characters
    input = '<>&"\''
    expected = '&lt;&gt;&amp;&quot;\''
    actual = nil
    if_cgiext { actual = CGIExt.escape_html(input) }
    if_cgialt { actual = CGI.escapeHTML(input) }
    assert_equal(expected, actual)
    if_cgiext { assert_equal(CGI.escapeHTML(input), actual) }
    ## if no html characters found, return the passed argument as is
    input = 'foobar'
    expected = input
    if_cgiext { actual = CGIExt.escape_html(input) }
    if_cgialt { actual = CGI.escapeHTML(input) }
    assert_equal(expected, actual)
    #assert_same(expected, actual)
    ## when non-string is passed, error raised
    input = nil
    if_cgiext { assert_raise(TypeError) { CGIExt.escape_html(input) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.escapeHTML(input) } }
    input = 123
    if_cgiext { assert_raise(TypeError) { CGIExt.escape_html(input) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.escapeHTML(input) } }
  end


if_cgiext {
  def test_escape_html!
    ## escape html characters
    input = '<>&"\''
    expected = '&lt;&gt;&amp;&quot;\''
    actual = CGIExt.escape_html!(input)
    assert_equal(expected, actual)
    assert_equal(CGI.escapeHTML(input), actual)
    ## if no html characters found, return the string as is
    input = 'foobar'
    expected = input
    actual = CGIExt.escape_html!(input)
    assert_equal(expected, actual)
    assert_same(expected, actual)
    ## non-string value are converted into string
    input = nil
    expected = ''
    actual = CGIExt.escape_html!(input)
    assert_equal(expected, actual)
    input = 123
    expected = '123'
    actual = CGIExt.escape_html!(input)
    assert_equal(expected, actual)
  end
}


  def test_unescape_html
    ## unescape html characters
    tdata = [
      ## html entities ('<>&"')
      ['&lt;&gt;&amp;&quot;', '<>&"'],
      ## otehr html entities (ex. '&copy;')
      ['&copy;&heart;', '&copy;&heart;'],
      ## '&#99' format
      ['&#34;&#38;&#39;&#60;&#62;', '"&\'<>'],
      ## '&#x9999' format
      ['&#x0022;&#x0026;&#x0027;&#x003c;&#x003E;', '"&\'<>'],
      ## invalid format
      ['&&lt;&amp&gt;&quot&abcdefghijklmn', '&<&amp>&quot&abcdefghijklmn'],
    ]
    actual = nil
    tdata.each do |input, expected|
      if_cgiext { actual = CGIExt.unescape_html(input) }
      if_cgialt { actual = CGI.unescapeHTML(input) }
      assert_equal(expected, actual)
      if_cgiext { assert_equal(CGI.unescapeHTML(input), actual) }
    end
    ## return as-is when no html entity found
    input = "foobar"
    expected = input
    if_cgiext { actual = CGIExt.unescape_html(input) }
    if_cgialt { actual = CGI.unescapeHTML(input) }
    assert_equal(expected, actual)
    if_cgiext { assert_same(expected, actual) }
    ## when non-string is passed, error raised
    input = nil
    if_cgiext { assert_raise(TypeError) { CGIExt.unescape_html(input) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.unescapeHTML(input) } }
    input = 123
    if_cgiext { assert_raise(TypeError) { CGIExt.unescape_html(input) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.unescapeHTML(input) } }
  end


  TESTDATA_FOR_ESCAPE_URL = [
      ## example data
      ["'Stop!' said Fred._-+", '%27Stop%21%27+said+Fred._-%2B'],
      ## characters not to be escaped
      ["abcdefgxyzABCDEFGXYZ0123456789_.-",    "abcdefgxyzABCDEFGXYZ0123456789_.-"],
      ## characters to be escaped
      [' !"#$%&\'()*+,/:;<=>?@[\\]^`{|}~', "+%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E%60%7B%7C%7D%7E"],
      ## '%' format
      ["k[]", 'k%5B%5D'],
      ## unicode characters
      ["\244\242\244\244\244\246\244\250\244\252", "%A4%A2%A4%A4%A4%A6%A4%A8%A4%AA"],
  ]


  def test_escape_url
    ## encode url string
    testdata = TESTDATA_FOR_ESCAPE_URL + [
                 ## containing '%' character
                 ["%XX%5%%%", "%25XX%255%25%25%25"],
               ]
    actual = nil
    testdata.each do |input, expected|
      if_cgiext { actual = CGIExt.escape_url(input) }
      if_cgialt { actual = CGI.escape(input) }
      assert_equal(expected, actual)
      if_cgiext { assert_equal(CGI.escape(input), actual) }
      #assert_equal(expected, CGI.escape(input))
    end
    ## error when non-string
    if_cgiext { assert_raise(TypeError) { CGIExt.escape_url(nil) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.escape(nil) } }
    if_cgiext { assert_raise(TypeError) { CGIExt.escape_url(123) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.escape(123) } }
  end


  def test_unescape_url
    ## decode url string
    testdata = TESTDATA_FOR_ESCAPE_URL + [
                 ## invalid '%' format
                 ["%XX%5%%%", "%XX%5%%%"],
                 ## combination of lower case and upper case
                 ["\244\252", "%a4%Aa"],
               ]
    actual = nil
    testdata.each do |expected, input|
      if_cgiext { actual = CGIExt.unescape_url(input) }
      if_cgialt { actual = CGI.unescape(input) }
      assert_equal(expected, actual)
      if_cgiext { assert_equal(CGI.unescape(input), actual) }
      #assert_equal(expected, CGI.unescape(input))
    end
    ## error when non-string
    if_cgiext { assert_raise(TypeError) { CGIExt.unescape_url(nil) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.unescape(nil) } }
    if_cgiext { assert_raise(TypeError) { CGIExt.unescape_url(123) } }
    if_cgialt { assert_raise(NoMethodError) { CGI.unescape(123) } }
  end


  def test_rfc1123_date
    sec = 1196524602
    t = Time.at(sec)
    expected = 'Sat, 01 Dec 2007 15:56:42 GMT'
    actual = nil
    if_cgiext { actual = CGIExt.rfc1123_date(t) }
    if_cgialt { actual = CGI.rfc1123_date(t) }
    assert_equal(expected, actual)
    if_cgiext { assert_equal(CGI.rfc1123_date(t), actual) }
    ## error when not Time object
    if_cgiext { assert_raise(TypeError) { CGIExt.rfc1123_date(nil) } }
    if_cgialt { assert_raise(TypeError) { CGI.rfc1123_date(nil) } }
    if_cgiext { assert_raise(TypeError) { CGIExt.rfc1123_date(123) } }
    if_cgialt { assert_raise(TypeError) { CGI.rfc1123_date(123) } }
  end


  def test_parse_query_string
    ## equal with CGI.parse()
    tuples = [
      ## '&' separator
      ['a=10&b=20&key1=val1',  {'a'=>['10'], 'b'=>['20'], 'key1'=>['val1']} ],
      ## ';' separator
      ['a=10;b=20;key1=val1',  {'a'=>['10'], 'b'=>['20'], 'key1'=>['val1']} ],
      ## same keys
      ['a=1&a=2&a=3',          {'a'=>['1', '2', '3']} ],
      ## no value
      ['key=&key=', {'key'=>['', '']} ],
      ## unescape ascii string
      ['k%5B%5D=%5B%5D%26%3B', {'k[]'=>['[]&;']} ],
      ## unescape unicode string
      ["%A4%A2%a4%a4=%A4%a6%A4%A8%A4%Aa", {"\244\242\244\244"=>["\244\246\244\250\244\252"]} ],
      ## invalid '%' format
      ['k%XX%5=%%%', {'k%XX%5'=>['%%%']} ],
    ]
    actual = nil
    tuples.each do |input, expected|
      if_cgiext { actual = CGIExt.parse_query_string(input) }
      if_cgialt { actual = CGI.parse(input) }
      assert_equal(expected, actual)
      if_cgiext { assert_equal(CGI.parse(input), actual) }
    end
    ## different with CGI.parse()
    tdata = {}
    ## without '=' (CGI: {"a"=>[nil], "b"=>[nil]})
    if_cgiext { tdata['a&b'] =  {'a'=>[''], 'b'=>['']}     }
    if_cgialt { tdata['a&b'] =  {"a"=>[nil], "b"=>[nil]}   }
    ## no key  (CGI: {""=>["a", "b"], nil=>[nil]})
    if_cgiext { tdata['&=a&=b'] = {''=>['', 'a', 'b']}     }
    if_cgialt { tdata['&=a&=b'] = {""=>["a", "b"], nil=>[nil]}  }
    ## invalid format  (CGI: {"a"=>[""], "b"=>[nil]})
    if_cgiext { tdata['a=&b&&'] = {'a'=>[''], 'b'=>[''], ''=>['', '']}  }
    if_cgialt { tdata['a=&b&&'] = {"a"=>[""], "b"=>[nil]}  }
    tdata.each do |input, expected|
      if_cgiext { actual = CGIExt.parse_query_string(input) }
      if_cgialt { actual = CGI.parse(input) }
      assert_equal(expected, actual)
      if_cgiext { assert_equal(CGI.parse(input), actual) }
    end
    ## default value is frozen empty array
    assert_equal(actual['unknownkey'], [])
    ex = nil
    if "".respond_to?(:encoding)      # Ruby1.9
      errclass = RuntimeError
    else
      errclass = TypeError
    end
    ex = assert_raise(errclass) { actual['unknownkey'] << 'foo' }
    assert_equal("can't modify frozen array", ex.message)
  end


end
