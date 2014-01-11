require 'redis'
require "stud/buffer"

class LogStashLogger::Redis
  include Stud::Buffer

  def initialize(host, port, options = {})
    @host = host
    @port = port
    @options = options
    @redis = nil
    @redis_list = options[:list] || 'logstash'

    buffer_initialize(
                      max_items: options[:max_items] || 1000,
                      max_interval: options[:max_interval] || 3
                      )
  end

  def flush(messages, key, final = false)
    redis.rpush key, messages
  rescue SocketError
    messages.each{|m| STDOUT << "#{m}\n" }
  end

  def write(message)
    begin
      buffer_receive message, @redis_list
    rescue => e
      warn "#{self.class} - #{e.class} - #{e.message}"
      close
      @redis = nil
    end
  end

  def close
    buffer_flush
    @redis && @redis.quit
  rescue => e
    warn "#{self.class} - #{e.class} - #{e.message}"
  end

  private
  def redis
    @redis ||= Redis.new host: @host, port: @port
  end
end
