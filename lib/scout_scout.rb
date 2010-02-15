require 'hashie'
require 'httparty'
require 'cgi'
require 'scout_scout/version'
require 'scout_scout/server'
require 'scout_scout/descriptor'
require 'scout_scout/plugin'
require 'scout_scout/alert'
require 'scout_scout/cluster.rb'
require 'scout_scout/metric.rb'

class ScoutScout
  include HTTParty
  base_uri 'https://scoutapp.com'
  format :xml
  mattr_inheritable :account
  
  class Error < RuntimeError
  end

  def initialize(scout_account_name, username, password)
    self.class.account = scout_account_name
    self.class.basic_auth username, password
  end

  # Recent alerts across all servers on this account
  #
  # @return [Array] An array of ScoutScout::Alert objects
  def alerts
    response = self.class.get("/#{self.class.account}/activities.xml")
    response['alerts'].map { |alert| ScoutScout::Alert.new(alert) }
  end

  # All servers on this account
  #
  # @return [Array] An array of ScoutScout::Server objects
  def servers
    response = self.class.get("/#{self.class.account}/clients.xml")
    response['clients'].map { |client| ScoutScout::Server.new(client) }
  end
  
  class << self
    alias_method :http_get, :get
  end
  
  # Checks for errors via the HTTP status code. If an error is found, a 
  # ScoutScout::Error is raised. Otherwise, the response.
  # 
  # @return HTTParty::Response
  def self.get(uri)
    response = http_get(uri)
    response.code.to_s =~ /^(4|5)/ ? raise( ScoutScout::Error,response.message) : response
  end

end