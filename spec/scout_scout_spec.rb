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
        @scout_scout.stub_get('clients.xml')
        @clients = @scout_scout.clients
      end
      it 'should list all clients' do
        @clients.size.should == 2
      end
      it "should be an array ScoutScout::Client objects" do
        @clients.first.class.should == ScoutScout::Client
      end
      it "should include active alerts" do
        @clients.last.active_alerts.first.class.should == ScoutScout::Alert
        @clients.last.active_alerts.first.title.should =~ /Passenger/
      end
    end
    describe 'alert log' do
      before(:each) do
        @scout_scout.stub_get('activities.xml')
        @activities = @scout_scout.alerts
      end
      it "should be an array ScoutScout::Alert objects" do
        @activities.first.class.should == ScoutScout::Alert
      end
      it "should be associated with it's plugin and client" do
        @scout_scout.stub_get('clients/24331.xml', 'client.xml')
        @activities.first.client.class.should == ScoutScout::Client
        @scout_scout.stub_get('clients/13431/plugins/122761.xml', 'plugin_data.xml')
        @activities.first.plugin.class.should == ScoutScout::Plugin
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
    describe 'should be accessable' do
      describe '' do
        before(:each) do
          @scout_scout.stub_get('clients/1234.xml', 'client.xml')
          @client = ScoutScout::Client.first(1234)
        end
        it "by id" do
          @client.key.should == 'FOOBAR'
          @client.class.should == ScoutScout::Client
        end
      end
      describe '' do
        before(:each) do
          @scout_scout.stub_get('clients.xml?host=foo.awesome.com', 'client_by_hostname.xml')
          @client = ScoutScout::Client.first('foo.awesome.com')
        end
        it "by hostname" do
          @client.key.should == 'FOOBAR'
          @client.class.should == ScoutScout::Client
        end
      end
    end
    describe 'alert log' do
      before(:each) do
        @scout_scout.stub_get('clients/13431.xml', 'client.xml')
        @client = ScoutScout::Client.first(13431)
        @scout_scout.stub_get('clients/13431/activities.xml', 'activities.xml')
        @activities = @client.alerts
      end
      it "should be accessable" do
        @activities.size.should == 2
        @activities.each do |activity|
          activity.title.should =~ /Passenger/
        end
      end
      it "should be an array ScoutScout::Alert objects" do
        @activities.first.class.should == ScoutScout::Alert
      end
    end
    describe 'plugin' do
      describe 'list' do
        before(:each) do
          @scout_scout.stub_get('clients/13431.xml', 'client.xml')
          @client = ScoutScout::Client.first(13431)
          @scout_scout.stub_get('clients/13431/plugins.xml', 'plugins.xml')
          @plugins = @client.plugins
        end
        it "should be accessable" do
          @plugins.size.should == 2
          @plugins.each do |plugin|
            plugin.name.should =~ /Passenger/
            plugin.descriptors.length.should == 11
          end
        end
        it "should be an array ScoutScout::Plugin objects" do
          @plugins.first.class.should == ScoutScout::Plugin
        end
      end
      describe 'individually' do
        before(:each) do
          @scout_scout.stub_get('clients/13431.xml', 'client.xml')
          @client = ScoutScout::Client.first(13431)
          @scout_scout.stub_get('clients/13431/plugins/12345.xml', 'plugin_data.xml')
          @plugin_data = @client.plugin(12345)
        end
        it "should be accessable" do
          @plugin_data.class.should == ScoutScout::Plugin
          @plugin_data.name.should == 'Passenger'
          @plugin_data.descriptors.length.should == 11
        end
        it "should include descriptors" do
          @plugin_data.descriptors.first.class.should == ScoutScout::Descriptor
          @plugin_data.descriptors.first.value.should == '31'
          @plugin_data.descriptors.first.name.should == 'passenger_process_active'
        end
        it "should be an ScoutScout::Plugin objects" do
        end
      end

    end
    describe 'descriptor list' do
      before(:each) do
        @scout_scout.stub_get('clients/13431.xml', 'client.xml')
        @client = ScoutScout::Client.first(13431)
        @scout_scout.stub_get('descriptors.xml?descriptor=&host=foobar.com&', 'descriptors.xml')
        @descriptors = @client.descriptors
      end
      it "should be accessable" do
        @descriptors.size.should == 30
      end
      it "should be an array ScoutScout::Descriptor objects" do
        @descriptors.first.class.should == ScoutScout::Descriptor
      end
    end
  end
end
