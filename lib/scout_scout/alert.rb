class ScoutScout::Alert < Hashie::Mash
  # The Scout client that generated this alert
  #
  # @return [ScoutScout::Client]
  def client
    @client ||= ScoutScout::Client.first(client_id)
  end

  # The Scout plugin that generated this alert
  #
  # @return [ScoutScout::Plugin]
  def plugin
    client.plugin(plugin_id)
  end
end