require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ScoutScout" do
  it "should provide a version constant" do
    ScoutScout::VERSION.should be_instance_of(String)
  end
end
