require 'hashie'
require 'httparty'
require 'scout_scout/version'
require 'cgi'

class ScoutScout
  include HTTParty
  base_uri 'https://scoutapp.com'
  format :xml
  mattr_inheritable :account

  def initialize(scout_account_name, username, password)
    self.class.account = scout_account_name
    self.class.basic_auth username, password
  end

  def alerts(client_id_or_hostname = nil)
    response = if client_id_or_hostname.nil?
      self.class.get("/#{self.class.account}/activities.xml")
    elsif client_id_or_hostname.is_a?(Fixnum)
      self.class.get("/#{self.class.account}/clients/#{client_id_or_hostname}/activities.xml")
    else
      self.class.get("/#{self.class.account}/activities.xml?host=#{client_id_or_hostname}")
    end
    response['alerts'].map { |alert| Hashie::Mash.new(alert) }
  end

  def clients
    response = self.class.get("/#{self.class.account}/clients.xml")
    response['clients'].map { |client| Hashie::Mash.new(client) }
  end

  def client(client_id_or_hostname)
    if client_id_or_hostname.is_a?(Fixnum)
      response = self.class.get("/#{self.class.account}/clients/#{client_id_or_hostname}.xml")
      Hashie::Mash.new(response['client'])
    else
      response = self.class.get("/#{self.class.account}/clients.xml?host=#{client_id_or_hostname}")
      Hashie::Mash.new(response['clients'].first)
    end
  end

  def plugins(client_id_or_hostname)
    response = if client_id_or_hostname.is_a?(Fixnum)
      self.class.get("/#{self.class.account}/clients/#{client_id_or_hostname}/plugins.xml")
    else
      self.class.get("/#{self.class.account}/plugins.xml?host=#{client_id_or_hostname}")
    end
    response['plugins'].map { |plugin| format_plugin(Hashie::Mash.new(plugin)) }
  end

  def plugin_data(hostname, plugin_name)
    response = self.class.get("/#{self.class.account}/plugins/show.xml?host=#{hostname}&name=#{CGI.escape(plugin_name)}")
    format_plugin(Hashie::Mash.new(response['plugin']))
  end

protected

  def format_plugin(plugin)
    plugin.descriptors = plugin.descriptors.descriptor
    plugin
  end

end