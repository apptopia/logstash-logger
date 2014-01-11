class LogStashLogger < ::Logger
  def initialize(host, port, transport = :udp, options = {})
    case transport
    when :udp, :tcp
      super(::LogStashLogger::Socket.new(host, port, transport) )
    when :redis
      super(::LogStashLogger::Redis.new(host, port, options) )
    else
      raise "Unknown transport: #{transport}"
    end
    @logstash_formatter = LogStashLogger::Formatter.new
  end

  def format_message(severity, time, progname, message)
    message = formatter.call(severity, time, progname, message) if formatter
    @logstash_formatter.call severity, time, progname, message
  end

end
