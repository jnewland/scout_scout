class ScoutScout::Cluster < Hashie::Mash
  # Find the average value of a descriptor by name (ex: 'last_minute').
  #
  # Options:
  #
  # * <tt>:host</tt>: Only selects descriptors from servers w/hostnames matching this pattern.
  #   Use a MySQL-formatted Regex. http://dev.mysql.com/doc/refman/5.0/en/regexp.html
  # * <tt>:start</tt>: The start time for grabbing metrics. Default is 1 hour ago. Times will be converted to UTC.
  # * <tt>:end</tt>: The end time for grabbing metrics. Default is NOW. Times will be converted to UTC.
  # * <tt>:per_server</tt>: Whether the result should be returned per-server or an aggregate of the entire cluster.
  #   Default is false. Note that total is not necessary equal to the value on each server * num of servers.
  # Examples:
  #
  # How much memory are my servers using?
  # ScoutScout::Cluster.average('mem_used')
  #
  # What is the average per-server load on my servers?
  # ScoutScout::Cluster.average('cpu_last_minute', :per_server => true)
  #
  # How much disk space is available on our db servers?
  # ScoutScout::Cluster.average('disk_avail',:host => "db[0-9]*.awesomeapp.com")
  #
  # How much memory did my servers use yesterday?
  # ScoutScout::Cluster.average('mem_used', :start => Time.now-(24*60*60)*2, :end => Time.now-(24*60*60)*2)
  #
  # @return [ScoutScout::Metric]
  def self.average(descriptor,options = {})
    calculate('AVG',descriptor,options)
  end

  # Find the maximum value of a descriptor by name (ex: 'last_minute').
  #
  # See +average+ for options and examples.
  #
  # @return [ScoutScout::Metric]
  def self.maximum(descriptor,options = {})
    calculate('MAX',descriptor,options)
  end

  # Find the minimum value of a descriptor by name (ex: 'last_minute').
  #
  # See +average+ for options and examples.
  #
  # @return [ScoutScout::Metric]
  def self.minimum(descriptor,options = {})
    calculate('MIN',descriptor,options)
  end

  def self.calculate(function,descriptor,options = {})
    consolidate = options[:per_server] ? 'AVG' : 'SUM'
    start_time,end_time=format_times(options)
    response = ScoutScout.get("/#{ScoutScout.account}/data/value?descriptor=#{CGI.escape(descriptor)}&function=#{function}&consolidate=#{consolidate}&host=#{options[:host]}&start=#{start_time}&end=#{end_time}")

    if response['data']
      ScoutScout::Metric.new(response['data'])
    else
      ScoutScout::Error.new(response['error'])
    end
  end

  # API expects times in epoch.
  def self.format_times(options)
    options.values_at(:start,:end).map { |t| t ? t.to_i : nil }
  end
end