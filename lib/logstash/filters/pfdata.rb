# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/json"
require "logstash/timestamp"

# This example filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Pfdata < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
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
    # Add instance variables 
  end # def register

  public
  def filter(event)
    
    original_value = event[@field]
    return unless original_value

    begin
      parsed = "{}";
      parsed = Base64.decode64(parsed) if parsed != '-'
      json_value = LogStash::Json.load(parsed)
    rescue => e
      @tag_on_failure.each{|tag| event.tag(tag)}
      @logger.warn("Error parsing json", :field => @field, :raw => field, :exception => e)
      return
    end



    if json_value.is_a?(Array)
      splits = json_value
    elsif json_value.is_a?(String)
      # Using -1 for 'limit' on String#split makes ruby not drop trailing empty
      # splits.
      splits = json_value.split(@terminator, -1)
    else
      raise LogStash::ConfigurationError, "Only String and Array types are splittable. field:#{@field} is of type = #{original_value.class}"
    end

    # Skip filtering if splitting this event resulted in only one thing found.
    return if splits.length == 1 && json_value.is_a?(String)
    #or splits[1].empty?

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
