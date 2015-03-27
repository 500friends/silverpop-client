require 'oauth2'
require 'faraday_middleware'
require 'silverpop/client/version'
require 'silverpop/exceptions'
require 'silverpop/engage_response'
require 'silverpop/request'
require 'silverpop/engage'
require 'silverpop/transact'
require 'silverpop/util'

module Silverpop
  class Client

    DEFAULT_OAUTH_TOKEN_URL = 'https://apipilot.silverpop.com/oauth/token'
    DEFAULT_XMLAPI_URL = 'https://api.silverpop.com/XMLAPI'
    DEFAULT_XTMAIL_URL = "https://transactpilot.silverpop.com/XTMail"

    attr_accessor :access_token

    def initialize(options={})
      @xmlapi_url = options[:xmlapi_url] || DEFAULT_XMLAPI_URL
      @xtmail_url = options[:xtmail_url] || DEFAULT_XTMAIL_URL
      @access_token = options[:access_token] ||
          generate_access_token(options[:client_id], options[:client_secret], options[:refresh_token], options[:auth_url])
    end

    def generate_access_token(client_id, client_secret, refresh_token, auth_url = DEFAULT_OAUTH_TOKEN_URL)
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      @auth_url = auth_url
      @client = OAuth2::Client.new(client_id, client_secret, site: @auth_url)
      oauth_token = OAuth2::AccessToken.from_hash(@client, refresh_token: refresh_token).refresh!
      oauth_token.token
    end

    def connection
      @_connection = Client::new_connection(@access_token)
    end

    def engage_request
      @engage ||= Silverpop::Engage.new(connection, @xmlapi_url)
    end

    def transact_request
      @transact ||= Silverpop::Transact.new(connection, @xtmail_url)
    end

    def method_missing(method, *args, &block)
      if engage_request.respond_to?(method)
        return engage_request.invoke_api(method, *args, &block)
      elsif transact_request.respond_to?(method)
        return transact_request.invoke_api(method, *args, &block)
      end
      super
    end

    def respond_to?(method, include_private=false)
      engage_request.respond_to?(method) || transact_request.respond_to?(method) || super(method, include_private)
    end

    def generate(method, *args, &block)
      if engage_request.respond_to?(method)
        engage_request.xml(method, *args, &block)
      elsif transact_request.respond_to?(method)
        return transact_request.xml(method, *args, &block)
      end
    end

    def invoke(method, *args, &block)
      engage_request.invoke_api(method, *args, &block) || transact_request.invoke_api(method, *args, &block)
    end

    def self.new_connection(access_token)
      Faraday.new do |conn|
        conn.adapter Faraday.default_adapter
        conn.request :oauth2, access_token
        conn.request :url_encoded
        conn.response :mashify
        conn.response :xml, :content_type => /\bxml$/
      end
    end

  end
end
