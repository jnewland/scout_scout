class ScoutScout::Plugin < Hashie::Mash
  attr_accessor :server

  def initialize(hash)
    if hash['descriptors'] && hash['descriptors']['descriptor']
      @descriptor_hash = hash['descriptors']['descriptor']
      hash.delete('descriptors')
    end
    super(hash)
  end

  # All descriptors for this plugin, including their name and current
  #
  # @return [Array] An array of ScoutScout::Descriptor objects
  def descriptors
    @descriptors ||= @descriptor_hash.map { |d| decorate_with_server_and_plugin(ScoutScout::Descriptor.new(d)) }
  end

protected

  def decorate_with_server_and_plugin(hashie)
    hashie.server = self.server
    hashie.plugin = self
    hashie
  end

end