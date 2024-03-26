# frozen_string_literal: true

module StructuredLog
  # Timing example:
  #
  #  StructuredLog.capture(
  #    "Some timing metric",
  #    {
  #      class_name: "User",
  #      method: "a_slow_method",
  #      some_arbitrary_data: 123,
  #      ms: 123.45,
  #    }
  #  )
  #
  # Error occurrence example:
  #
  #  StructuredLog.capture(
  #    "Some error metric",
  #    {
  #      class_name: "Team",
  #      method: "some_erroring_method",
  #      some_arbitrary_data: 123,
  #      message: "A description of the error",
  #    }
  #  )
  #
  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def self.capture(name, data_hash)
    log(name, data_hash)
  rescue StandardError => e
    logger.warn "Error capturing structured log for metric=#{name} - #{e.message}"
  end

  private_class_method def self.log(name, data_hash)
    raise ArgumentError, 'log name should be formatted in UPPERCASE_AND_UNDERSCORES' if name[/[^A-Z0-9_]/]

    info = ["[#{name}]"]
    cleaned_data_hash = base_data.merge(data_hash).map do |k, v|
      # if the value is a string and doesn't already have quotes around it
      # then add quotes so Datadog interprets the whitespaces in the value as part of the string message
      if v.instance_of?(String) &&
         v.include?(' ') &&
         !(["'", '"'].include?(v[0]) && ["'", '"'].include?(v[-1]))
        "#{k}='#{v}'"
      elsif v.nil?
        "#{k}=nil"
      else
        "#{k}=#{v}"
      end
    end

    logger.info info.concat(cleaned_data_hash).join(' ')
  end

  def self.loggable_datetime(time: nil)
    datetime_to_use = time || Time.current
    datetime_to_use.iso8601
  end

  def self.base_data
    {}
  end
end
