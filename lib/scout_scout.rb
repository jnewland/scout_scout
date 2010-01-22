require 'hashie'
require 'httparty'
require 'scout_scout/version'

class ScoutScout
  include HTTParty
  base_uri 'https://scoutapp.com'
  format :xml
  mattr_inheritable :account

  def initialize(acct, user, pass)
    self.class.account = acct
    self.class.basic_auth user, pass
  end

  def alerts(id = nil)
    if id.nil?
      response = self.class.get("/#{self.class.account}/activities.xml")
      response['alerts'].map { |alert| Hashie::Mash.new(alert) }
    else
      response = self.class.get("/#{self.class.account}/clients/#{id}/activities.xml")
      response['alerts'].map { |alert| Hashie::Mash.new(alert) }
    end
  end

  def clients
    response = self.class.get("/#{self.class.account}/clients.xml")
    response['clients'].map { |client| Hashie::Mash.new(client) }
  end

  def client(id)
    response = self.class.get("/#{self.class.account}/clients/#{id}.xml")
    Hashie::Mash.new(response['client'])
  end

  def plugins(id)
    response = self.class.get("/#{self.class.account}/clients/#{id}/plugins.xml")
    response['plugins'].map { |plugin| Hashie::Mash.new(plugin) }
  end

  def plugin_data(client, id)
    require 'nokogiri'
    html = self.class.get("/#{self.class.account}/clients/#{client}/plugins/#{id}", :format => :html)
    plugin_doc = Nokogiri::HTML(html)
    table = plugin_doc.css('table.list.spaced').first
    data = []
    table.css('tr').each do |row|
      if (columns = row.css('td')).length == 2
        link = columns.first.css('a').first
        descriptor = {}
        descriptor[:name] = link.content
        descriptor[:data] = columns[1].content.strip
        descriptor[:id] = link.attribute('href').to_s.gsub(/.*=/,'').to_i
        descriptor[:graph] = "#{self.class.base_uri}/#{self.class.account}/descriptors/#{descriptor[:id]}/graph"
        data << Hashie::Mash.new(descriptor)
      end
    end
    data
  end
end