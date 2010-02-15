class ScoutScout::Alert < Hashie::Mash
  attr_writer :server

  # The Scout server that generated this alert
  #
  # @return [ScoutScout::Server]
  def server
    @server ||= ScoutScout::Server.first(client_id)
  end

  # The Scout plugin that generated this alert
  #
  # @return [ScoutScout::Plugin]
  def plugin
    server.plugin(plugin_id)
  end
end