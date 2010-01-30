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

  def alerts(id_or_hostname = nil)
    response = if id_or_hostname.nil?
      self.class.get("/#{self.class.account}/activities.xml")
    elsif id_or_hostname.is_a?(Fixnum)
      self.class.get("/#{self.class.account}/clients/#{id_or_hostname}/activities.xml")
    else
      self.class.get("/#{self.class.account}/activities.xml?host=#{id_or_hostname}")
    end
    response['alerts'].map { |alert| Hashie::Mash.new(alert) }
  end

  def clients
    response = self.class.get("/#{self.class.account}/clients.xml")
    response['clients'].map { |client| Hashie::Mash.new(client) }
  end

  def client(id_or_hostname)
    if id_or_hostname.is_a?(Fixnum)
      response = self.class.get("/#{self.class.account}/clients/#{id_or_hostname}.xml")
      Hashie::Mash.new(response['client'])
    else
      response = self.class.get("/#{self.class.account}/clients.xml?host=#{id_or_hostname}")
      Hashie::Mash.new(response['clients'].first)
    end
  end

  def plugins(id_or_hostname)
    response = if id_or_hostname.is_a?(Fixnum)
      self.class.get("/#{self.class.account}/clients/#{id_or_hostname}/plugins.xml")
    else
      self.class.get("/#{self.class.account}/plugins.xml?host=#{id_or_hostname}")
    end
    response['plugins'].map { |plugin| Hashie::Mash.new(plugin) }
  end

  def plugin_data(hostname, plugin_name)
    response = self.class.get("/#{self.class.account}/plugins/show.xml?host=#{hostname}&name=#{CGI.escape(plugin_name)}")
    response = Hashie::Mash.new(response['plugin'])
    #munge the descriptors
    response.descriptors = response.descriptors.map { |item| item[1].first }
    response
  end
end