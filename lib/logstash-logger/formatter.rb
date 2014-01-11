class LogStashLogger::Formatter
  LOGSTASH_EVENT_FIELDS = %w(@timestamp @tags @type @source @fields message).freeze
  HOST = ::Socket.gethostname

  def call(severity, time, progname, message)
    data = message
    if data.is_a?(String) && data[0] == '{'
      data = (JSON.parse(message) rescue nil) || message
    end

    event = case data
    when LogStash::Event
      data.clone
    when Hash
      event_data = {
        "@tags" => [],
        "@fields" => {},
        "@timestamp" => time
      }
      LOGSTASH_EVENT_FIELDS.each do |field_name|
        if field_data = data.delete(field_name)
          event_data[field_name] = field_data
        end
      end
      event_data["@fields"].merge!(data)
      LogStash::Event.new(event_data)
    when String
      LogStash::Event.new("message" => data, "@timestamp" => time)
    end

    event['severity'] ||= severity
    #event.type = progname
    event['source'] = HOST

    hash = event.to_hash
    hash['@timestamp'] = time.iso8601(3)
    hash.to_json
  end
end
