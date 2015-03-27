require 'rubygems'
require 'rspec'
require 'silverpop/client'
require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.raise_errors_for_deprecations!
end

def stub_post(url)
  stub_request(:post, url)
end

def stub_engage_post(url_params)
  stub_request(:post, "#{Silverpop::Request::DEFAULT_XMLAPI_URL}#{url_params}")
end

def fixture(file)
  fixtures_path = File.expand_path('../fixtures', __FILE__)
  File.new(fixtures_path + '/' + file)
end

def fixture_content(file)
  f = fixture(file)
  f.read.gsub!(/\s+/, ' ').gsub!(/>\s*</, "><")
end

def engage_response(file)
  xml = fixture_content(file)
  Silverpop::EngageResponse.new(::MultiXml.parse(xml))
end