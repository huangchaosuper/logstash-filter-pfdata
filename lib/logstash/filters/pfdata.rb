# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/json"
require "logstash/timestamp"

class LogStash::Filters::Pfdata < LogStash::Filters::Base
  config_name "pfdata"
  
  # The string to split on. This is usually a line terminator, but can be any
  # string.
  config :terminator, :validate => :string, :default => "\n"

  # The field which value is split by the terminator
  config :field, :validate => :string, :default => "http_pf_data"

  # The field within the new event which the value is split into.
  # If not set, target field defaults to split field name.
  config :target, :validate => :string, :default => "pfdata"
  
  config :tag_on_failure, :validate => :array, :default => ["_jsonparsefailure"]

  public
  def register
    # null
  end # def register

  public
  def filter(event)
    original_value = event[@field]
    return unless original_value
    parsed = "[]";
    begin
      parsed = Base64.decode64(original_value) if original_value != '-'
      json_value = LogStash::Json.load(parsed)
    rescue => e
      @tag_on_failure.each{|tag| event.tag(tag)}
      json_value = LogStash::Json.load("[]")
    end

    if json_value.is_a?(Array)
      splits = json_value
    elsif json_value.is_a?(String)
      splits = json_value.split(@terminator, -1)
      return if splits.length == 1
    else
      splits = Array.new(1,"NA")
    end

    splits.each do |value|
      next if value.empty?

      event_split = event.clone
      @logger.debug("Split event", :value => value, :field => @field)
      event_split[(@target || @field)] = value
      filter_matched(event_split)

      # Push this new event onto the stack at the LogStash::FilterWorker
      yield event_split
    end

    # Cancel this event, we'll use the newly generated ones above.
    event.cancel
  end # def filter
end # class LogStash::Filters::Pfdata
