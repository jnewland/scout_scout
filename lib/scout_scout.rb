require 'hashie'
require 'httparty'
require 'scout_scout/version'
require 'scout_scout/client'
require 'scout_scout/descriptor'
require 'scout_scout/plugin'
require 'scout_scout/alert'

class ScoutScout
  include HTTParty
  base_uri 'https://scoutapp.com'
  format :xml
  mattr_inheritable :account

  def initialize(scout_account_name, username, password)
    self.class.account = scout_account_name
    self.class.basic_auth username, password
  end

  # Recent alerts across all clients on this account
  #
  # @return [Array] An array of ScoutScout::Alert objects
  def alerts
    response = self.class.get("/#{self.class.account}/activities.xml")
    response['alerts'].map { |alert| ScoutScout::Alert.new(alert) }
  end

  # All clients on this account
  #
  # @return [Array] An array of ScoutScout::Client objects
  def clients
    response = self.class.get("/#{self.class.account}/clients.xml")
    response['clients'].map { |client| ScoutScout::Client.new(client) }
  end

end