require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ScoutScout" do
  before(:each) do
    @scout_scout = ScoutScout.new('account', 'username', 'password')
  end
  it "should provide a version constant" do
    ScoutScout::VERSION.should be_instance_of(String)
  end
  it "should set the client and basic auth parameters when initialized" do
    @scout_scout.class.account.should == 'account'
    @scout_scout.class.default_options[:basic_auth].should == { :username => 'username', :password => 'password' }
  end
  describe "global" do
    describe "client list" do
      before(:each) do
        stub_http_response_with('clients.xml')
        @clients = @scout_scout.clients
      end
      it 'should list all clients' do
        @clients.size.should == 2
      end
      it "should include active alerts" do
        @clients.last.active_alerts.first.title.should =~ /Passenger/
      end
    end
    describe 'alert log' do
      before(:each) do
        stub_http_response_with('activities.xml')
        @activities = @scout_scout.alerts
      end
      it "should be accessable" do
        @activities.size.should == 2
        @activities.each do |activity|
          activity.title.should =~ /Passenger/
        end
      end
    end
  end
  describe 'individual clients' do
    describe '' do
      before(:each) do
        stub_http_response_with('client.xml')
        @client = @scout_scout.client(1234)
      end
      it "should be accessable" do
        @client.key.should == 'FOOBAR'
      end
    end
    describe 'alert log' do
      before(:each) do
        stub_http_response_with('activities.xml')
        @activities = @scout_scout.alerts(1234)
      end
      it "should be accessable" do
        @activities.size.should == 2
        @activities.each do |activity|
          activity.title.should =~ /Passenger/
        end
      end
    end
    describe 'plugins' do
      describe '' do
        before(:each) do
          stub_http_response_with('plugins.xml')
          @plugins = @scout_scout.plugins(1234)
        end
        it "should be accessable" do
          @plugins.size.should == 4
          @plugins.each do |plugin|
            plugin.code.should =~ /Scout::Plugin/
          end
        end
      end
      describe 'data' do
        before(:each) do
          stub_http_response_with('plugin.html')
          @plugin_data = @scout_scout.plugin_data(1234,5678)
        end
        it "should be accessable" do
          @plugin_data.size.should == 13
        end
        it "should include data" do
          @plugin_data.first.data.should == '6 MB'
        end
        it "should include graph URLs" do
          @plugin_data.first.graph.should == 'https://scoutapp.com/account/descriptors/368241/graph'
        end
        it "should include name" do
          @plugin_data.first.name.should == 'Swap Used'
        end
      end
    end
  end
end
