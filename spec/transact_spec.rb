require 'spec_helper'
require 'oauth2'

describe Silverpop::Engage do

  describe "#xtmailing" do
    it "should send a template-based mailing to a specific list" do

      token = 'test_token'
      @client = Silverpop::Client.new(access_token: token)
      @connection = Silverpop::Client.new_connection(token)
      @request = Silverpop::Transact.new(@connection)
      personalization = {'NAME' => 'good', 'Balance' => 100}

      request = @request.xtmailing(22341598, 'i@email.com', personalization)
      request.should == fixture_content('xtmailing_request.xml')
    end
  end
end
