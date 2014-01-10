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
                      max_items: options[:max_items] || 50,
                      max_interval: options[:max_interval] || 5
                      )
  end

  def flush(events, key, final = false)
    redis.rpush key, events.collect(&:to_json)
  end

  def write(event)
    begin
      buffer_receive event, @redis_list
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
