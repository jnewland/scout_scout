require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ScoutScout" do
  before(:each) do
    @scout_scout = ScoutScout.new('account', 'username', 'password')
  end
  it "should provide a version constant" do
    ScoutScout::VERSION.should be_instance_of(String)
  end
  it "should set the server and basic auth parameters when initialized" do
    @scout_scout.class.account.should == 'account'
    @scout_scout.class.default_options[:basic_auth].should == { :username => 'username', :password => 'password' }
  end
  describe "global" do
    describe "server list" do
      before(:each) do
        @scout_scout.stub_get('clients.xml')
        @servers = @scout_scout.servers
      end
      it 'should list all servers' do
        @servers.size.should == 2
      end
      it "should be an array ScoutScout::Server objects" do
        @servers.first.class.should == ScoutScout::Server
      end
      it "should include active alerts" do
        @servers.last.active_alerts.first.class.should == ScoutScout::Alert
        @servers.last.active_alerts.first.title.should =~ /Passenger/
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
      it "should be associated with it's plugin and server" do
        @scout_scout.stub_get('clients/24331.xml', 'client.xml')
        @activities.first.server.class.should == ScoutScout::Server
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
    describe 'descriptors' do
      before(:each) do
        @scout_scout.stub_get('descriptors.xml?descriptor=&host=&','descriptors.xml')
        @descriptors = ScoutScout::Descriptor.all
      end
      it "should be an array ScoutScout::Descriptor objects" do
        @descriptors.first.class.should == ScoutScout::Descriptor
      end
      it "should be accessable" do
        @descriptors.size.should == 30
      end
    end
    describe 'descriptor metrics' do
      before(:each) do
        @scout_scout.stub_get('data/value?descriptor=cpu_last_minute&function=AVG&consolidate=SUM&host=&start=&end=&','data.xml')
        @metric = ScoutScout::Cluster.average('cpu_last_minute')
      end
      it "should be a ScoutScout::Metric object" do
        @metric.class.should == ScoutScout::Metric
      end
      it "should contain the value" do
        @metric.value.should == '31.10'
      end
    end
  end
  describe 'individual servers' do
    describe 'should be accessable' do
      describe '' do
        before(:each) do
          @scout_scout.stub_get('clients/1234.xml', 'client.xml')
          @server = ScoutScout::Server.first(1234)
        end
        it "by id" do
          @server.key.should == 'FOOBAR'
          @server.class.should == ScoutScout::Server
        end
      end
      describe '' do
        before(:each) do
          @scout_scout.stub_get('clients.xml?host=foo.awesome.com', 'client_by_hostname.xml')
          @server = ScoutScout::Server.first('foo.awesome.com')
        end
        it "by hostname" do
          @server.key.should == 'FOOBAR'
          @server.class.should == ScoutScout::Server
        end
      end
    end
    describe '' do
      before(:each) do        
        @scout_scout.stub_post('clients.xml?client[copy_plugins_from_client_id]=&client[name]=sweet%20new%20server', 
        'client.xml', {:id => '1234'})
        @scout_scout.stub_get('clients/1234.xml', 'client.xml')
      end
      it 'can be created' do
        @server = ScoutScout::Server.create('sweet new server')
        @server.id.should == 13431
      end
    end
    describe '' do
      before(:each) do        
        @scout_scout.stub_delete('clients/1234.xml','client.xml', {'status' => '200 OK'})
      end
      it 'can be deleted' do
        ScoutScout::Server.delete(1234).should == true
      end
    end
    describe 'alert log' do
      before(:each) do
        @scout_scout.stub_get('clients/13431.xml', 'client.xml')
        @server = ScoutScout::Server.first(13431)
        @scout_scout.stub_get('clients/13431/activities.xml', 'activities.xml')
        @activities = @server.alerts
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
          @server = ScoutScout::Server.first(13431)
          @scout_scout.stub_get('clients/13431/plugins.xml', 'plugins.xml')
          @plugins = @server.plugins
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
          @server = ScoutScout::Server.first(13431)
          @scout_scout.stub_get('clients/13431/plugins/12345.xml', 'plugin_data.xml')
          @plugin_data = @server.plugin(12345)
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
    describe 'trigger' do
      describe 'list' do
        before(:each) do
          @scout_scout.stub_get('clients/13431.xml', 'client.xml')
          @server = ScoutScout::Server.first(13431)
          @scout_scout.stub_get('clients/13431/triggers.xml', 'triggers.xml')
          @triggers = @server.triggers
        end
        it "should be accessable" do
          @triggers.size.should == 3
          @triggers.each do |trigger|
            trigger.simple_type.should == 'peak'
          end
        end
        it "should be an array of ScoutScout::Trigger objects" do
          @triggers.first.class.should == ScoutScout::Trigger
        end
      end
    end
    describe 'descriptor list' do
      before(:each) do
        @scout_scout.stub_get('clients/13431.xml', 'client.xml')
        @server = ScoutScout::Server.first(13431)
        @scout_scout.stub_get('descriptors.xml?descriptor=&host=foobar.com&', 'descriptors.xml')
        @descriptors = @server.descriptors
      end
      it "should be accessable" do
        @descriptors.size.should == 30
      end
      it "should be an array ScoutScout::Descriptor objects" do
        @descriptors.first.class.should == ScoutScout::Descriptor
      end
    end
    describe 'descriptor metrics' do
      before(:each) do
        @scout_scout.stub_get('clients/13431.xml', 'client.xml')
        @server = ScoutScout::Server.first(13431)
        @scout_scout.stub_get('clients/13431/plugins.xml', 'plugins.xml')
        @plugins = @server.plugins
        @scout_scout.stub_get('data/value?descriptor=passenger_process_active&function=AVG&consolidate=SUM&host=foobar.com&start=&end=&','data.xml')
        @metric = @plugins.first.descriptors.first.average
      end
      it "should be a ScoutScout::Metric object" do
        @metric.class.should == ScoutScout::Metric
      end
      it "should contain the value" do
        @metric.value.should == '31.10'
      end
    end
  end
end
