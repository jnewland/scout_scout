require 'hashie'
require 'httparty'
require 'scout_scout/version'
require 'cgi'

class ScoutScout
  include HTTParty
  base_uri 'https://scoutapp.com'
  format :xml
  mattr_inheritable :account

  def initialize(acct, user, pass)
    self.class.account = acct
    self.class.basic_auth user, pass
  end

  def alerts(hostname = nil)
    if hostname.nil?
      response = self.class.get("/#{self.class.account}/activities.xml")
      response['alerts'].map { |alert| Hashie::Mash.new(alert) }
    else
      response = self.class.get("/#{self.class.account}/activities.xml?host=hostname")
      response['alerts'].map { |alert| Hashie::Mash.new(alert) }
    end
  end

  def clients
    response = self.class.get("/#{self.class.account}/clients.xml")
    response['clients'].map { |client| Hashie::Mash.new(client) }
  end

  def client(hostname)
    response = self.class.get("/#{self.class.account}/clients.xml?host=#{hostname}")
    Hashie::Mash.new(response['clients'].first)
  end

  def plugins(hostname)
    response = self.class.get("/#{self.class.account}/plugins.xml?host=#{hostname}")
    response['plugins'].map { |plugin| Hashie::Mash.new(plugin) }
  end

  def plugin_data(hostname, plugin_name)
    response = self.class.get("/#{self.class.account}/plugins/show.xml?host=#{hostname}&name=#{CGI.escape(plugin_name)}")
    Hashie::Mash.new(response['plugin'])
  end
end