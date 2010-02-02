class ScoutScout::Plugin < Hashie::Mash
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
    @descriptors ||= @descriptor_hash.map { |d| ScoutScout::Descriptor.new(d) }
  end
end