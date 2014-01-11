class Time
  def to_json(*args)
    iso8601(3).to_json(*args)
  end
end
