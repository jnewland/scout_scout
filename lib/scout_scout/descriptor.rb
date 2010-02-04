class ScoutScout::Descriptor < Hashie::Mash
  # Search for descriptors by matching name and hostname. 
  #
  # Options:
  # 
  # - :descriptor => The descriptor name to match
  # - :host => The host name to match
  #
  # @return [Array] An array of ScoutScout::Descriptor objects
  def self.all(options = {})
    response = ScoutScout.get("/#{ScoutScout.account}/descriptors.xml?descriptor=#{CGI.escape(options[:descriptor] || String.new)}&host=#{options[:host]}")
    response['ar_descriptors'].map { |descriptor| ScoutScout::Descriptor.new(descriptor) }    
  end
end