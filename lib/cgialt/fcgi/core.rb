##
## $Rev$
## $Release: 0.0.0 $
## $Copyright$
##

=begin

fcgi.rb 0.8.5 - fcgi.so compatible pure-ruby FastCGI library

fastcgi.rb Copyright (C) 2001 Eli Green
fcgi.rb    Copyright (C) 2002-2003 MoonWolf <moonwolf@moonwolf.com>
fcgi.rb    Copyright (C) 2004 Minero Aoki

=end


  require 'socket'
  require 'stringio'

  class FCGI

    def self::is_cgi?
      begin
        s = Socket.for_fd($stdin.fileno)
        s.getpeername
        false
      rescue Errno::ENOTCONN
        false
      rescue Errno::ENOTSOCK, Errno::EINVAL
        true
      end
    end

    def self::each(&block)
      f = default_connection()
      Server.new(f).each_request(&block)
    ensure
      f.close if f
    end

    def self::each_request(&block)
      f = default_connection()
      Server.new(f).each_request(&block)
    ensure
      f.close if f
    end

    def self::default_connection
      ::Socket.for_fd($stdin.fileno)
    end



    ProtocolVersion = 1

    # Record types
    FCGI_BEGIN_REQUEST = 1
    FCGI_ABORT_REQUEST = 2
    FCGI_END_REQUEST = 3
    FCGI_PARAMS = 4
    FCGI_STDIN = 5
    FCGI_STDOUT = 6
    FCGI_STDERR = 7
    FCGI_DATA = 8
    FCGI_GET_VALUES = 9
    FCGI_GET_VALUES_RESULT = 10
    FCGI_UNKNOWN_TYPE = 11
    FCGI_MAXTYPE = FCGI_UNKNOWN_TYPE

    FCGI_NULL_REQUEST_ID = 0

    # FCGI_BEGIN_REQUSET.role
    FCGI_RESPONDER = 1
    FCGI_AUTHORIZER = 2
    FCGI_FILTER = 3

    # FCGI_BEGIN_REQUEST.flags
    FCGI_KEEP_CONN = 1

    # FCGI_END_REQUEST.protocolStatus
    FCGI_REQUEST_COMPLETE = 0
    FCGI_CANT_MPX_CONN = 1
    FCGI_OVERLOADED = 2
    FCGI_UNKNOWN_ROLE = 3


    class Server

      def initialize(server)
        @server = server
        @buffers = {}
        @default_parameters = {
          "FCGI_MAX_CONNS" => 1,
          "FCGI_MAX_REQS"  => 1,
          "FCGI_MPX_CONNS" => true
        }
      end

      def each_request(&block)
        graceful = false
        trap("SIGUSR1") { graceful = true }
        while true
          begin
            session(&block)
          rescue Errno::EPIPE, EOFError
            # HTTP request is canceled by the remote user
          end
          exit 0 if graceful
        end
      end

      def session
        sock, addr = *@server.accept
        return unless sock
        fsock = FastCGISocket.new(sock)
        req = next_request(fsock)
        yield req
        respond_to req, fsock, FCGI_REQUEST_COMPLETE
      ensure
        sock.close if sock and not sock.closed?
      end

      private

      def next_request(sock)
        while rec = sock.read_record
          if rec.management_record?
            if rec.type == FCGI_GET_VALUES
              sock.send_record handle_GET_VALUES(rec)
            else
              sock.send_record UnknownTypeRecord.new(rec.request_id, rec.type)
            end
          else
            if (rec_type = rec.type) == FCGI_BEGIN_REQUEST
              @buffers[rec.request_id] = RecordBuffer.new(rec)
            elsif rec_type == FCGI_ABORT_REQUEST
              raise "got ABORT_REQUEST"   # FIXME
            else
              buf = @buffers[rec.request_id]   or next # inactive request
              buf.push rec
              if buf.ready?
                @buffers.delete rec.request_id
                return buf.new_request
              end
            end
          end
        end
        raise "must not happen: FCGI socket unexpected EOF"
      end

      def handle_GET_VALUES(rec)
        h = {}
        rec.values.each_key do |name|
          h[name] = @default_parameters[name]
        end
        ValuesRecord.new(FCGI_GET_VALUES_RESULT, rec.request_id, h)
      end

      def respond_to(req, sock, status)
        split_data(FCGI_STDOUT, req.id, req.out) do |rec|
          sock.send_record rec
        end
        split_data(FCGI_STDERR, req.id, req.err) do |rec|
          sock.send_record rec
        end if req.err.length > 0
        sock.send_record EndRequestRecord.new(req.id, 0, status)
      end

      DATA_UNIT = 16384

      def split_data(type, id, f)
        unless f.length == 0
          f.rewind
          while s = f.read(DATA_UNIT)
            yield GenericDataRecord.new(type, id, s)
          end
        end
        yield GenericDataRecord.new(type, id, '')
      end

    end


    class FastCGISocket
      def initialize(sock)
        @socket = sock
      end

      def read_record
        header = @socket.read(Record::HEADER_LENGTH) or return nil
        return nil unless header.size == Record::HEADER_LENGTH
        version, type, reqid, clen, padlen, reserved = *Record.parse_header(header)
        Record.class_for(type).parse(reqid, read_record_body(clen, padlen))
      end

      def read_record_body(content_len, padding_len)
        #*buf = ''
        #*while buf.length < content_len
        #*  buf << @socket.read([1024, content_len - buf.length].min)
        #*end
        buf = @socket.read(content_len)
        @socket.read padding_len if padding_len
        buf
      end
      private :read_record_body

      def send_record(rec)
        @socket.write rec.serialize
        @socket.flush
      end
    end


    class RecordBuffer
      def initialize(rec)
        @begin_request = rec
        @envs = []
        @stdins = []
        @datas = []
      end

      def push(rec)
        case rec
        when ParamsRecord
          @envs.push rec
        when StdinDataRecord
          @stdins.push rec
        when DataRecord
          @datas.push rec
        else
          raise "got unknown record: #{rec.class}"
        end
      end

      def ready?
        case @begin_request.role
        when FCGI_RESPONDER
          completed?(@envs) and
          completed?(@stdins)
        when FCGI_AUTHORIZER
          completed?(@envs)
        when FCGI_FILTER
          completed?(@envs) and
          completed?(@stdins) and
          completed?(@datas)
        else
          raise "unknown role: #{@begin_request.role}"
        end
      end

      def completed?(records)
        records.last and records.last.empty?
      end
      private :completed?

      def new_request
        Request.new(@begin_request.request_id, env(), stdin(), nil, nil, data())
      end

      def env
        h = {}
        @envs.each {|rec| h.update rec.values }
        h
      end

      def stdin
        StringIO.new(@stdins.inject('') {|buf, rec| buf << rec.flagment })
      end

      def data
        StringIO.new(@datas.inject('') {|buf, rec| buf << rec.flagment })
      end
    end


    class Request
      def initialize(id, env, stdin, stdout = nil, stderr = nil, data = nil)
        @id = id
        @env = env
        @in = stdin
        @out = stdout || StringIO.new
        @err = stderr || StringIO.new
        @data = data || StringIO.new
      end

      attr_reader :id
      attr_reader :env
      attr_reader :in
      attr_reader :out
      attr_reader :err
      attr_reader :data

      def finish   # for backword compatibility
      end
    end


    class Record
      # uint8_t  protocol_version;
      # uint8_t  record_type;
      # uint16_t request_id;     (big endian)
      # uint16_t content_length; (big endian)
      # uint8_t  padding_length;
      # uint8_t  reserved;
      HEADER_FORMAT = 'CCnnCC'
      HEADER_LENGTH = 8

      def self::parse_header(buf)
        return *buf.unpack(HEADER_FORMAT)
      end

      def self::class_for(type)
        RECORD_CLASS[type]
      end

      def initialize(type, reqid)
        @type = type
        @request_id = reqid
      end

      def version
        ::FCGI::ProtocolVersion
      end

      attr_reader :type, :request_id

      def management_record?
        @request_id == FCGI_NULL_REQUEST_ID
      end

      def serialize
        body = make_body()
        padding_length = body.length % 8
        header = make_header(body.length, padding_length)
        "#{header}#{body}#{'\000' * padding_length}"
      end

      private

      def make_header(content_length, pading_length)
        [::FCGI::ProtocolVersion, @type, @request_id, content_length, padding_length, 0].pack(HEADER_FORMAT)
      end

      def make_body
        raise NotImplementedError.new("#{self.class.name}#make_body(): not implemented.")
      end

    end

    class BeginRequestRecord < Record
      # uint16_t role; (big endian)
      # uint8_t  flags;
      # uint8_t  reserved[5];
      BODY_FORMAT = 'nCC5'

      def self.parse(id, body)
        role, flags, *reserved = *body.unpack(BODY_FORMAT)
        new(id, role, flags)
      end

      def initialize(id, role, flags)
        super FCGI_BEGIN_REQUEST, id
        @role = role
        @flags = flags
      end

      attr_reader :role
      attr_reader :flags

      def make_body
        [@role, @flags, 0, 0, 0, 0, 0].pack(BODY_FORMAT)
      end
    end

    class AbortRequestRecord < Record
      def self.parse(id, body)
        new(id)
      end

      def initialize(id)
        super FCGI_ABORT_REQUEST, id
      end
    end

    class EndRequestRecord < Record
      # uint32_t appStatus; (big endian)
      # uint8_t  protocolStatus;
      # uint8_t  reserved[3];
      BODY_FORMAT = 'NCC3'

      def self.parse(id, body)
        appstatus, protostatus, *reserved = *body.unpack(BODY_FORMAT)
        new(id, appstatus, protostatus)
      end

      def initialize(id, appstatus, protostatus)
        super FCGI_END_REQUEST, id
        @application_status = appstatus
        @protocol_status = protostatus
      end

      attr_reader :application_status
      attr_reader :protocol_status

      private

      def make_body
        [@application_status, @protocol_status, 0, 0, 0].pack(BODY_FORMAT)
      end
    end

    class UnknownTypeRecord < Record
      # uint8_t type;
      # uint8_t reserved[7];
      BODY_FORMAT = 'CC7'

      def self.parse(id, body)
        type, *reserved = *body.unpack(BODY_FORMAT)
        new(id, type)
      end

      def initialize(id, type)
        super FCGI_UNKNOWN_TYPE, id
        @unknown_type = type
      end

      attr_reader :unknown_type

      private

      def make_body
        [@unknown_type, 0, 0, 0, 0, 0, 0, 0].pack(BODY_FORMAT)
      end
    end

    class ValuesRecord < Record
      def self::parse(id, body)
        new(id, parse_values(body))
      end

      def self::parse_values(buf)
        result = {}
        until buf.empty?
          #*name, value = *read_pair(buf)
          #*result[name] = value
          name_len = read_length(buf)
          value_len = read_length(buf)
          name = buf.slice!(0, name_len)
          value = buf.slice!(0, value_len)
          result[name] = value
        end
        result
      end

      def self::read_pair(buf)
        name_len = read_length(buf)
        value_len = read_length(buf)
        return buf.slice!(0, name_len), buf.slice!(0, value_len)
      end

      MASK = ((1<<31) - 1)
      def self::read_length(buf)
        buf[0] >> 7 == 0 ? buf.slice!(0,1)[0] \
                         : buf.slice!(0,4).unpack('N')[0] & MASK
      end

      def initialize(type, id, values)
        super type, id
        @values = values   # Hash
      end

      attr_reader :values

      private

      def make_body
        buf = ''
        @values.each do |name, value|
          buf << "#{serialize_length(name.length)}#{serialize_length(value.length)}#{name}#{value}"
        end
        buf
      end

      def serialize_length(len)
        len < 128 ? len.chr : [len | (1<<31)].pack('N')
      end
    end

    class GetValuesRecord < ValuesRecord
      def initialize(id, values)
        super FCGI_GET_VALUES, id, values
      end
    end

    class ParamsRecord < ValuesRecord
      def initialize(id, values)
        super FCGI_PARAMS, id, values
      end

      def empty?
        @values.empty?
      end
    end

    class GenericDataRecord < Record
      def self::parse(id, body)
        new(id, body)
      end

      def initialize(type, id, flagment)   # abstract
        super type, id
        @flagment = flagment
      end

      attr_reader :flagment

      def empty?
        @flagment.empty?
      end

      private

      def make_body
        @flagment
      end
    end

    class StdinDataRecord < GenericDataRecord
      def initialize(id, flagment)
        super FCGI_STDIN, id, flagment
      end
    end

    class StdoutDataRecord < GenericDataRecord
      def initialize(id, flagment)
        super FCGI_STDOUT, id, flagment
      end
    end

    class DataRecord < GenericDataRecord
      def initialize(id, flagment)
        super FCGI_DATA, id, flagment
      end
    end

    class Record   # redefine
      RECORD_CLASS = {
        FCGI_GET_VALUES    => GetValuesRecord,

        FCGI_BEGIN_REQUEST => BeginRequestRecord,
        FCGI_ABORT_REQUEST => AbortRequestRecord,
        FCGI_PARAMS        => ParamsRecord,
        FCGI_STDIN         => StdinDataRecord,
        FCGI_DATA          => DataRecord,
        FCGI_STDOUT        => StdoutDataRecord,
        FCGI_END_REQUEST   => EndRequestRecord
      }
    end

  end # FCGI class
