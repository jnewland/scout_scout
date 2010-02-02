require 'scout_scout'
require 'spec'
require 'spec/autorun'
require 'fakeweb'

FakeWeb.allow_net_connect = false

class ScoutScout

  def scout_url(path)
    uri = URI.join(self.class.default_options[:base_uri], "#{self.class.account}/", path)
    uri.userinfo = "#{self.class.default_options[:basic_auth][:username]}:#{self.class.default_options[:basic_auth][:password]}".gsub(/@/, '%40')
    uri.to_s
  end

  def file_fixture(filename)
    open(File.join(File.dirname(__FILE__), 'fixtures', "#{filename.to_s}")).read
  end

  def stub_get(path, filename = nil, status=nil)
    filename = path if filename.nil?
    options = {:body => file_fixture(filename)}
    options.merge!({:status => status}) unless status.nil?
    FakeWeb.register_uri(:get, scout_url(path), options)
  end

  def stub_post(path, filename)
    FakeWeb.register_uri(:post, scout_url(path), :body => file_fixture(filename))
  end

  def stub_put(path, filename)
    FakeWeb.register_uri(:put, scout_url(path), :body => file_fixture(filename))
  end

  def stub_delete(path, filename)
    FakeWeb.register_uri(:delete, scout_url(path), :body => file_fixture(filename))
  end

  def stub_http_response_with(filename)
    format = filename.split('.').last.intern
    data = file_fixture(filename)

    response = Net::HTTPOK.new("1.1", 200, "Content for you")
    response.stub!(:body).and_return(data)

    http_request = HTTParty::Request.new(Net::HTTP::Get, 'http://localhost', :format => format)
    http_request.stub!(:perform_actual_request).and_return(response)

    HTTParty::Request.should_receive(:new).at_least(1).and_return(http_request)
  end

end