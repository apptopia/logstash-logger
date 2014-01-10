require 'redis'

class LogStashLogger::Redis
  def initialize(host, port, options = {})
    @host = host
    @port = port
    @options = options
    @redis = nil
    @redis_list = options[:list] || 'logstash'
  end

  def write(event)
    begin
      message = event.to_hash
      redis.rpush(@redis_list, "#{event.to_hash.to_s}")
    rescue => e
      warn "#{self.class} - #{e.class} - #{e.message}"
      close
      @redis = nil
    end
  end

  def close
    @redis && @redis.quit
  rescue => e
    warn "#{self.class} - #{e.class} - #{e.message}"
  end

  private
  def redis
    @redis ||= Redis.new host: @host, port: @port
  end
end
