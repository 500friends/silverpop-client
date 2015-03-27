require 'spec_helper'

describe Silverpop::Client do
  describe "access" do
    it "should return a access token" do
      c = Silverpop::Client.new(access_token: 'test_token')
      c.access_token.should == 'test_token'
    end
  end
end
