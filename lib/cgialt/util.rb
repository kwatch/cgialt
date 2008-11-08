##
## Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
##
## Copyright (C) 2000  Information-technology Promotion Agency, Japan
##
## Original Author: Wakou Aoyama <wakou@ruby-lang.org>
##
## Documentation: Wakou Aoyama (RDoc'd and embellished by William Webber)
##

class CGI

  # URL-encode a string.
  #   url_encoded_string = CGI::escape("'Stop!' said Fred")
  #      # => "%27Stop%21%27+said+Fred"
  def CGI::escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end


  # URL-decode a string.
  #   string = CGI::unescape("%27Stop%21%27+said+Fred")
  #      # => "'Stop!' said Fred"
  def CGI::unescape(string)
    string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
      [$1.delete('%')].pack('H*')
    end
  end


  # Escape special characters in HTML, namely &\"<>
  #   CGI::escapeHTML('Usage: foo "bar" <baz>')
  #      # => "Usage: foo &quot;bar&quot; &lt;baz&gt;"
  def CGI::escapeHTML(string)
    string.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;')
  end


  # Unescape a string that has been HTML-escaped
  #   CGI::unescapeHTML("Usage: foo &quot;bar&quot; &lt;baz&gt;")
  #      # => "Usage: foo \"bar\" <baz>"
  def self.unescapeHTML(string)
    table = UNESCAPE_ENTITIES
    unicode_p = $KCODE[0] == ?u || $KCODE[0] == ?U
    string.gsub(/&[a-zA-F0-9]+;/n) do
      match = $&
      key = match[1..-2]
      if (s = table[key])
        s
      elsif key =~ /\A#0*(\d+)\z/n
        if   (v = Integer($1)) < 256 ;  v.chr
        elsif v < 65536 && unicode_p ;  [v].pack("U")
        else                         ;  match
        end
      elsif key =~ /\A#x([0-9a-f]+)\z/ni
        if   (v = $1.hex) < 256      ;  v.chr
        elsif v < 65536 && unicode_p ;  [v].pack("U")
        else                         ;  match
        end
      else
        match
      end
    end
  end
  UNESCAPE_ENTITIES = {
    'amp'=>'&', 'lt'=>'<', 'gt'=>'>', 'quot'=>'"',
  }
  #*** original
  #*def CGI::unescapeHTML(string)
  #*  string.gsub(/&(amp|quot|gt|lt|\#[0-9]+|\#x[0-9A-Fa-f]+);/n) do
  #*    match = $1.dup
  #*    case match
  #*    when 'amp'                 then '&'
  #*    when 'quot'                then '"'
  #*    when 'gt'                  then '>'
  #*    when 'lt'                  then '<'
  #*    when /\A#0*(\d+)\z/n       then
  #*      if Integer($1) < 256
  #*        Integer($1).chr
  #*      else
  #*        if Integer($1) < 65536 and ($KCODE[0] == ?u or $KCODE[0] == ?U)
  #*          [Integer($1)].pack("U")
  #*        else
  #*          "&##{$1};"
  #*        end
  #*      end
  #*    when /\A#x([0-9a-f]+)\z/ni then
  #*      if $1.hex < 256
  #*        $1.hex.chr
  #*      else
  #*        if $1.hex < 65536 and ($KCODE[0] == ?u or $KCODE[0] == ?U)
  #*          [$1.hex].pack("U")
  #*        else
  #*          "&#x#{$1};"
  #*        end
  #*      end
  #*    else
  #*      "&#{match};"
  #*    end
  #*  end
  #*end
  #*** /original


  # Escape only the tags of certain HTML elements in +string+.
  #
  # Takes an element or elements or array of elements.  Each element
  # is specified by the name of the element, without angle brackets.
  # This matches both the start and the end tag of that element.
  # The attribute list of the open tag will also be escaped (for
  # instance, the double-quotes surrounding attribute values).
  #
  #   print CGI::escapeElement('<BR><A HREF="url"></A>', "A", "IMG")
  #     # "<BR>&lt;A HREF=&quot;url&quot;&gt;&lt;/A&gt"
  #
  #   print CGI::escapeElement('<BR><A HREF="url"></A>', ["A", "IMG"])
  #     # "<BR>&lt;A HREF=&quot;url&quot;&gt;&lt;/A&gt"
  def CGI::escapeElement(string, *elements)
    elements = elements[0] if elements[0].kind_of?(Array)
    unless elements.empty?
      string.gsub(/<\/?(?:#{elements.join("|")})(?!\w)(?:.|\n)*?>/ni) do
        CGI::escapeHTML($&)
      end
    else
      string
    end
  end


  # Undo escaping such as that done by CGI::escapeElement()
  #
  #   print CGI::unescapeElement(
  #           CGI::escapeHTML('<BR><A HREF="url"></A>'), "A", "IMG")
  #     # "&lt;BR&gt;<A HREF="url"></A>"
  # 
  #   print CGI::unescapeElement(
  #           CGI::escapeHTML('<BR><A HREF="url"></A>'), ["A", "IMG"])
  #     # "&lt;BR&gt;<A HREF="url"></A>"
  def CGI::unescapeElement(string, *elements)
    elements = elements[0] if elements[0].kind_of?(Array)
    unless elements.empty?
      string.gsub(/&lt;\/?(?:#{elements.join("|")})(?!\w)(?:.|\n)*?&gt;/ni) do
        CGI::unescapeHTML($&)
      end
    else
      string
    end
  end


  # Format a +Time+ object as a String using the format specified by RFC 1123.
  #
  #   CGI::rfc1123_date(Time.now)
  #     # Sat, 01 Jan 2000 00:00:00 GMT
  def CGI::rfc1123_date(time)
    t = time.clone.gmtime
    return format("%s, %.2d %s %.4d %.2d:%.2d:%.2d GMT",
                RFC822_DAYS[t.wday], t.day, RFC822_MONTHS[t.month-1], t.year,
                t.hour, t.min, t.sec)
  end

  # Abbreviated day-of-week names specified by RFC 822
  RFC822_DAYS = %w[ Sun Mon Tue Wed Thu Fri Sat ]

  # Abbreviated month names specified by RFC 822
  RFC822_MONTHS = %w[ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ]


  # Prettify (indent) an HTML string.
  #
  # +string+ is the HTML string to indent.  +shift+ is the indentation
  # unit to use; it defaults to two spaces.
  #
  #   print CGI::pretty("<HTML><BODY></BODY></HTML>")
  #     # <HTML>
  #     #   <BODY>
  #     #   </BODY>
  #     # </HTML>
  # 
  #   print CGI::pretty("<HTML><BODY></BODY></HTML>", "\t")
  #     # <HTML>
  #     #         <BODY>
  #     #         </BODY>
  #     # </HTML>
  #
  def CGI::pretty(string, shift = "  ")
    lines = string.gsub(/(?!\A)<(?:.|\n)*?>/n, "\n\\0").gsub(/<(?:.|\n)*?>(?!\n)/n, "\\0\n")
    end_pos = 0
    while end_pos = lines.index(/^<\/(\w+)/n, end_pos)
      element = $1.dup
      start_pos = lines.rindex(/^\s*<#{element}/ni, end_pos)
      lines[start_pos ... end_pos] = "__" + lines[start_pos ... end_pos].gsub(/\n(?!\z)/n, "\n" + shift) + "__"
    end
    lines.gsub(/^((?:#{Regexp::quote(shift)})*)__(?=<\/?\w)/n, '\1')
  end


end
