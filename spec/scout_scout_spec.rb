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
      it "should include active alerts" do
        @clients.last.active_alerts.first.title.should =~ /Passenger/
      end
    end
    describe 'alert log' do
      before(:each) do
        @scout_scout.stub_get('activities.xml')
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
    describe 'should be accessable' do
      describe '' do
        before(:each) do
          @scout_scout.stub_get('clients/1234.xml', 'client.xml')
          @client = @scout_scout.client(1234)
        end
        it "by id" do
          @client.key.should == 'FOOBAR'
        end
      end
      describe '' do
        before(:each) do
          @scout_scout.stub_get('clients.xml?host=foo.awesome.com', 'client_by_hostname.xml')
          @client = @scout_scout.client('foo.awesome.com')
        end
        it "by hostname" do
          @client.key.should == 'FOOBAR'
        end
      end
    end
    describe 'alert log' do
      before(:each) do
        @scout_scout.stub_get('clients/1234/activities.xml', 'activities.xml')
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
          @scout_scout.stub_get('clients/1234/plugins.xml', 'plugins.xml')
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
          @scout_scout.stub_get('plugins/show.xml?host=foo.awesome.com&name=passenger', 'plugin_data.xml')
          @plugin_data = @scout_scout.plugin_data('foo.awesome.com','passenger')
        end
        it "should be accessable" do
          @plugin_data.name.should == 'Passenger'
        end
        it "should include descriptors" do
          @plugin_data.descriptors.first.value.should == '31'
          @plugin_data.descriptors.first.name.should == 'passenger_process_active'
        end
      end

    end
  end
end
