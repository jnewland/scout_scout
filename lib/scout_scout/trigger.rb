class ScoutScout::Trigger < Hashie::Mash
  attr_writer :server, :plugin
  
  def server
    @server ||= ScoutScout::Server.first(id)
  end

  def plugin
    @plugin ||= server.plugin(plugin_id)
  end
end
