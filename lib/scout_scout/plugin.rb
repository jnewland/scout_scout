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

  def email_subscribers
    response = ScoutScout.get("/#{ScoutScout.account}/clients/#{server.id}/email_subscribers?plugin_id=#{id}")
    doc = Nokogiri::HTML(response.body)

    table = doc.css('table.list').first
    user_rows = active_table.css('tr')[1..-1] # skip first row, which is headings

    user_rows.map do |row|
      name_td, receiving_notifications_td = *row.css('td')

      name = name_td.content.gsub(/[\t\n]/, '')
      checked = receiving_notifications_td.css('input').attribute('checked')
      receiving_notifications = checked && checked.value == 'checked'
      Hashie::Mash.new :name => name, :receiving_notifications => receiving_notifications
    end
    
  end

protected

  def decorate_with_server_and_plugin(hashie)
    hashie.server = self.server
    hashie.plugin = self
    hashie
  end

end
