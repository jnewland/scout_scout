class ScoutScout::Client < Hashie::Mash
  def initialize(hash)
    if hash['active_alerts']
      @alert_hash = hash['active_alerts']
      hash.delete('active_alerts')
    end
    super(hash)
  end

  # Search for a client by id or matching hostname
  #
  # @return [ScoutScout::Client]
  def self.first(client_id_or_hostname)
    if client_id_or_hostname.is_a?(Fixnum)
      response = ScoutScout.get("/#{ScoutScout.account}/clients/#{client_id_or_hostname}.xml")
      ScoutScout::Client.new(response['client'])
    else
      response = ScoutScout.get("/#{ScoutScout.account}/clients.xml?host=#{client_id_or_hostname}")
      ScoutScout::Client.new(response['clients'].first)
    end
  end
  
  # Search for clients by matching hostname. 
  #
  # @return [Array] An array of ScoutScout::Client objects
  def self.all(hostname)
    response = ScoutScout.get("/#{ScoutScout.account}/clients.xml?host=#{hostname}")
    response['clients'].map { |client| ScoutScout::Client.new(client) }    
  end

  # Active alerts for this client
  #
  # @return [Array] An array of ScoutScout::Alert objects
  def active_alerts
    @active_alerts ||= @alert_hash.map { |a| ScoutScout::Alert.new(a) }
  end

  # Recent alerts for this client
  #
  # @return [Array] An array of ScoutScout::Alert objects
  def alerts
    response = ScoutScout.get("/#{ScoutScout.account}/clients/#{self.id}/activities.xml")
    response['alerts'].map { |alert| ScoutScout::Alert.new(alert) }
  end

  # Details about all plugins for this client
  #
  # @return [Array] An array of ScoutScout::Plugin objects
  def plugins
    response = ScoutScout.get("/#{ScoutScout.account}/clients/#{self.id}/plugins.xml")
    response['plugins'].map { |plugin| ScoutScout::Plugin.new(plugin) }
  end

  # Details about a specific plugin
  #
  # @return [ScoutScout::Plugin]
  def plugin(id)
    response = ScoutScout.get("/#{ScoutScout.account}/clients/#{self.id}/plugins/#{id}.xml")
    ScoutScout::Plugin.new(response['plugin'])
  end
end