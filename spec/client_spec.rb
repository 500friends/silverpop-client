require 'spec_helper'

describe Silverpop::Client do
  describe "access" do
    it "should return a access token" do
      c = Silverpop::Client.new(access_token: 'test_token')
      c.access_token.should == 'test_token'
    end

    it "should regenerate access token" do
      c = Silverpop::Client.new(access_token: 'test_token', regenerate_token: 1)
      Silverpop::Client::expects(:generate_access_token).once.returns('new_token')
      Silverpop::Engage.any_instance.expects(:post).twice.returns(fixture_xml_content('error_response.xml'), fixture_xml_content('get_job_status_response.xml'))
      c.get_job_status('40865')
      c.access_token.should == 'new_token'
    end

    it "should not raise exception on error response" do
      c = Silverpop::Client.new(access_token: 'test_token')
      Silverpop::Engage.any_instance.expects(:post).once.returns(fixture_xml_content('error_response.xml'))
      c.get_job_status('40865')
    end
  end
end
